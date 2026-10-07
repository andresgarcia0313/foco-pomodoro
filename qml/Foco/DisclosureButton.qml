import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

AbstractButton {
    id: control
    property bool expanded: false
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    implicitHeight: Theme.hit + Theme.s2
    implicitWidth: row.implicitWidth + Theme.s4
    Accessible.role: Accessible.Button
    Accessible.name: text
    contentItem: Item {
        RowLayout {
            id: row
            anchors.verticalCenter: parent.verticalCenter
            x: Theme.s2
            Text { text: control.text; color: Theme.textMuted; font.pointSize: Theme.label }
            Icon { glyph: "chevron-down"; size: 16; color: Theme.textMuted
                   rotation: control.expanded ? 180 : 0 }
        }
    }
    background: Rectangle {
        radius: Theme.radiusControl
        color: control.hovered ? Theme.hover : "transparent"
        FocusRing { target: control }
    }
}
