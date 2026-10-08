//! Edits and the property refresh of `TaskStore`; every edit is saved at once.

use crate::{qvariant as qv, store, tasks_object::qobject::TaskStore};
use core::pin::Pin;
use cxx_qt_lib::QString;
use foco_core::tasks::TaskList;

impl TaskStore {
    fn change(self: Pin<&mut Self>, edit: impl FnOnce(&mut TaskList)) {
        store::with(|s| {
            edit(&mut s.data.tasks);
            s.save();
        });
        self.refresh();
    }

    pub fn add(self: Pin<&mut Self>, title: &QString, estimate: i32) {
        let estimate = u32::try_from(estimate).unwrap_or(1);
        self.change(|t| {
            t.add(&title.to_string(), estimate);
        });
    }

    pub fn toggle_completed(self: Pin<&mut Self>, id: i32) {
        self.change(|t| t.toggle_completed(id as u64));
    }

    pub fn remove(self: Pin<&mut Self>, id: i32) {
        self.change(|t| {
            t.remove(id as u64);
        });
    }

    pub fn undo_remove(self: Pin<&mut Self>) {
        self.change(TaskList::undo_remove);
    }

    pub fn commit_remove(self: Pin<&mut Self>) {
        self.change(TaskList::commit_remove);
    }

    pub fn set_active(self: Pin<&mut Self>, id: i32) {
        self.change(|t| t.set_active(id as u64));
    }

    pub fn refresh(mut self: Pin<&mut Self>) {
        let (items, active, undo) = store::with(|s| {
            let t = &s.data.tasks;
            let items = qv::array(t.items().iter().map(|task| {
                qv::object([
                    ("id", qv::int(task.id)),
                    ("title", qv::text(&task.title)),
                    ("estimate", qv::int(task.estimate)),
                    ("done", qv::int(task.done)),
                    ("completed", qv::flag(task.completed)),
                ])
            }));
            (items, t.active().map_or(0, |id| id as i32), t.can_undo())
        });
        self.as_mut().set_items(items);
        self.as_mut().set_active_id(active);
        self.as_mut().set_can_undo(undo);
    }
}
