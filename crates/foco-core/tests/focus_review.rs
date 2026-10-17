use foco_core::{
    settings::Settings,
    stats::{History, Session},
    tasks::TaskList,
};

fn two_tasks() -> (TaskList, u64, u64) {
    let mut list = TaskList::default();
    let a = list.add("Propuesta", 2).unwrap();
    let b = list.add("Real", 2).unwrap();
    (list, a, b)
}

#[test]
fn recredit_moves_the_focus_to_the_task_really_worked_on() {
    let (mut list, a, b) = two_tasks();
    list.credit_focus();
    assert_eq!(list.recredit(b).as_deref(), Some("Real"));
    assert_eq!(list.get(a).unwrap().done, 0);
    assert_eq!(list.get(b).unwrap().done, 1);
    assert_eq!(list.active(), Some(b));
    // Asking again for the same task changes nothing.
    list.recredit(b);
    assert_eq!(list.get(b).unwrap().done, 1);
}

#[test]
fn confirming_the_proposed_task_keeps_the_credit() {
    let (mut list, a, _) = two_tasks();
    list.credit_focus();
    list.recredit(a);
    assert_eq!(list.get(a).unwrap().done, 1);
}

#[test]
fn a_focus_without_active_task_can_be_credited_later() {
    let mut list = TaskList::default();
    let a = list.add("A", 1).unwrap();
    list.toggle_completed(a);
    list.toggle_completed(a);
    assert_eq!(list.active(), None);
    list.credit_focus();
    list.recredit(a);
    assert_eq!(list.get(a).unwrap().done, 1);
}

#[test]
fn without_a_focus_or_with_an_unknown_task_nothing_moves() {
    let (mut list, a, b) = two_tasks();
    assert_eq!(list.recredit(b), None);
    list.credit_focus();
    assert_eq!(list.recredit(99), None);
    assert_eq!(list.get(a).unwrap().done, 1);
}

#[test]
fn history_takes_the_corrected_title() {
    let mut history = History::default();
    history.retitle_last("Nada".into()); // empty history: no panic
    let ended = chrono::NaiveDate::from_ymd_opt(2026, 10, 16)
        .unwrap()
        .and_hms_opt(10, 0, 0)
        .unwrap();
    history.record(Session::new(ended, 25, Some("Propuesta".into())));
    history.retitle_last("Real".into());
    assert_eq!(history.sessions()[0].task.as_deref(), Some("Real"));
}

#[test]
fn break_screen_is_on_by_default_and_old_files_get_it() {
    assert!(Settings::default().break_screen);
    let old: Settings = serde_json::from_str(r#"{"focus_minutes": 30}"#).unwrap();
    assert!(old.break_screen);
}
