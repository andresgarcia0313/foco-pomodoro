use foco_core::export::history_csv;
use foco_core::settings::Settings;
use foco_core::stats::{History, Session};
use foco_core::storage::{load, save, AppData, LoadOutcome};
use foco_core::timer::{Phase, RunState, Timer};
use std::time::{Duration, Instant};

#[test]
fn missing_file_starts_fresh_and_roundtrip_keeps_data() {
    let dir = tempfile::tempdir().unwrap();
    let path = dir.path().join("sub/foco.json");
    let (mut data, outcome) = load(&path);
    assert!(matches!(outcome, LoadOutcome::Fresh));
    data.tasks.add("Informe", 2);
    data.settings.focus_minutes = 40;
    save(&path, &data).unwrap();
    let (back, outcome) = load(&path);
    assert!(matches!(outcome, LoadOutcome::Loaded));
    assert_eq!(back.settings.focus_minutes, 40);
    assert_eq!(back.tasks.items()[0].title, "Informe");
}

#[test]
fn corrupt_file_is_backed_up_and_never_blocks() {
    let dir = tempfile::tempdir().unwrap();
    let path = dir.path().join("foco.json");
    std::fs::write(&path, "{ esto no es json").unwrap();
    let (data, outcome) = load(&path);
    let LoadOutcome::Recovered(backup) = outcome else {
        panic!("expected recovery")
    };
    assert!(backup.exists());
    assert!(!path.exists());
    assert_eq!(data.settings, Settings::default());
}

#[test]
fn unknown_or_missing_fields_fall_back_to_defaults() {
    let dir = tempfile::tempdir().unwrap();
    let path = dir.path().join("foco.json");
    std::fs::write(&path, r#"{"settings":{"focus_minutes":0},"future":true}"#).unwrap();
    let (data, _) = load(&path);
    assert_eq!(data.settings.focus_minutes, 1); // sanitized, never a zero-length phase
    assert_eq!(data.settings.short_break_minutes, 5);
    let _ = AppData::default();
}

#[test]
fn snapshot_restores_paused_with_same_remaining_time() {
    let t0 = Instant::now();
    let mut t = Timer::new(&Settings::default());
    t.toggle(t0);
    let snap = t.snapshot(t0 + Duration::from_secs(600)).unwrap();
    let back = Timer::restore(&Settings::default(), snap);
    assert_eq!(back.phase(), Phase::Focus);
    assert_eq!(back.state(), RunState::Paused);
    assert_eq!(back.remaining(Instant::now()), Duration::from_secs(900));
    assert!(Timer::new(&Settings::default()).snapshot(t0).is_none());
}

#[test]
fn csv_quotes_commas_and_quotes() {
    let mut h = History::default();
    let at = chrono::NaiveDate::from_ymd_opt(2026, 10, 7)
        .unwrap()
        .and_hms_opt(9, 30, 0)
        .unwrap();
    h.record(Session::new(at, 25, Some("Leer \"Rust\", cap. 5".into())));
    assert_eq!(
        history_csv(&h),
        "ended_at,minutes,task\n2026-10-07 09:30:00,25,\"Leer \"\"Rust\"\", cap. 5\"\n"
    );
}
