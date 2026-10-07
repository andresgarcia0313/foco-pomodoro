import QtQuick
import QtQuick.Layouts

// Last seven days of focus minutes. Today at full strength, other days at 70 % (3.6:1).
RowLayout {
    id: chart
    property var days: []   // [{ label, name, count, minutes, today }]
    readonly property int peak: Math.max(25, ...days.map(d => d.minutes))
    spacing: Theme.s2

    Repeater {
        model: chart.days
        delegate: ColumnLayout {
            required property var modelData
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Theme.s1
            Accessible.role: Accessible.StaticText
            Accessible.name: modelData.name + ": " + Phases.focuses(modelData.count)

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.min(28, parent.width * 0.7)
                    height: Math.max(3, parent.height * modelData.minutes / chart.peak)
                    radius: 4
                    color: Theme.focusPhase
                    opacity: modelData.today ? 1 : 0.7
                }
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: modelData.label
                color: modelData.today ? Theme.text : Theme.textMuted
                font.pointSize: Theme.caption
                font.weight: modelData.today ? Font.DemiBold : Font.Normal
            }
        }
    }
}
