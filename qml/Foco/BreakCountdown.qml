import QtQuick
import QtQuick.Layouts

// The rest itself: the remaining time as the hero inside the phase ring, plus one suggestion.
ColumnLayout {
    id: countdown
    required property QtObject timer
    property color color: Theme.shortBreak
    property real ringSize: 360
    property bool advice: true
    spacing: Theme.s6

    PhaseRing {
        id: ring
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: countdown.ringSize
        Layout.preferredHeight: countdown.ringSize
        progress: 1 - countdown.timer.remainingSeconds / Math.max(1, countdown.timer.totalSeconds)
        cycleLength: countdown.timer.cycleLength
        cycleDone: countdown.timer.cycleDone
        color: countdown.color
        paused: countdown.timer.state === 2
        Accessible.name: qsTr("%1, quedan %2").arg(Phases.name(countdown.timer.phase))
            .arg(Phases.clock(countdown.timer.remainingSeconds))
        Digits {
            anchors.centerIn: parent
            width: ring.width * 0.66
            horizontalAlignment: Text.AlignHCenter
            fontSizeMode: Text.HorizontalFit
            text: Phases.clock(countdown.timer.remainingSeconds)
            color: Theme.text
            font.pointSize: Theme.display * 1.4
            font.weight: Font.Medium
        }
    }
    Text {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        visible: countdown.advice
        text: countdown.timer.phase === 2
            ? qsTr("Aléjate de la pantalla: camina, toma agua.")
            : qsTr("Levántate, estira y mira algo lejano.")
        color: Theme.textMuted
        font.pointSize: Theme.title
    }
}
