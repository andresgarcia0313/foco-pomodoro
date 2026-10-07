//! User preferences with the defaults of the Pomodoro technique.

use serde::{Deserialize, Serialize};

/// Appearance choice; Dracula is the product identity, so it is the default.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize, Default)]
#[serde(rename_all = "snake_case")]
pub enum Appearance {
    #[default]
    Dracula,
    Alucard,
    System,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(default)]
pub struct Settings {
    pub focus_minutes: u32,
    pub short_break_minutes: u32,
    pub long_break_minutes: u32,
    pub long_break_every: u32,
    pub auto_start_breaks: bool,
    pub auto_start_focus: bool,
    pub notifications: bool,
    pub sound: bool,
    pub volume: f32,
    pub keep_in_tray: bool,
    pub always_on_top: bool,
    pub appearance: Appearance,
    /// Empty = follow the system language.
    pub language: String,
    pub reduce_motion: bool,
}

impl Default for Settings {
    fn default() -> Self {
        Self {
            focus_minutes: 25,
            short_break_minutes: 5,
            long_break_minutes: 15,
            long_break_every: 4,
            auto_start_breaks: false,
            auto_start_focus: false,
            notifications: true,
            sound: true,
            volume: 0.6,
            keep_in_tray: true,
            always_on_top: false,
            appearance: Appearance::Dracula,
            language: String::new(),
            reduce_motion: false,
        }
    }
}

impl Settings {
    /// Clamps values a hand-edited file could break (zero-length phases, volume out of range).
    pub fn sanitized(mut self) -> Self {
        self.focus_minutes = self.focus_minutes.clamp(1, 180);
        self.short_break_minutes = self.short_break_minutes.clamp(1, 60);
        self.long_break_minutes = self.long_break_minutes.clamp(1, 120);
        self.long_break_every = self.long_break_every.clamp(2, 12);
        self.volume = self.volume.clamp(0.0, 1.0);
        self
    }
}
