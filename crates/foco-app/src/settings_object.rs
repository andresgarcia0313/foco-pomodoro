//! `AppSettings`: every preference as a QML property. Any change is applied and saved at once
//! (there is no Save button); `applied` tells the timer to pick up new durations.

#[cxx_qt::bridge]
pub mod qobject {
    extern "RustQt" {
        #[qobject]
        #[qml_element]
        #[qproperty(i32, focus_minutes, cxx_name = "focusMinutes")]
        #[qproperty(i32, short_break_minutes, cxx_name = "shortBreakMinutes")]
        #[qproperty(i32, long_break_minutes, cxx_name = "longBreakMinutes")]
        #[qproperty(i32, long_break_every, cxx_name = "longBreakEvery")]
        #[qproperty(bool, auto_start_breaks, cxx_name = "autoStartBreaks")]
        #[qproperty(bool, auto_start_focus, cxx_name = "autoStartFocus")]
        #[qproperty(bool, notifications)]
        #[qproperty(bool, sound)]
        #[qproperty(f64, volume)]
        #[qproperty(bool, keep_in_tray, cxx_name = "keepInTray")]
        #[qproperty(bool, always_on_top, cxx_name = "alwaysOnTop")]
        #[qproperty(i32, appearance)]
        #[qproperty(i32, language_index, cxx_name = "languageIndex")]
        #[qproperty(bool, reduce_motion, cxx_name = "reduceMotion")]
        type AppSettings = super::SettingsRust;

        #[qsignal]
        fn applied(self: Pin<&mut AppSettings>);
    }

    impl cxx_qt::Initialize for AppSettings {}
}

#[derive(Default)]
pub struct SettingsRust {
    pub(crate) focus_minutes: i32,
    pub(crate) short_break_minutes: i32,
    pub(crate) long_break_minutes: i32,
    pub(crate) long_break_every: i32,
    pub(crate) auto_start_breaks: bool,
    pub(crate) auto_start_focus: bool,
    pub(crate) notifications: bool,
    pub(crate) sound: bool,
    pub(crate) volume: f64,
    pub(crate) keep_in_tray: bool,
    pub(crate) always_on_top: bool,
    pub(crate) appearance: i32,
    pub(crate) language_index: i32,
    pub(crate) reduce_motion: bool,
}
