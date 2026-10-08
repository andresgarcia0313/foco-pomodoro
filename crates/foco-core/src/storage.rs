//! One JSON file in the user's config folder. Writes are atomic (temp file + rename) and a
//! damaged file is moved aside instead of blocking the app.

use crate::{settings::Settings, stats::History, tasks::TaskList, timer::Snapshot};
use serde::{Deserialize, Serialize};
use std::{
    fs, io,
    path::{Path, PathBuf},
};

pub const FILE_NAME: &str = "foco.json";

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
#[serde(default)]
pub struct AppData {
    pub version: u32,
    pub settings: Settings,
    pub tasks: TaskList,
    pub history: History,
    /// The phase in progress when the app was closed (RF-13).
    pub session: Option<Snapshot>,
}

#[derive(Debug)]
pub enum LoadOutcome {
    Fresh,
    Loaded,
    /// The file could not be read; it was renamed to the given backup.
    Recovered(PathBuf),
}

pub fn load(path: &Path) -> (AppData, LoadOutcome) {
    let text = match fs::read_to_string(path) {
        Ok(text) => text,
        Err(_) => return (AppData::default(), LoadOutcome::Fresh),
    };
    match serde_json::from_str::<AppData>(&text) {
        Ok(mut data) => {
            data.settings = data.settings.sanitized();
            (data, LoadOutcome::Loaded)
        }
        Err(_) => {
            let backup = path.with_extension(format!(
                "corrupt-{}.json",
                chrono::Local::now().format("%Y%m%d%H%M%S")
            ));
            let _ = fs::rename(path, &backup);
            (AppData::default(), LoadOutcome::Recovered(backup))
        }
    }
}

pub fn save(path: &Path, data: &AppData) -> io::Result<()> {
    let json = serde_json::to_string_pretty(&AppData {
        version: 1,
        ..data.clone()
    })
    .map_err(io::Error::other)?;
    write_atomic(path, &json)
}

/// Temp file + rename: a crash mid-write never leaves a half-written file.
pub fn write_atomic(path: &Path, text: &str) -> io::Result<()> {
    if let Some(dir) = path.parent() {
        fs::create_dir_all(dir)?;
    }
    let tmp = path.with_extension("tmp");
    fs::write(&tmp, text)?;
    fs::rename(&tmp, path)
}
