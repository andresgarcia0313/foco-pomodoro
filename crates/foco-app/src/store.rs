//! Process-wide state shared by the QObjects. Everything runs on the Qt thread, so a
//! thread-local `RefCell` is enough; each QObject is a thin view over it.

use foco_core::{
    stats::Session,
    storage::{self, AppData, LoadOutcome},
    timer::Timer,
    usage::{self, Usage},
};
use std::{
    cell::RefCell,
    path::PathBuf,
    time::{Duration, Instant},
};

/// While a phase runs it is saved this often, so a crash or a kill loses at most this much.
const AUTOSAVE: Duration = Duration::from_secs(15);

pub struct Store {
    pub data: AppData,
    pub timer: Timer,
    path: PathBuf,
    usage: Usage,
    usage_changed: bool,
    saved_at: Instant,
}

thread_local! {
    static STORE: RefCell<Option<Store>> = const { RefCell::new(None) };
}

/// Loads `foco.json` and resumes the phase in progress, running if it was running.
pub fn init() {
    let path = config_dir().join(storage::FILE_NAME);
    let (mut data, outcome) = storage::load(&path);
    if let LoadOutcome::Recovered(backup) = outcome {
        eprintln!("foco: archivo dañado, copia en {}", backup.display());
    }
    let now = Instant::now();
    let timer = match data.session.take() {
        Some(snapshot) => Timer::restore(&data.settings, snapshot, now),
        None => Timer::new(&data.settings),
    };
    let text = std::fs::read_to_string(config_dir().join(usage::FILE_NAME)).unwrap_or_default();
    let usage = Usage::from_json(&text);
    let (usage_changed, saved_at) = (false, now);
    let store = Store {
        data,
        timer,
        path,
        usage,
        usage_changed,
        saved_at,
    };
    STORE.with_borrow_mut(|s| *s = Some(store));
}

/// Runs `f` with the store. Never call it again from inside `f`.
pub fn with<R>(f: impl FnOnce(&mut Store) -> R) -> R {
    STORE.with_borrow_mut(|s| f(s.as_mut().expect("store::init runs before the QML engine")))
}

impl Store {
    /// Writes both files atomically, including the running phase (RF-13).
    pub fn save(&mut self) {
        self.saved_at = Instant::now();
        self.data.session = self.timer.snapshot(self.saved_at);
        if let Err(err) = storage::save(&self.path, &self.data) {
            eprintln!("foco: no se pudo guardar {}: {err}", self.path.display());
        }
        if std::mem::take(&mut self.usage_changed) {
            let json = self.usage.to_json_within(usage::MAX_BYTES);
            let _ = storage::write_atomic(&self.path.with_file_name(usage::FILE_NAME), &json);
        }
    }

    pub fn save_if_due(&mut self) {
        if self.saved_at.elapsed() >= AUTOSAVE {
            self.save();
        }
    }

    /// Counts one use of a feature for today (local only, see `foco_core::usage`).
    pub fn track(&mut self, event: &str) {
        self.usage.track(chrono::Local::now().date_naive(), event);
        self.usage_changed = true;
    }

    /// Records a completed focus of `minutes` and credits the active task.
    pub fn record_focus(&mut self, minutes: u32) {
        let tasks = &mut self.data.tasks;
        let title = tasks
            .active()
            .and_then(|id| tasks.get(id))
            .map(|t| t.title.clone());
        tasks.credit_focus();
        let ended = chrono::Local::now().naive_local();
        self.data
            .history
            .record(Session::new(ended, minutes, title));
    }
}

/// `FOCO_CONFIG_DIR` isolates tests; otherwise the platform's configuration folder.
pub fn config_dir() -> PathBuf {
    std::env::var_os("FOCO_CONFIG_DIR")
        .map(PathBuf::from)
        .or_else(|| dirs::config_dir().map(|d| d.join("foco")))
        .unwrap_or_else(|| PathBuf::from("."))
}
