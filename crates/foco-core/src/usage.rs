//! Local usage counters that guide UI and UX decisions. They never leave the computer and the
//! file never grows past `MAX_BYTES`: the oldest days are dropped first.

use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;

pub const FILE_NAME: &str = "uso.json";
pub const MAX_BYTES: usize = 10 * 1024 * 1024;

/// Event counts per day, for example `{"2026-10-08": {"start": 3, "adjust+1": 5}}`.
#[derive(Debug, Clone, Default, PartialEq, Serialize, Deserialize)]
#[serde(default)]
pub struct Usage {
    pub days: BTreeMap<String, BTreeMap<String, u32>>,
}

impl Usage {
    /// A missing or damaged file just starts the counters again.
    pub fn from_json(text: &str) -> Self {
        serde_json::from_str(text).unwrap_or_default()
    }

    pub fn track(&mut self, day: chrono::NaiveDate, event: &str) {
        let day = self.days.entry(day.to_string()).or_default();
        let count = day.entry(event.to_owned()).or_default();
        *count = count.saturating_add(1);
    }

    /// The JSON text within `max` bytes, dropping the oldest days when needed.
    pub fn to_json_within(&mut self, max: usize) -> String {
        loop {
            let json = serde_json::to_string(self).unwrap_or_default();
            if json.len() <= max || self.days.pop_first().is_none() {
                return json;
            }
        }
    }
}
