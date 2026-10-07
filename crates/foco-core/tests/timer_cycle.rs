use foco_core::settings::Settings;
use foco_core::timer::{Phase, RunState, Timer};
use std::time::{Duration, Instant};

fn secs(s: u64) -> Duration {
    Duration::from_secs(s)
}

#[test]
fn starts_idle_in_focus_with_full_duration() {
    let t = Timer::new(&Settings::default());
    assert_eq!(t.phase(), Phase::Focus);
    assert_eq!(t.state(), RunState::Idle);
    assert_eq!(t.remaining(Instant::now()), secs(25 * 60));
}

#[test]
fn remaining_uses_monotonic_clock_not_ticks() {
    let t0 = Instant::now();
    let mut t = Timer::new(&Settings::default());
    t.toggle(t0);
    assert_eq!(t.remaining(t0 + secs(61)), secs(25 * 60 - 61));
}

#[test]
fn pause_freezes_and_resume_continues() {
    let t0 = Instant::now();
    let mut t = Timer::new(&Settings::default());
    t.toggle(t0);
    t.toggle(t0 + secs(100));
    assert_eq!(t.state(), RunState::Paused);
    assert_eq!(t.remaining(t0 + secs(500)), secs(1400));
    t.toggle(t0 + secs(500));
    assert_eq!(t.remaining(t0 + secs(510)), secs(1390));
}

#[test]
fn completed_focus_moves_to_short_break_and_counts() {
    let t0 = Instant::now();
    let mut t = Timer::new(&Settings::default());
    t.toggle(t0);
    let end = t.tick(t0 + secs(25 * 60)).expect("phase must end");
    assert_eq!(end.finished, Phase::Focus);
    assert_eq!(end.next, Phase::ShortBreak);
    assert!(end.counted);
    assert_eq!(t.cycle_done(), 1);
    assert_eq!(t.state(), RunState::Idle);
}

#[test]
fn fourth_focus_leads_to_long_break_then_cycle_resets() {
    let mut now = Instant::now();
    let mut t = Timer::new(&Settings::default());
    for _ in 0..4 {
        t.select_phase(Phase::Focus);
        t.toggle(now);
        now += secs(25 * 60);
        t.tick(now);
    }
    assert_eq!(t.phase(), Phase::LongBreak);
    assert_eq!(t.cycle_done(), 4);
    t.toggle(now);
    t.tick(now + secs(15 * 60));
    assert_eq!(t.phase(), Phase::Focus);
    assert_eq!(t.cycle_done(), 0);
}

#[test]
fn auto_start_breaks_keeps_running() {
    let t0 = Instant::now();
    let settings = Settings {
        auto_start_breaks: true,
        ..Settings::default()
    };
    let mut t = Timer::new(&settings);
    t.toggle(t0);
    let end = t.tick(t0 + secs(25 * 60 + 2)).unwrap();
    assert!(end.auto_started);
    assert_eq!(t.state(), RunState::Running);
    assert_eq!(t.remaining(t0 + secs(25 * 60 + 2)), secs(5 * 60));
}

#[test]
fn skip_does_not_count_focus_and_reset_restores_duration() {
    let t0 = Instant::now();
    let mut t = Timer::new(&Settings::default());
    t.toggle(t0);
    let end = t.skip(t0 + secs(30));
    assert!(!end.counted);
    assert_eq!(t.cycle_done(), 0);
    assert_eq!(t.phase(), Phase::ShortBreak);
    t.toggle(t0 + secs(40));
    t.reset();
    assert_eq!(t.state(), RunState::Idle);
    assert_eq!(t.remaining(t0 + secs(99)), secs(5 * 60));
}

#[test]
fn new_durations_apply_to_untouched_idle_phase() {
    let mut t = Timer::new(&Settings::default());
    t.apply(&Settings {
        focus_minutes: 50,
        ..Settings::default()
    });
    assert_eq!(t.total(), secs(50 * 60));
}

#[test]
fn skipping_long_break_also_restarts_the_cycle() {
    let mut t = Timer::new(&Settings::default());
    t.select_phase(Phase::LongBreak);
    t.skip(Instant::now());
    assert_eq!(t.cycle_done(), 0);
    assert_eq!(t.phase(), Phase::Focus);
}

#[test]
fn lowering_long_break_interval_never_traps_the_cycle() {
    let mut now = Instant::now();
    let mut t = Timer::new(&Settings::default());
    for _ in 0..3 {
        t.select_phase(Phase::Focus);
        t.toggle(now);
        now += secs(25 * 60);
        t.tick(now);
    }
    t.apply(&Settings {
        long_break_every: 2,
        ..Settings::default()
    });
    t.select_phase(Phase::Focus);
    t.toggle(now);
    t.tick(now + secs(25 * 60));
    assert_eq!(t.phase(), Phase::LongBreak);
}
