import QtQuick
import QtQuick.Layouts

// Remaining time (tabular figures, no layout shift), position in the cycle and one-minute
// steps on either side, right next to the number they change.
ColumnLayout {
    id: face
    required property QtObject timer
    spacing: 0
    Text {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        Layout.preferredHeight: face.width * 0.42
        verticalAlignment: Text.AlignVCenter
        fontSizeMode: Text.Fit
        minimumPointSize: 12
        text: Phases.clock(face.timer.remainingSeconds)
        color: face.timer.state === 2 ? Theme.textMuted : Theme.text
        font.pointSize: Theme.display
        font.weight: Font.Medium
        font.features: { "tnum": 1 }
    }
    RowLayout {
        Layout.fillWidth: true
        spacing: 0
        StepButton { minutes: -1; timer: face.timer }
        Text {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            text: face.timer.state === 2 ? qsTr("En pausa")
                : face.timer.phase === 0
                    ? qsTr("%1 de %2").arg(Math.min(face.timer.cycleDone + 1, face.timer.cycleLength))
                        .arg(face.timer.cycleLength)
                    : qsTr("%1 de %2 hechos").arg(face.timer.cycleDone).arg(face.timer.cycleLength)
            color: Theme.textMuted
            font.pointSize: Theme.label
        }
        StepButton { minutes: 1; timer: face.timer }
    }
}
