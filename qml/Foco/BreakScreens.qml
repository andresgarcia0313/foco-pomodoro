import QtQuick

// Covers every screen during a break. Only the screen that holds the main window asks the
// questions; the others show the countdown. Closed, the windows are destroyed, not hidden.
Instantiator {
    id: screens
    required property QtObject timer
    required property QtObject tasks
    property var home: Qt.application.screens[0]
    property string step: "rest"
    property bool shown: false
    signal reviewed(int taskId)
    signal continued(int taskId)
    signal closed()
    // A window is up: the app asks the window manager to put it full screen on that screen.
    signal covered(string title, string screenName, bool focus)

    function open(firstStep) { step = firstStep; shown = true }
    function close() { if (!shown) return; shown = false; closed() }

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
        Component.onCompleted: cover()
    }
}
