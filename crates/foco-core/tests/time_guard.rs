use foco_core::settings::Settings;
use foco_core::timer::{RunState, Timer, MAX_PHASE};
use foco_core::usage::Usage;
use std::time::{Duration, Instant};

fn secs(s: u64) -> Duration {
    Duration::from_secs(s)
}

/// Ticks once per second up to `until`, like the app does every 250 ms.
fn tick_until(t: &mut Timer, t0: Instant, until: u64) {
    for s in 1..=until {
        assert!(!t.forgive_stall(t0 + secs(s)));
        assert!(t.tick(t0 + secs(s)).is_none());
    }
}

fn running(t0: Instant) -> Timer {
    let mut t = Timer::new(&Settings::default());
    t.toggle(t0);
    t
}

#[test]
fn adjust_adds_and_removes_whole_minutes() {
    let t0 = Instant::now();
    let mut t = running(t0);
    t.adjust(t0, 1);
    assert_eq!(t.remaining(t0), secs(26 * 60));
    t.adjust(t0, -3);
    assert_eq!(t.remaining(t0), secs(23 * 60));
}

#[test]
fn adjust_never_leaves_less_than_a_second_nor_exceeds_the_cap() {
    let t0 = Instant::now();
    let mut t = running(t0);
    t.adjust(t0 + secs(24 * 60 + 30), -5);
    assert_eq!(t.remaining(t0 + secs(24 * 60 + 30)), secs(1));
    let mut idle = Timer::new(&Settings::default());
    idle.adjust(t0, 10_000);
    assert_eq!(idle.total(), MAX_PHASE);
}

#[test]
fn a_frozen_process_resumes_where_it_was() {
    let t0 = Instant::now();
    let mut t = running(t0);
    tick_until(&mut t, t0, 60);
    // Frozen for four hours: the phase must not end nor count.
    assert!(t.forgive_stall(t0 + secs(60 + 4 * 3600)));
    assert!(t.tick(t0 + secs(60 + 4 * 3600)).is_none());
    assert!(!t.forgive_stall(t0 + secs(61 + 4 * 3600)));
    assert_eq!(t.state(), RunState::Running);
    assert_eq!(t.remaining(t0 + secs(61 + 4 * 3600)), secs(25 * 60 - 61));
}

#[test]
fn regular_ticks_are_not_stalls() {
    let t0 = Instant::now();
    let mut t = running(t0);
    for s in 1..=30 {
        assert!(!t.forgive_stall(t0 + secs(s)));
    }
    assert_eq!(t.remaining(t0 + secs(30)), secs(25 * 60 - 30));
}

#[test]
fn an_adjusted_phase_survives_a_restart() {
    let t0 = Instant::now();
    let mut t = running(t0);
    t.adjust(t0, 10);
    let snap = t.snapshot(t0 + secs(60)).unwrap();
    let back = Timer::restore(&Settings::default(), snap, t0);
    assert_eq!(back.remaining(t0), secs(34 * 60));
    assert_eq!(back.total(), secs(35 * 60));
}

#[test]
fn usage_counts_per_day_and_stays_within_the_limit() {
    let mut u = Usage::default();
    let day = |d| chrono::NaiveDate::from_ymd_opt(2026, 10, d).unwrap();
    u.track(day(7), "start");
    u.track(day(8), "start");
    u.track(day(8), "start");
    assert_eq!(u.days["2026-10-08"]["start"], 2);
    let small = u.to_json_within(40);
    assert!(small.len() <= 40, "{small}");
    assert!(!u.days.contains_key("2026-10-07"));
}
