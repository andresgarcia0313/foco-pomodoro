import QtQuick
import Foco

// One design scenario: the shell, the settings page or the mini view, fed by mocks.
Item {
    id: scene
    property var config
    MockTimer {
        id: mockTimer
        phase: scene.config.phase ?? 0
        state: scene.config.state ?? 1
        totalSeconds: [25, 5, 15][phase] * 60
        remainingSeconds: scene.config.remaining ?? (24 * 60 + 13)
        cycleDone: scene.config.cycleDone ?? 1
    }
    MockTasks {
        id: mockTasks
        Component.onCompleted: {
            if (scene.config.emptyTasks) items = []
            if (scene.config.noActive) activeId = 0
            canUndo = scene.config.undo ?? false
        }
    }
    MockStats {
        id: mockStats
        Component.onCompleted: if (scene.config.emptyStats) {
            todayCount = 0; todayMinutes = 0; streak = 0; weekCount = 0; weekMinutes = 0
            week = week.map(d => Object.assign({}, d, { count: 0, minutes: 0 }))
        }
    }
    MockSettings { id: mockSettings }

    Loader {
        anchors.fill: parent
        sourceComponent: scene.config.kind === "settings" ? settingsPage
                       : scene.config.kind === "mini" ? miniView : shell
    }
    Component { id: shell
        AppShell { timer: mockTimer; tasks: mockTasks; stats: mockStats; section: scene.config.section ?? 0 } }
    Component { id: settingsPage; SettingsPage { settings: mockSettings } }
    Component { id: miniView; MiniView { timer: mockTimer } }
}
