import QtQuick
import QtQuick.Layouts

// Window content: phase-tinted canvas, section navigation and the three sections.
Rectangle {
    id: shell
    required property QtObject timer
    required property QtObject tasks
    required property QtObject stats
    property alias section: nav.current
    property alias menuButton: nav.menuButton
    signal menuRequested()
    function showTasksInput() { section = 1; tasksView.focusInput() }

    color: Theme.base
    Rectangle { // the room changes color: 7 % phase tint, only orchestrated motion
        anchors.fill: parent
        color: Theme.tint(Theme.phaseColor(shell.timer.phase), 0.07)
        Behavior on color { ColorAnimation { duration: Theme.slow } }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        NavBar {
            id: nav
            Layout.fillWidth: true
            Layout.margins: Theme.s2
            onSelected: i => current = i
            onMenuRequested: shell.menuRequested()
        }
        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: nav.current
            TimerView { timer: shell.timer; tasks: shell.tasks }
            TasksView { id: tasksView; tasks: shell.tasks }
            StatsView { stats: shell.stats }
        }
    }
    Connections {
        target: shell.tasks
        function onNewRequested() { shell.showTasksInput() }
    }
}
