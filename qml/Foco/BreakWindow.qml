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
    signal deactivated()
    title: qsTr("Foco: descanso") + " · " + screenName
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: "transparent"

    // The screen this window covers. Qt reassigns `screen` from the window's position, and a
    // new window sits at 0,0 on the first screen, where full screen would then be requested.
    required property var place

    // Placed on its own screen first, also when shown again on another desktop. macOS turns
    // full screen into a separate Space with its own animation; a borderless window the size
    // of the screen covers it in place instead.
    function cover() {
        screen = place
        x = place.virtualX; y = place.virtualY
        width = place.width; height = place.height
        if (Qt.platform.os === "osx") show()
        else showFullScreen()
        // Where the window manager allows it; a window that never had the focus cannot tell
        // when its desktop is left (BreakScreens `follow`).
        if (questions) requestActivate()
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
    onActiveChanged: if (!active) deactivated()
    Timer { interval: 300; running: win.visible; onTriggered: win.placed() }
    Shortcut { sequence: "Escape"; onActivated: win.closeRequested() }
}
