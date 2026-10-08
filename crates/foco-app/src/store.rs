//! Process-wide state shared by the four QObjects. Everything runs on the Qt thread, so a
//! thread-local `RefCell` is enough; each QObject is a thin view over it.

use foco_core::{
    stats::Session,
    storage::{self, AppData, LoadOutcome},
    timer::Timer,
};
use std::{cell::RefCell, path::PathBuf, time::Instant};

pub struct Store {
    pub data: AppData,
    pub timer: Timer,
    path: PathBuf,
}

thread_local! {
    static STORE: RefCell<Option<Store>> = const { RefCell::new(None) };
}

/// Loads `foco.json` and restores an interrupted phase (paused) when there is one.
pub fn init() {
    let path = config_dir().join(storage::FILE_NAME);
    let (mut data, outcome) = storage::load(&path);
    if let LoadOutcome::Recovered(backup) = outcome {
        eprintln!("foco: archivo dañado, copia en {}", backup.display());
    }
    let timer = match data.session.take() {
        Some(snapshot) => Timer::restore(&data.settings, snapshot),
        None => Timer::new(&data.settings),
    };
    STORE.with_borrow_mut(|s| *s = Some(Store { data, timer, path }));
}

/// Runs `f` with the store. Never call it again from inside `f`.
pub fn with<R>(f: impl FnOnce(&mut Store) -> R) -> R {
    STORE.with_borrow_mut(|s| f(s.as_mut().expect("store::init runs before the QML engine")))
}

impl Store {
    /// Writes the file atomically, including the running phase for RF-13.
    pub fn save(&mut self) {
        self.data.session = self.timer.snapshot(Instant::now());
        if let Err(err) = storage::save(&self.path, &self.data) {
            eprintln!("foco: no se pudo guardar {}: {err}", self.path.display());
        }
    }

    /// Records a completed focus and credits the active task.
    pub fn record_focus(&mut self) {
        let tasks = &mut self.data.tasks;
        let title = tasks.active().and_then(|id| tasks.get(id)).map(|t| t.title.clone());
        tasks.credit_focus();
        let ended = chrono::Local::now().naive_local();
        let minutes = self.data.settings.focus_minutes;
        self.data.history.record(Session::new(ended, minutes, title));
    }
}

/// `FOCO_CONFIG_DIR` isolates tests; otherwise the platform's configuration folder.
fn config_dir() -> PathBuf {
    std::env::var_os("FOCO_CONFIG_DIR")
        .map(PathBuf::from)
        .or_else(|| dirs::config_dir().map(|d| d.join("foco")))
        .unwrap_or_else(|| PathBuf::from("."))
}
