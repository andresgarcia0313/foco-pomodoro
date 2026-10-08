//! Time corrections: a frozen or starved process does not eat the phase, and people can add
//! or remove whole minutes from the phase in progress.

use super::{RunState, Timer};
use std::time::{Duration, Instant};

/// Ticks arrive every 250 ms; a longer gap than this means the app was not running (frozen,
/// stopped or starved), and that time is not counted, so the phase resumes where it was.
pub const STALL: Duration = Duration::from_secs(10);
/// Upper bound for a phase stretched with `adjust`.
pub const MAX_PHASE: Duration = Duration::from_secs(240 * 60);

impl Timer {
    /// Skips the time the process was not running; returns true when it did. Call it before
    /// every action from a caller that ticks regularly (the app does, every 250 ms).
    pub fn forgive_stall(&mut self, now: Instant) -> bool {
        if self.state != RunState::Running {
            return false;
        }
        let gap = self
            .last_seen
            .map_or(Duration::ZERO, |seen| now.saturating_duration_since(seen));
        self.last_seen = Some(now);
        let stalled = gap > STALL;
        if let (true, Some(start)) = (stalled, self.started_at.as_mut()) {
            *start += gap;
        }
        stalled
    }

    /// Adds (`minutes` > 0) or removes whole minutes from the current phase. Removing never
    /// leaves less than one second, so the phase still ends, and is counted, through `tick`.
    pub fn adjust(&mut self, now: Instant, minutes: i32) {
        let step = Duration::from_secs(60 * u64::from(minutes.unsigned_abs()));
        let floor = (self.elapsed(now) + Duration::from_secs(1)).min(self.total);
        self.total = if minutes >= 0 {
            (self.total + step).min(MAX_PHASE.max(self.total))
        } else {
            self.total.saturating_sub(step).max(floor)
        };
    }
}
