import QtQuick
import QtQuick.Layouts

// Compact always-visible view: phase dot, clock, start/pause, back to the full window.
Rectangle {
    id: mini
    required property QtObject timer
    signal expand()
    color: Theme.base
    Rectangle { anchors.fill: parent; color: Theme.tint(Theme.phaseColor(mini.timer.phase), 0.07) }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Theme.s3
        spacing: Theme.s2
        Rectangle {
            width: 10; height: 10; radius: 5
            color: mini.timer.state === 2 ? Theme.textMuted : Theme.phaseColor(mini.timer.phase)
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            Text {
                text: Phases.clock(mini.timer.remainingSeconds)
                color: mini.timer.state === 2 ? Theme.textMuted : Theme.text
                font.pointSize: Theme.displayMini
                font.weight: Font.Medium
                font.features: { "tnum": 1 }
            }
            Text {
                text: mini.timer.state === 2 ? qsTr("En pausa") : Phases.name(mini.timer.phase)
                color: Theme.textMuted
                font.pointSize: Theme.caption
            }
        }
        IconButton {
            iconName: mini.timer.state === 1 ? "pause" : "play"
            tip: mini.timer.state === 1 ? qsTr("Pausar") : qsTr("Iniciar")
            tint: Theme.accent
            onClicked: mini.timer.toggle()
        }
        IconButton {
            iconName: "maximize-2"
            tip: qsTr("Volver a la ventana completa")
            tint: Theme.textMuted
            onClicked: mini.expand()
        }
    }
}
