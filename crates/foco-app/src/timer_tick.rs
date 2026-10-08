//! Tick, phase completion and the property sync of `PomodoroTimer`.

use crate::{notify, store, timer_object::qobject::PomodoroTimer};
use core::pin::Pin;
use cxx_qt::Threading;
use foco_core::timer::{PhaseEnd, RunState};
use std::time::Instant;

impl PomodoroTimer {
    pub fn tick(mut self: Pin<&mut Self>) {
        if let Some(end) = store::with(|s| s.timer.tick(Instant::now())) {
            self.as_mut().complete(end);
        }
        self.sync();
    }

    fn complete(mut self: Pin<&mut Self>, end: PhaseEnd) {
        let message = store::with(|s| {
            if end.counted {
                s.record_focus();
            }
            s.save();
            let wanted = s.data.settings.notifications;
            wanted.then(|| notify::message(&end, &s.data.settings, s.timer.cycle_done()))
        });
        if let Some(message) = message {
            let qt = self.qt_thread();
            notify::show(message, move || {
                let _ = qt.queue(|timer| timer.toggle());
            });
        }
        let (finished, next) = (end.finished.index(), end.next.index());
        self.as_mut().phase_ended(finished, next, end.counted);
    }

    pub fn sync(mut self: Pin<&mut Self>) {
        let now = Instant::now();
        let view = store::with(|s| {
            let t = &s.timer;
            let state = match t.state() {
                RunState::Idle => 0,
                RunState::Running => 1,
                RunState::Paused => 2,
            };
            // Rounded up: a fresh phase shows 25:00 and 00:00 only appears at the very end.
            let left = t.remaining(now).as_millis().div_ceil(1000);
            (t.phase().index(), state, t.total().as_secs(), left, t.cycle_length(), t.cycle_done())
        });
        let to_i32 = |v: u128| i32::try_from(v).unwrap_or(i32::MAX);
        self.as_mut().set_phase(view.0);
        self.as_mut().set_state(view.1);
        self.as_mut().set_total_seconds(to_i32(view.2.into()));
        self.as_mut().set_remaining_seconds(to_i32(view.3));
        self.as_mut().set_cycle_length(to_i32(view.4.into()));
        self.as_mut().set_cycle_done(to_i32(view.5.into()));
    }
}
