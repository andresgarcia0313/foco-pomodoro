//! Loads `AppSettings` from the store and writes every change back to it.

use crate::{
    settings_object::{qobject::AppSettings, SettingsRust},
    store,
};
use core::pin::Pin;
use cxx_qt::CxxQtType;
use foco_core::settings::{Appearance, Settings};

const LANGUAGES: [&str; 3] = ["", "es", "en"];

impl cxx_qt::Initialize for AppSettings {
    fn initialize(mut self: Pin<&mut Self>) {
        let loaded = store::with(|s| SettingsRust::from(&s.data.settings));
        *self.as_mut().rust_mut().get_mut() = loaded;
        macro_rules! commit_on {
            ($($signal:ident),+) => {
                $( let _ = self.as_mut().$signal(|o| o.commit()).release(); )+
            };
        }
        commit_on!(
            on_focus_minutes_changed,
            on_short_break_minutes_changed,
            on_long_break_minutes_changed,
            on_long_break_every_changed,
            on_auto_start_breaks_changed,
            on_auto_start_focus_changed,
            on_notifications_changed,
            on_sound_changed,
            on_volume_changed,
            on_keep_in_tray_changed,
            on_always_on_top_changed,
            on_appearance_changed,
            on_language_index_changed,
            on_reduce_motion_changed
        );
    }
}

impl AppSettings {
    fn commit(mut self: Pin<&mut Self>) {
        let settings = self.rust().to_core();
        store::with(|s| {
            s.data.settings = settings.sanitized();
            s.timer.apply(&s.data.settings);
            s.save();
        });
        self.as_mut().applied();
    }
}

impl From<&Settings> for SettingsRust {
    fn from(s: &Settings) -> Self {
        let minutes = |m: u32| i32::try_from(m).unwrap_or(i32::MAX);
        Self {
            focus_minutes: minutes(s.focus_minutes),
            short_break_minutes: minutes(s.short_break_minutes),
            long_break_minutes: minutes(s.long_break_minutes),
            long_break_every: minutes(s.long_break_every),
            auto_start_breaks: s.auto_start_breaks,
            auto_start_focus: s.auto_start_focus,
            notifications: s.notifications,
            sound: s.sound,
            volume: f64::from(s.volume),
            keep_in_tray: s.keep_in_tray,
            always_on_top: s.always_on_top,
            appearance: s.appearance as i32,
            language_index: LANGUAGES.iter().position(|l| *l == s.language).unwrap_or(0) as i32,
            reduce_motion: s.reduce_motion,
        }
    }
}

impl SettingsRust {
    fn to_core(&self) -> Settings {
        let minutes = |m: i32| u32::try_from(m).unwrap_or(0);
        Settings {
            focus_minutes: minutes(self.focus_minutes),
            short_break_minutes: minutes(self.short_break_minutes),
            long_break_minutes: minutes(self.long_break_minutes),
            long_break_every: minutes(self.long_break_every),
            auto_start_breaks: self.auto_start_breaks,
            auto_start_focus: self.auto_start_focus,
            notifications: self.notifications,
            sound: self.sound,
            volume: self.volume as f32,
            keep_in_tray: self.keep_in_tray,
            always_on_top: self.always_on_top,
            appearance: match self.appearance {
                1 => Appearance::Alucard,
                2 => Appearance::System,
                _ => Appearance::Dracula,
            },
            language: LANGUAGES.get(self.language_index as usize).unwrap_or(&"").to_string(),
            reduce_motion: self.reduce_motion,
        }
    }
}
