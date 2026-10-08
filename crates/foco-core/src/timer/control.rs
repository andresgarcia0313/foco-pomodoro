//! Transitions of the state machine: start, pause, tick, skip, reset and new settings.

use super::{Phase, PhaseEnd, RunState, Timer};
use crate::settings::Settings;
use std::time::{Duration, Instant};

impl Timer {
    /// Start, pause or resume, like the primary button.
    pub fn toggle(&mut self, now: Instant) {
        match self.state {
            RunState::Running => {
                self.elapsed_before = self.elapsed(now);
                self.started_at = None;
                self.state = RunState::Paused;
            }
            RunState::Idle | RunState::Paused => {
                self.started_at = Some(now);
                self.last_seen = Some(now);
                self.state = RunState::Running;
            }
        }
    }

    /// Returns the end of the phase when the time is up; call it about once per second.
    pub fn tick(&mut self, now: Instant) -> Option<PhaseEnd> {
        (self.state == RunState::Running && self.remaining(now).is_zero())
            .then(|| self.advance(now, true))
    }

    /// Moves to the next phase without counting the current one.
    pub fn skip(&mut self, now: Instant) -> PhaseEnd {
        self.advance(now, false)
    }

    /// Back to the full duration of the current phase, stopped.
    pub fn reset(&mut self) {
        self.enter(self.phase)
    }

    pub fn select_phase(&mut self, phase: Phase) {
        self.enter(phase)
    }

    /// New preferences; the current phase changes length only if it has not started.
    pub fn apply(&mut self, settings: &Settings) {
        self.settings = settings.clone().sanitized();
        if self.state == RunState::Idle && self.elapsed_before.is_zero() {
            self.total = self.phase.duration(&self.settings);
        }
    }

    fn advance(&mut self, now: Instant, completed: bool) -> PhaseEnd {
        let finished = self.phase;
        let minutes = u32::try_from((self.total.as_secs() + 30) / 60).unwrap_or(u32::MAX);
        let counted = completed && finished == Phase::Focus;
        if counted {
            self.cycle_done += 1;
        }
        if finished == Phase::LongBreak {
            self.cycle_done = 0;
        }
        let next = finished.next(self.cycle_done, self.settings.long_break_every);
        self.enter(next);
        let auto_started = completed && next.auto_starts(&self.settings);
        if auto_started {
            self.toggle(now);
        }
        PhaseEnd {
            finished,
            next,
            counted,
            auto_started,
            minutes,
        }
    }

    pub(super) fn enter(&mut self, phase: Phase) {
        self.phase = phase;
        self.state = RunState::Idle;
        self.total = phase.duration(&self.settings);
        self.elapsed_before = Duration::ZERO;
        self.started_at = None;
        self.last_seen = None;
    }
}
