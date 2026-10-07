import QtQuick

// Separate settings window (Settings… in the app menu); min/max are irrelevant here.
Window {
    id: win
    required property QtObject settings
    title: qsTr("Ajustes de Foco")
    width: 460; height: 640
    minimumWidth: 380; minimumHeight: 420
    color: Theme.base
    flags: Qt.Dialog
    SettingsPage { anchors.fill: parent; settings: win.settings }
    Shortcut { sequences: [StandardKey.Close, "Esc"]; onActivated: win.close() }
}
