import QtQuick
import QtQuick.Layouts

// Full-screen break in three steps: "review" (which task got the focus), "rest" (the countdown
// as the hero) and "next" (which task comes next). Other screens only show the countdown.
Rectangle {
    id: view
    required property QtObject timer
    required property QtObject tasks
    property string step: "rest"
    property bool questions: true
    readonly property bool resting: timer.phase !== 0
    // After the break the screen is about the coming focus, so it takes the focus color.
    readonly property color phaseColor: Theme.phaseColor(resting ? timer.phase : 0)
    readonly property var proposed: tasks.items.find(t => t.id === tasks.activeId)
    signal reviewed(int taskId)
    signal continued(int taskId)
    signal closeRequested()
    color: Theme.base

    IconButton {
        anchors { top: parent.top; right: parent.right; margins: Theme.s5 }
        iconName: "x"
        tip: qsTr("Cerrar (Esc)")
        onClicked: view.closeRequested()
    }
    ColumnLayout {
        anchors.centerIn: parent
        width: Math.min(view.width - Theme.s7 * 2, Theme.basePt * 48)
        spacing: Theme.s6

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: view.resting ? qsTr("%1 · %2").arg(Phases.name(view.timer.phase))
                                                .arg(Phases.clock(view.timer.remainingSeconds))
                               : qsTr("Descanso terminado")
            color: view.phaseColor
            font.pointSize: Theme.title
            font.weight: Font.DemiBold
            // Screens without questions say the break is over instead of showing an idle clock.
            visible: view.questions ? view.step !== "rest" : !view.resting
        }
        BreakCountdown {
            Layout.fillWidth: true
            visible: view.resting && (!view.questions || view.step === "rest")
            timer: view.timer
            color: view.phaseColor
            ringSize: Math.min(view.height * 0.5, 420)
            advice: view.questions
        }
        Loader {
            id: question
            Layout.fillWidth: true
            active: view.questions && view.step !== "rest"
            visible: active
            sourceComponent: view.step === "review" ? review : next
        }
    }
    Component {
        id: review
        BreakQuestion {
            tasks: view.tasks
            title: qsTr("¿En qué trabajaste?")
            hint: view.proposed
                ? qsTr("Propusiste «%1». Si fue otra, elígela o escríbela.").arg(view.proposed.title)
                : qsTr("Elige la tarea o escríbela para que el enfoque quede registrado.")
            maxListHeight: view.height * 0.35
            action: qsTr("Guardar y descansar")
            onAnswered: id => view.reviewed(id)
        }
    }
    Component {
        id: next
        BreakQuestion {
            tasks: view.tasks
            title: qsTr("¿Con qué tarea sigues?")
            maxListHeight: view.height * 0.35
            action: qsTr("Empezar enfoque")
            actionIcon: "play"
            onAnswered: id => view.continued(id)
        }
    }
}
