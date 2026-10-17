//! Focus credit, correctable once: the break screen asks which task the last focus really went
//! to, since people often drift from the task they proposed.

use super::TaskList;

impl TaskList {
    /// A completed focus block counts for the active task.
    pub fn credit_focus(&mut self) {
        let active = self.active;
        if let Some(task) = self.items.iter_mut().find(|t| Some(t.id) == active) {
            task.done += 1;
        }
        self.last_credit = Some(active);
    }

    /// Moves the last focus credit to `to`, which also becomes the active task. Returns the
    /// title the focus now belongs to, or `None` when there is no focus or no such task.
    pub fn recredit(&mut self, to: u64) -> Option<String> {
        let from = self.last_credit?;
        let title = self.get(to)?.title.clone();
        if from != Some(to) {
            for task in self.items.iter_mut() {
                if Some(task.id) == from {
                    task.done = task.done.saturating_sub(1);
                } else if task.id == to {
                    task.done += 1;
                }
            }
            self.last_credit = Some(Some(to));
        }
        self.set_active(to);
        Some(title)
    }
}
