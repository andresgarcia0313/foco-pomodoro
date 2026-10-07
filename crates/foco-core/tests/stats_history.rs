use chrono::NaiveDate;
use foco_core::stats::{History, Session};

fn day(d: u32) -> NaiveDate {
    NaiveDate::from_ymd_opt(2026, 10, d).unwrap()
}

fn history(days: &[(u32, u32)]) -> History {
    let mut h = History::default();
    for &(d, n) in days {
        for _ in 0..n {
            h.record(Session::new(
                day(d).and_hms_opt(10, 0, 0).unwrap(),
                25,
                None,
            ));
        }
    }
    h
}

#[test]
fn today_counts_focus_sessions_and_minutes() {
    let h = history(&[(6, 2), (7, 3)]);
    let today = h.day_total(day(7));
    assert_eq!((today.count, today.minutes), (3, 75));
}

#[test]
fn streak_counts_consecutive_days_ending_today_or_yesterday() {
    let h = history(&[(3, 1), (5, 1), (6, 2), (7, 1)]);
    assert_eq!(h.streak(day(7)), 3);
    // Nothing yet today: the streak from yesterday still stands.
    assert_eq!(h.streak(day(8)), 3);
    assert_eq!(h.streak(day(10)), 0);
}

#[test]
fn week_has_seven_days_ending_today_with_weekday_index() {
    let h = history(&[(1, 1), (7, 2)]);
    let week = h.week(day(7));
    assert_eq!(week.len(), 7);
    assert_eq!(week[6].date, day(7));
    assert_eq!(week[6].weekday, 2); // 2026-10-07 is a Wednesday (Monday = 0)
    assert_eq!(week[0].date, day(1));
    assert_eq!(week[0].count, 1);
    assert_eq!(week.iter().map(|d| d.count).sum::<u32>(), 3);
}
