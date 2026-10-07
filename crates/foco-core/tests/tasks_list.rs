use foco_core::tasks::TaskList;

#[test]
fn add_trims_and_rejects_empty_titles() {
    let mut list = TaskList::default();
    assert!(list.add("   ", 1).is_none());
    let id = list.add("  Escribir informe ", 3).unwrap();
    assert_eq!(list.get(id).unwrap().title, "Escribir informe");
    assert_eq!(list.get(id).unwrap().estimate, 3);
}

#[test]
fn first_task_becomes_active_and_receives_focus_credit() {
    let mut list = TaskList::default();
    let id = list.add("A", 2).unwrap();
    assert_eq!(list.active(), Some(id));
    list.credit_focus();
    assert_eq!(list.get(id).unwrap().done, 1);
}

#[test]
fn completing_the_active_task_clears_it() {
    let mut list = TaskList::default();
    let a = list.add("A", 1).unwrap();
    list.toggle_completed(a);
    assert!(list.get(a).unwrap().completed);
    assert_eq!(list.active(), None);
    list.credit_focus(); // no active task: nothing to credit, no panic
}

#[test]
fn remove_then_undo_restores_position_and_active() {
    let mut list = TaskList::default();
    let a = list.add("A", 1).unwrap();
    let b = list.add("B", 1).unwrap();
    list.set_active(b);
    assert!(list.remove(b));
    assert!(list.can_undo());
    assert_eq!(list.active(), None);
    list.undo_remove();
    assert_eq!(
        list.items().iter().map(|t| t.id).collect::<Vec<_>>(),
        vec![a, b]
    );
    assert_eq!(list.active(), Some(b));
    assert!(!list.can_undo());
}

#[test]
fn estimate_is_clamped_and_ids_are_unique() {
    let mut list = TaskList::default();
    let a = list.add("A", 0).unwrap();
    let b = list.add("B", 99).unwrap();
    assert_ne!(a, b);
    assert_eq!(list.get(a).unwrap().estimate, 1);
    assert_eq!(list.get(b).unwrap().estimate, 12);
}
