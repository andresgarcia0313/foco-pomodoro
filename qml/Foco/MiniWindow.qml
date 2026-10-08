import QtQuick

Window {
    id: win
    required property QtObject timer
    property bool stayOnTop: true
    signal expand()
    title: qsTr("Foco mini")
    width: 260; height: 96
    minimumWidth: 220; minimumHeight: 80
    flags: Qt.Tool | (stayOnTop ? Qt.WindowStaysOnTopHint : 0)
    color: Theme.base
    MiniView { anchors.fill: parent; timer: win.timer; onExpand: win.expand() }
    Shortcut { sequence: "Space"; onActivated: win.timer.toggle() }
    Shortcut { sequences: ["+", "="]; onActivated: win.timer.adjust(1) }
    Shortcut { sequence: "-"; onActivated: win.timer.adjust(-1) }
}
