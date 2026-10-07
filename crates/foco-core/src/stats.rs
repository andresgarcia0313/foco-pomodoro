//! Focus history and the numbers shown in Statistics.

use chrono::{Datelike, Days, NaiveDate, NaiveDateTime};
use serde::{Deserialize, Serialize};

/// One completed focus block.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Session {
    pub ended_at: NaiveDateTime,
    pub minutes: u32,
    pub task: Option<String>,
}

impl Session {
    pub fn new(ended_at: NaiveDateTime, minutes: u32, task: Option<String>) -> Self {
        Self {
            ended_at,
            minutes,
            task,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct DayTotal {
    pub date: NaiveDate,
    /// Monday = 0 … Sunday = 6, for localized labels in the UI.
    pub weekday: u32,
    pub count: u32,
    pub minutes: u32,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
#[serde(default)]
pub struct History {
    sessions: Vec<Session>,
}

impl History {
    pub fn sessions(&self) -> &[Session] {
        &self.sessions
    }

    pub fn record(&mut self, session: Session) {
        self.sessions.push(session);
    }

    pub fn day_total(&self, date: NaiveDate) -> DayTotal {
        let (count, minutes) = self
            .sessions
            .iter()
            .filter(|s| s.ended_at.date() == date)
            .fold((0, 0), |(c, m), s| (c + 1, m + s.minutes));
        DayTotal {
            date,
            weekday: date.weekday().num_days_from_monday(),
            count,
            minutes,
        }
    }

    /// Seven days ending today, oldest first.
    pub fn week(&self, today: NaiveDate) -> Vec<DayTotal> {
        (0..7u64)
            .rev()
            .filter_map(|back| today.checked_sub_days(Days::new(back)))
            .map(|d| self.day_total(d))
            .collect()
    }

    /// Consecutive days with at least one focus, ending today (or yesterday if today is empty).
    pub fn streak(&self, today: NaiveDate) -> u32 {
        let active = |d: NaiveDate| self.sessions.iter().any(|s| s.ended_at.date() == d);
        let mut day = if active(today) {
            today
        } else {
            match today.pred_opt() {
                Some(d) => d,
                None => return 0,
            }
        };
        let mut streak = 0;
        while active(day) {
            streak += 1;
            match day.pred_opt() {
                Some(d) => day = d,
                None => break,
            }
        }
        streak
    }
}
