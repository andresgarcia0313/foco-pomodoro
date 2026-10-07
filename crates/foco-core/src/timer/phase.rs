use crate::settings::Settings;
use serde::{Deserialize, Serialize};
use std::time::Duration;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum Phase {
    Focus,
    ShortBreak,
    LongBreak,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum RunState {
    Idle,
    Running,
    Paused,
}

/// What happened when a phase ended, so the UI can notify and the stats can record.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct PhaseEnd {
    pub finished: Phase,
    pub next: Phase,
    /// A completed focus block: it adds to the cycle, the active task and the history.
    pub counted: bool,
    pub auto_started: bool,
}

impl Phase {
    pub fn index(self) -> i32 {
        self as i32
    }

    pub fn from_index(index: i32) -> Self {
        match index {
            1 => Self::ShortBreak,
            2 => Self::LongBreak,
            _ => Self::Focus,
        }
    }

    pub fn duration(self, s: &Settings) -> Duration {
        let minutes = match self {
            Self::Focus => s.focus_minutes,
            Self::ShortBreak => s.short_break_minutes,
            Self::LongBreak => s.long_break_minutes,
        };
        Duration::from_secs(u64::from(minutes) * 60)
    }

    pub(super) fn next(self, cycle_done: u32, long_every: u32) -> Self {
        match self {
            Self::Focus if cycle_done >= long_every => Self::LongBreak,
            Self::Focus => Self::ShortBreak,
            Self::ShortBreak | Self::LongBreak => Self::Focus,
        }
    }

    pub(super) fn auto_starts(self, s: &Settings) -> bool {
        match self {
            Self::Focus => s.auto_start_focus,
            Self::ShortBreak | Self::LongBreak => s.auto_start_breaks,
        }
    }
}
