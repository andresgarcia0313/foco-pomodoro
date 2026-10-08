//! Pomodoro state machine. Time is read from an injected `Instant`, never counted in ticks,
//! so a late or skipped tick cannot make the clock drift.

use crate::settings::Settings;
use std::time::{Duration, Instant};

mod control;
mod guard;
mod phase;
mod snapshot;
pub use guard::{MAX_PHASE, STALL};
pub use phase::{Phase, PhaseEnd, RunState};
pub use snapshot::Snapshot;

#[derive(Debug, Clone)]
pub struct Timer {
    settings: Settings,
    phase: Phase,
    state: RunState,
    total: Duration,
    elapsed_before: Duration,
    started_at: Option<Instant>,
    /// Last moment the running phase was observed; see `forgive_stall`.
    last_seen: Option<Instant>,
    cycle_done: u32,
}

impl Timer {
    pub fn new(settings: &Settings) -> Self {
        let settings = settings.clone().sanitized();
        let total = Phase::Focus.duration(&settings);
        Self {
            settings,
            phase: Phase::Focus,
            state: RunState::Idle,
            total,
            elapsed_before: Duration::ZERO,
            started_at: None,
            last_seen: None,
            cycle_done: 0,
        }
    }

    pub fn phase(&self) -> Phase {
        self.phase
    }
    pub fn state(&self) -> RunState {
        self.state
    }
    pub fn total(&self) -> Duration {
        self.total
    }
    pub fn cycle_done(&self) -> u32 {
        self.cycle_done
    }
    pub fn cycle_length(&self) -> u32 {
        self.settings.long_break_every
    }

    pub fn elapsed(&self, now: Instant) -> Duration {
        let running = self
            .started_at
            .map_or(Duration::ZERO, |s| now.saturating_duration_since(s));
        (self.elapsed_before + running).min(self.total)
    }

    pub fn remaining(&self, now: Instant) -> Duration {
        self.total - self.elapsed(now)
    }
}
