//! Saving and restoring the phase in progress across app restarts (RF-13).

use super::{Phase, RunState, Timer};
use crate::settings::Settings;
use serde::{Deserialize, Serialize};
use std::time::{Duration, Instant};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub struct Snapshot {
    pub phase: Phase,
    pub remaining_secs: u64,
    pub cycle_done: u32,
}

impl Timer {
    /// Only a phase that has started is worth restoring.
    pub fn snapshot(&self, now: Instant) -> Option<Snapshot> {
        (self.state != RunState::Idle || !self.elapsed_before.is_zero()).then(|| Snapshot {
            phase: self.phase,
            remaining_secs: self.remaining(now).as_secs(),
            cycle_done: self.cycle_done,
        })
    }

    /// Restores a saved phase as paused, so time spent with the app closed is not counted.
    pub fn restore(settings: &Settings, snap: Snapshot) -> Self {
        let mut timer = Timer::new(settings);
        timer.enter(snap.phase);
        timer.cycle_done = snap.cycle_done;
        let remaining = Duration::from_secs(snap.remaining_secs).min(timer.total);
        timer.elapsed_before = timer.total - remaining;
        timer.state = if remaining.is_zero() {
            RunState::Idle
        } else {
            RunState::Paused
        };
        timer
    }
}
