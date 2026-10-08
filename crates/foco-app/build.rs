use cxx_qt_build::{CxxQtBuilder, QResource, QResources, QmlModule};
use qt_build_utils::QResourceFile;
use std::{fs, path::Path};

const BRIDGES: [&str; 5] = [
    "src/services_object.rs",
    "src/timer_object.rs",
    "src/tasks_object.rs",
    "src/stats_object.rs",
    "src/settings_object.rs",
];

fn main() {
    let interface = Path::new(env!("CARGO_MANIFEST_DIR")).join("../../qml/Foco");
    let interface = interface.canonicalize().expect("qml/Foco exists");
    println!("cargo:rerun-if-changed={}", interface.display());

    CxxQtBuilder::new_qml_module(QmlModule::new("FocoApp").version(1, 0).qml_files([
        "qml/Main.qml",
        "qml/Tray.qml",
        "qml/Chime.qml",
    ]))
    .files(BRIDGES)
    .qt_module("Quick")
    .qt_module("QuickControls2")
    .qt_module("Widgets")
    .cpp_files(["src/app_shim.cpp"])
    .qrc_resources(
        QResources::new()
            .resource(QResource::new().files(["assets/chime.wav", "assets/foco.svg"]))
            .resource(interface_module(&interface)),
    )
    .build();
}

/// The hand-written `Foco` module (also used by the design prototypes), served from
/// `qrc:/qt/qml/Foco`, which is on the default QML import path.
fn interface_module(dir: &Path) -> QResource {
    let mut files = Vec::new();
    for sub in ["", "icons"] {
        let folder = dir.join(sub);
        for entry in fs::read_dir(&folder).expect("readable interface folder") {
            let path = entry.expect("readable entry").path();
            let name = path.file_name().unwrap().to_string_lossy().into_owned();
            let wanted = name == "qmldir" || name.ends_with(".qml") || name.ends_with(".svg");
            if path.is_file() && wanted {
                let alias = if sub.is_empty() {
                    name
                } else {
                    format!("{sub}/{name}")
                };
                files.push(QResourceFile::new(&path).alias(alias));
            }
        }
    }
    QResource::new().prefix("/qt/qml/Foco").files(files)
}
