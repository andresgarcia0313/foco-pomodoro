//! `PomodoroTimer`: the QML face of `foco_core::timer::Timer`. The remaining time always comes
//! from the monotonic clock; QML only asks for a `tick()` while the phase runs.

use crate::store;
use core::pin::Pin;
use foco_core::timer::{Phase, RunState, Timer};
use std::time::Instant;

#[cxx_qt::bridge]
pub mod qobject {
    extern "RustQt" {
        #[qobject]
        #[qml_element]
        #[qproperty(i32, phase)]
        #[qproperty(i32, state)]
        #[qproperty(i32, total_seconds, cxx_name = "totalSeconds")]
        #[qproperty(i32, remaining_seconds, cxx_name = "remainingSeconds")]
        #[qproperty(i32, cycle_length, cxx_name = "cycleLength")]
        #[qproperty(i32, cycle_done, cxx_name = "cycleDone")]
        type PomodoroTimer = super::TimerRust;

        /// A phase reached zero; `counted` is true when a focus was completed.
        #[qsignal]
        #[cxx_name = "phaseEnded"]
        fn phase_ended(self: Pin<&mut PomodoroTimer>, finished: i32, next: i32, counted: bool);

        #[qinvokable]
        fn toggle(self: Pin<&mut PomodoroTimer>);
        #[qinvokable]
        fn reset(self: Pin<&mut PomodoroTimer>);
        #[qinvokable]
        fn skip(self: Pin<&mut PomodoroTimer>);
        #[qinvokable]
        #[cxx_name = "selectPhase"]
        fn select_phase(self: Pin<&mut PomodoroTimer>, phase: i32);
        /// Adds or removes whole minutes from the phase in progress.
        #[qinvokable]
        fn adjust(self: Pin<&mut PomodoroTimer>, minutes: i32);
        #[qinvokable]
        fn tick(self: Pin<&mut PomodoroTimer>);
        #[qinvokable]
        fn sync(self: Pin<&mut PomodoroTimer>);
    }

    impl cxx_qt::Threading for PomodoroTimer {}
    impl cxx_qt::Initialize for PomodoroTimer {}
}

#[derive(Default)]
pub struct TimerRust {
    phase: i32,
    state: i32,
    total_seconds: i32,
    remaining_seconds: i32,
    cycle_length: i32,
    cycle_done: i32,
}

impl cxx_qt::Initialize for qobject::PomodoroTimer {
    fn initialize(self: Pin<&mut Self>) {
        self.sync();
    }
}

impl qobject::PomodoroTimer {
    /// Every action skips a stall first, applies the change, counts it and saves at once.
    fn act(self: Pin<&mut Self>, event: &str, change: impl FnOnce(&mut Timer, Instant)) {
        store::with(|s| {
            let now = Instant::now();
            if s.timer.forgive_stall(now) {
                s.track("stall");
            }
            change(&mut s.timer, now);
            s.track(event);
            s.save();
        });
        self.sync();
    }

    pub fn toggle(self: Pin<&mut Self>) {
        let running = store::with(|s| s.timer.state() == RunState::Running);
        self.act(if running { "pause" } else { "start" }, Timer::toggle);
    }

    pub fn reset(self: Pin<&mut Self>) {
        self.act("reset", |t, _| t.reset());
    }

    /// Skipping never counts the focus and never notifies.
    pub fn skip(self: Pin<&mut Self>) {
        self.act("skip", |t, now| {
            t.skip(now);
        });
    }

    pub fn select_phase(self: Pin<&mut Self>, phase: i32) {
        self.act("select_phase", |t, _| {
            t.select_phase(Phase::from_index(phase))
        });
    }

    pub fn adjust(self: Pin<&mut Self>, minutes: i32) {
        let event = if minutes > 0 { "adjust+" } else { "adjust-" };
        self.act(event, |t, now| t.adjust(now, minutes));
    }
}
