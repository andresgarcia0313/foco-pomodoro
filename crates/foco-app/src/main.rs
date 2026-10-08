//! Foco: Pomodoro timer for the desktop. Rust owns the state; QML draws it.
// No console window behind the app on Windows.
#![cfg_attr(windows, windows_subsystem = "windows")]

mod kwin;
mod notify;
mod qvariant;
mod services_object;
mod settings_object;
mod settings_sync;
mod stats_object;
mod store;
mod supervisor;
mod tasks_actions;
// `newRequested` is emitted from QML only, so Rust never calls its generated method.
#[allow(dead_code)]
mod tasks_object;
mod timer_object;
mod timer_tick;

use std::ffi::{c_char, c_int, CString};

// src/app_shim.cpp: QApplication, Basic style and the QML engine.
unsafe extern "C" {
    fn foco_app_new(argc: c_int, argv: *mut *mut c_char);
    fn foco_app_run() -> c_int;
}

fn main() {
    if let Some(code) = supervisor::run() {
        std::process::exit(code);
    }
    store::init();
    store::with(|s| {
        s.track(if supervisor::restarted() {
            "crash_restart"
        } else {
            "launch"
        });
        s.save();
    });

    // Qt keeps pointers to argv for the whole run, so these live until main returns.
    let args: Vec<CString> = std::env::args()
        .map(|a| CString::new(a).unwrap_or_default())
        .collect();
    let mut argv: Vec<*mut c_char> = args.iter().map(|a| a.as_ptr().cast_mut()).collect();
    argv.push(std::ptr::null_mut());
    let argc = c_int::try_from(args.len()).unwrap_or(1);

    // SAFETY: argv is null-terminated and outlives the application object.
    unsafe { foco_app_new(argc, argv.as_mut_ptr()) };
    cxx_qt::init_qml_module!("FocoApp");
    // SAFETY: called once, on the main thread, after foco_app_new.
    let code = unsafe { foco_app_run() };

    store::with(|s| s.save());
    std::process::exit(code);
}
