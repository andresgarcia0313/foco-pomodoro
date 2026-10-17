import QtQuick

// Covers every screen during a break. Only the screen that holds the main window asks the
// questions; the others show the countdown. Closed, the windows are destroyed, not hidden.
// With `follow`, where the window manager cannot pin them to every virtual desktop (Windows,
// GNOME), the windows come back on the desktop in use once none of them has the focus: shown
// again, a window opens on the current desktop.
Instantiator {
    id: screens
    required property QtObject timer
    required property QtObject tasks
    property var home: Qt.application.screens[0]
    property string step: "rest"
    property bool shown: false
    property bool follow: false
    signal reviewed(int taskId)
    signal continued(int taskId)
    signal closed()
    // A window is up: the app asks the window manager to put it full screen on that screen.
    signal covered(string title, string screenName, bool focus)

    function open(firstStep) { step = firstStep; shown = true }
    function close() { if (!shown) return; shown = false; closed() }
    function windows() {
        const all = []
        for (let i = 0; i < count; i++) if (objectAt(i)) all.push(objectAt(i))
        return all
    }

    active: shown
    model: Qt.application.screens
    delegate: BreakWindow {
        required property var modelData
        screen: modelData
        screenName: modelData.name
        timer: screens.timer
        tasks: screens.tasks
        step: screens.step
        questions: modelData.name === screens.home.name
        // Signal first, then change the screens: changing them destroys the sender.
        onReviewed: id => { screens.reviewed(id); Qt.callLater(() => screens.step = "rest") }
        onContinued: id => { screens.continued(id); Qt.callLater(() => screens.shown = false) }
        onCloseRequested: Qt.callLater(screens.close)
        onPlaced: screens.covered(title, screenName, questions)
        onDeactivated: if (screens.follow) refollow.restart()
        Component.onCompleted: cover()
    }
    // Waits for the desktop switch to settle, so moving focus between screens does not count.
    property Timer refollow: Timer {
        interval: 400
        onTriggered: {
            const all = screens.windows()
            if (!screens.shown || all.some(w => w.active)) return
            for (const w of all) { w.hide(); w.cover() }
        }
    }
}
