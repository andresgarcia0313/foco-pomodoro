//! Delete with a single undo, as offered by the "Tarea eliminada · Deshacer" toast.

use super::TaskList;

impl TaskList {
    /// Removes a task, keeping it for one undo.
    pub fn remove(&mut self, id: u64) -> bool {
        let Some(index) = self.items.iter().position(|t| t.id == id) else {
            return false;
        };
        let was_active = self.active == Some(id);
        if was_active {
            self.active = None;
        }
        self.removed = Some((index, self.items.remove(index), was_active));
        true
    }

    pub fn undo_remove(&mut self) {
        let Some((index, task, was_active)) = self.removed.take() else {
            return;
        };
        if was_active {
            self.active = Some(task.id);
        }
        self.items.insert(index.min(self.items.len()), task);
    }

    /// Forgets the pending undo (the toast expired).
    pub fn commit_remove(&mut self) {
        self.removed = None;
    }
}
