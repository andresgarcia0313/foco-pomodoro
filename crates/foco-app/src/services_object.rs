//! `AppServices`: what QML needs besides the domain objects: usage counters, keeping a window
//! above the others, the supervisor heartbeat and the file for the interface's own state.

use crate::{kwin, store, supervisor};
use core::pin::Pin;
use cxx_qt_lib::{QString, QUrl};

#[cxx_qt::bridge]
pub mod qobject {
    unsafe extern "C++" {
        include!("cxx-qt-lib/qstring.h");
        type QString = cxx_qt_lib::QString;
        include!("cxx-qt-lib/qurl.h");
        type QUrl = cxx_qt_lib::QUrl;
    }

    extern "RustQt" {
        #[qobject]
        #[qml_element]
        /// Window size and mini mode, kept by QtCore's `Settings` next to `foco.json`.
        #[qproperty(QUrl, state_file, cxx_name = "stateFile")]
        type AppServices = super::ServicesRust;

        #[qinvokable]
        fn track(self: &AppServices, event: &QString);
        /// Qt's stay-on-top hint is ignored on Wayland; on KDE this asks KWin instead.
        #[qinvokable]
        #[cxx_name = "keepAbove"]
        fn keep_above(self: &AppServices, title: &QString, on: bool);
        /// The event loop is alive; the supervisor restarts the app when beats stop.
        #[qinvokable]
        fn beat(self: &AppServices);
    }

    impl cxx_qt::Initialize for AppServices {}
}

#[derive(Default)]
pub struct ServicesRust {
    state_file: QUrl,
}

impl cxx_qt::Initialize for qobject::AppServices {
    fn initialize(self: Pin<&mut Self>) {
        let path = store::config_dir().join("interfaz.ini");
        let path = path.to_string_lossy().replace('\\', "/");
        let slash = if path.starts_with('/') { "" } else { "/" };
        self.set_state_file(QUrl::from(format!("file://{slash}{path}").as_str()));
    }
}

impl qobject::AppServices {
    pub fn track(&self, event: &QString) {
        store::with(|s| s.track(&event.to_string()));
    }

    pub fn keep_above(&self, title: &QString, on: bool) {
        kwin::keep_above(title.to_string(), on);
    }

    pub fn beat(&self) {
        supervisor::beat();
    }
}
