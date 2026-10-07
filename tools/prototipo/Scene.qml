import QtQuick
import Foco

AppShell {
    id: scene
    property var config
    timer: MockTimer {
        phase: scene.config.phase ?? 0
        state: scene.config.state ?? 1
        totalSeconds: [25, 5, 15][phase] * 60
        remainingSeconds: scene.config.remaining ?? (24 * 60 + 13)
        cycleDone: scene.config.cycleDone ?? 1
    }
    tasks: MockTasks {
        Component.onCompleted: {
            if (scene.config.emptyTasks) items = []
            if (scene.config.noActive) activeId = 0
            canUndo = scene.config.undo ?? false
        }
    }
    stats: MockStats {
        Component.onCompleted: if (scene.config.emptyStats) {
            todayCount = 0; todayMinutes = 0; streak = 0; weekCount = 0; weekMinutes = 0
            week = week.map(d => Object.assign({}, d, { count: 0, minutes: 0 }))
        }
    }
    section: config.section ?? 0
}
