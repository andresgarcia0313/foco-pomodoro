//! `PomodoroTimer`: the QML face of `foco_core::timer::Timer`. The remaining time always comes
//! from the monotonic clock; QML only asks for a `tick()` while the phase runs.

use crate::store;
use core::pin::Pin;
use foco_core::timer::{Phase, Timer};
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
    fn act(self: Pin<&mut Self>, change: impl FnOnce(&mut Timer)) {
        store::with(|s| {
            change(&mut s.timer);
            s.save();
        });
        self.sync();
    }

    pub fn toggle(self: Pin<&mut Self>) {
        self.act(|t| t.toggle(Instant::now()));
    }

    pub fn reset(self: Pin<&mut Self>) {
        self.act(Timer::reset);
    }

    /// Skipping never counts the focus and never notifies.
    pub fn skip(self: Pin<&mut Self>) {
        self.act(|t| {
            t.skip(Instant::now());
        });
    }

    pub fn select_phase(self: Pin<&mut Self>, phase: i32) {
        self.act(|t| t.select_phase(Phase::from_index(phase)));
    }
}
