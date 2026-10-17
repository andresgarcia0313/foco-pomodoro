import QtQuick

// One full-screen break window. It fades in, no control starts with the keyboard focus and no
// key answers a question, so whatever the person was typing when it appeared goes nowhere.
// Esc closes it, as the close button does.
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
    color: "transparent"

    // macOS turns full screen into a separate Space with its own animation; a borderless window
    // the size of the screen covers it in place instead.
    function cover() {
        if (Qt.platform.os !== "osx") return showFullScreen()
        x = screen.virtualX; y = screen.virtualY
        width = screen.width; height = screen.height
        show()
    }

    BreakView {
        id: view
        anchors.fill: parent
        timer: win.timer
        tasks: win.tasks
        opacity: 0
        Component.onCompleted: opacity = 1
        Behavior on opacity { NumberAnimation { duration: Theme.slow * 2 } }
        onReviewed: id => win.reviewed(id)
        onContinued: id => win.continued(id)
        onCloseRequested: win.closeRequested()
    }
    Timer { interval: 300; running: win.visible; onTriggered: win.placed() }
    Shortcut { sequence: "Escape"; onActivated: win.closeRequested() }
}
