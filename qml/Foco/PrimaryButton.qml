import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Pill-shaped main action. Label is dark on the accent fill (5.9:1 in Dracula).
AbstractButton {
    id: control
    property string iconName
    property color fill: Theme.accent
    implicitWidth: Math.max(148, row.implicitWidth + Theme.s6)
    implicitHeight: 44
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    Accessible.name: text
    Accessible.role: Accessible.Button

    contentItem: Item {
        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: Theme.s2
            Icon { glyph: control.iconName; color: Theme.accentLabel; visible: glyph !== "" }
            Text {
                text: control.text
                color: Theme.accentLabel
                font.pointSize: Theme.body * 1.05
                font.weight: Font.DemiBold
            }
        }
    }
    background: Rectangle {
        radius: height / 2
        color: control.down ? Qt.darker(control.fill, 1.15)
             : control.hovered ? Qt.lighter(control.fill, 1.08) : control.fill
        Behavior on color { ColorAnimation { duration: Theme.fast } }
        FocusRing { target: control }
    }
}
