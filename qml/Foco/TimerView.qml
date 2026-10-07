import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Home section: phase selector, signature ring with the clock, controls, active task.
Item {
    id: view
    required property QtObject timer
    required property QtObject tasks
    readonly property color phaseColor: Theme.phaseColor(timer.phase)
    readonly property bool paused: timer.state === 2

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.s5
        spacing: Theme.s4

        PhaseSelector {
            Layout.alignment: Qt.AlignHCenter
            compact: view.width < Theme.basePt * 34
            phase: view.timer.phase
            onPicked: p => view.timer.selectPhase(p)
        }
        PhaseRing {
            id: ring
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: true
            Layout.preferredWidth: Math.min(view.width - Theme.s6 * 2, height, 300)
            Layout.minimumWidth: 180
            Layout.minimumHeight: 180
            progress: 1 - view.timer.remainingSeconds / Math.max(1, view.timer.totalSeconds)
            cycleLength: view.timer.cycleLength
            cycleDone: view.timer.cycleDone
            color: view.phaseColor
            paused: view.paused
            Accessible.name: qsTr("%1, quedan %2").arg(Phases.name(view.timer.phase))
                .arg(Phases.clock(view.timer.remainingSeconds))
            ClockFace {
                anchors.centerIn: parent
                width: ring.width * 0.66
                timer: view.timer
            }
        }
        TimerControls {
            Layout.alignment: Qt.AlignHCenter
            timer: view.timer
        }
        ActiveTask {
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: view.width - Theme.s5 * 2
            tasks: view.tasks
        }
    }
}
