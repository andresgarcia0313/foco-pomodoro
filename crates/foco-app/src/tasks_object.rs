//! `TaskStore`: the task list for QML, as an array of plain objects plus the active task.

use core::pin::Pin;
use cxx_qt_lib::QVariant;

#[cxx_qt::bridge]
pub mod qobject {
    unsafe extern "C++" {
        include!("cxx-qt-lib/qstring.h");
        type QString = cxx_qt_lib::QString;
        include!("cxx-qt-lib/qvariant.h");
        type QVariant = cxx_qt_lib::QVariant;
    }

    extern "RustQt" {
        #[qobject]
        #[qml_element]
        #[qproperty(QVariant, items)]
        #[qproperty(i32, active_id, cxx_name = "activeId")]
        #[qproperty(bool, can_undo, cxx_name = "canUndo")]
        type TaskStore = super::TasksRust;

        /// Ctrl+N: the tasks view focuses its input.
        #[qsignal]
        #[cxx_name = "newRequested"]
        fn new_requested(self: Pin<&mut TaskStore>);

        #[qinvokable]
        fn add(self: Pin<&mut TaskStore>, title: &QString, estimate: i32);
        #[qinvokable]
        #[cxx_name = "toggleCompleted"]
        fn toggle_completed(self: Pin<&mut TaskStore>, id: i32);
        #[qinvokable]
        fn remove(self: Pin<&mut TaskStore>, id: i32);
        #[qinvokable]
        #[cxx_name = "undoRemove"]
        fn undo_remove(self: Pin<&mut TaskStore>);
        /// The undo window closed: forget the removed task.
        #[qinvokable]
        #[cxx_name = "commitRemove"]
        fn commit_remove(self: Pin<&mut TaskStore>);
        #[qinvokable]
        #[cxx_name = "setActive"]
        fn set_active(self: Pin<&mut TaskStore>, id: i32);
        #[qinvokable]
        fn refresh(self: Pin<&mut TaskStore>);
    }

    impl cxx_qt::Initialize for TaskStore {}
}

#[derive(Default)]
pub struct TasksRust {
    items: QVariant,
    active_id: i32,
    can_undo: bool,
}

impl cxx_qt::Initialize for qobject::TaskStore {
    fn initialize(self: Pin<&mut Self>) {
        self.refresh();
    }
}
