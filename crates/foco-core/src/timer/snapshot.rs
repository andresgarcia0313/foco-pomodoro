//! Saving and restoring the phase in progress across restarts, crashes and freezes (RF-13).

use super::{Phase, RunState, Timer, MAX_PHASE};
use crate::settings::Settings;
use serde::{Deserialize, Serialize};
use std::time::{Duration, Instant};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub struct Snapshot {
    pub phase: Phase,
    pub remaining_secs: u64,
    pub cycle_done: u32,
    /// Phase length with adjustments; 0 in files written before adjustments existed.
    #[serde(default)]
    pub total_secs: u64,
    /// The phase was running, so it keeps running when the app comes back.
    #[serde(default)]
    pub running: bool,
}

impl Timer {
    /// Only a phase that has started or was adjusted is worth restoring.
    pub fn snapshot(&self, now: Instant) -> Option<Snapshot> {
        let touched = self.state != RunState::Idle
            || !self.elapsed_before.is_zero()
            || self.total != self.phase.duration(&self.settings);
        touched.then(|| Snapshot {
            phase: self.phase,
            remaining_secs: self.remaining(now).as_secs(),
            cycle_done: self.cycle_done,
            total_secs: self.total.as_secs(),
            running: self.state == RunState::Running,
        })
    }

    /// Restores the saved phase with the same time left. A running phase keeps running from
    /// there: the time the app was closed, crashed or frozen is never counted.
    pub fn restore(settings: &Settings, snap: Snapshot, now: Instant) -> Self {
        let mut timer = Timer::new(settings);
        timer.enter(snap.phase);
        timer.cycle_done = snap.cycle_done;
        if snap.total_secs > 0 {
            timer.total = Duration::from_secs(snap.total_secs).min(MAX_PHASE);
        }
        let remaining = Duration::from_secs(snap.remaining_secs).min(timer.total);
        timer.elapsed_before = timer.total - remaining;
        if !remaining.is_zero() {
            timer.state = RunState::Paused;
            if snap.running {
                timer.toggle(now);
            }
        }
        timer
    }
}
