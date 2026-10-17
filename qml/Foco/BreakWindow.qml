import QtQuick

// One full-screen break window. Esc closes it; Enter answers the question once the window has
// been up for a moment, so keys typed into another app as it appears are not taken as answers.
Window {
    id: win
    required property QtObject timer
    required property QtObject tasks
    property alias step: view.step
    property alias questions: view.questions
    // On Wayland the window manager places windows; the title tells KWin which screen is ours.
    property string screenName
    signal reviewed(int taskId)
    signal continued(int taskId)
    signal closeRequested()
    signal placed()
    title: qsTr("Foco: descanso") + " · " + screenName
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: Theme.base

    BreakView {
        id: view
        anchors.fill: parent
        timer: win.timer
        tasks: win.tasks
        onReviewed: id => win.reviewed(id)
        onContinued: id => win.continued(id)
        onCloseRequested: win.closeRequested()
    }
    Timer { id: settle; interval: 1500; running: win.visible }
    Timer { interval: 300; running: win.visible; onTriggered: win.placed() }
    Shortcut { sequence: "Escape"; onActivated: win.closeRequested() }
    Shortcut {
        sequences: ["Return", "Enter"]
        enabled: !settle.running
        onActivated: view.confirm()
    }
}
