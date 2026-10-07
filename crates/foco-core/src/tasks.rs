//! Tasks give a name to each focus block. Deliberately small: no projects, no due dates.

use serde::{Deserialize, Serialize};

mod undo;

pub const MAX_ESTIMATE: u32 = 12;

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Task {
    pub id: u64,
    pub title: String,
    pub estimate: u32,
    pub done: u32,
    pub completed: bool,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
#[serde(default)]
pub struct TaskList {
    items: Vec<Task>,
    next_id: u64,
    active: Option<u64>,
    #[serde(skip)]
    removed: Option<(usize, Task, bool)>,
}

impl TaskList {
    pub fn items(&self) -> &[Task] {
        &self.items
    }
    pub fn active(&self) -> Option<u64> {
        self.active
    }
    pub fn can_undo(&self) -> bool {
        self.removed.is_some()
    }
    pub fn get(&self, id: u64) -> Option<&Task> {
        self.items.iter().find(|t| t.id == id)
    }

    /// Adds a task; the first pending task becomes the active one.
    pub fn add(&mut self, title: &str, estimate: u32) -> Option<u64> {
        let title = title.trim();
        if title.is_empty() {
            return None;
        }
        self.next_id = self
            .next_id
            .max(self.items.iter().map(|t| t.id).max().unwrap_or(0))
            + 1;
        let id = self.next_id;
        let estimate = estimate.clamp(1, MAX_ESTIMATE);
        self.items.push(Task {
            id,
            title: title.to_owned(),
            estimate,
            done: 0,
            completed: false,
        });
        if self.active.is_none() {
            self.active = Some(id);
        }
        Some(id)
    }

    pub fn set_active(&mut self, id: u64) {
        if self.get(id).is_some_and(|t| !t.completed) {
            self.active = Some(id);
        }
    }

    pub fn toggle_completed(&mut self, id: u64) {
        let Some(task) = self.items.iter_mut().find(|t| t.id == id) else {
            return;
        };
        task.completed = !task.completed;
        if task.completed && self.active == Some(id) {
            self.active = None;
        }
    }

    /// A completed focus block counts for the active task.
    pub fn credit_focus(&mut self) {
        let active = self.active;
        if let Some(task) = self.items.iter_mut().find(|t| Some(t.id) == active) {
            task.done += 1;
        }
    }
}
