import QtQuick
import QtQuick.Controls

// Square icon-only button with mandatory accessible name and tooltip.
AbstractButton {
    id: control
    property string iconName
    property string tip
    property color tint: Theme.text
    implicitWidth: Theme.hit + Theme.s2
    implicitHeight: Theme.hit + Theme.s2
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    Accessible.name: tip
    Accessible.role: Accessible.Button

    contentItem: Icon { glyph: control.iconName; color: control.enabled ? control.tint : Theme.border
        anchors.centerIn: parent }
    background: Rectangle {
        radius: Theme.radiusControl
        color: control.down ? Theme.selected : control.hovered ? Theme.hover : "transparent"
        Behavior on color { ColorAnimation { duration: Theme.fast } }
        FocusRing { target: control }
    }
    ToolTip.visible: hovered && tip !== ""
    ToolTip.delay: 600
    ToolTip.text: tip
}
