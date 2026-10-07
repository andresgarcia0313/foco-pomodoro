import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Section tab: label is always visible; selection = accent underline + bold text.
AbstractButton {
    id: tab
    property string iconName
    property bool compact: false
    checkable: true
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    implicitHeight: Theme.hit + Theme.s2
    implicitWidth: row.implicitWidth + Theme.s4
    Accessible.role: Accessible.PageTab
    Accessible.name: text
    ToolTip.visible: compact && hovered
    ToolTip.text: text

    contentItem: Item {
        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: Theme.s1 + 2
            Icon { glyph: tab.iconName; size: 16; color: tab.checked ? Theme.text : Theme.textMuted }
            Text {
                visible: !tab.compact
                text: tab.text
                color: tab.checked ? Theme.text : Theme.textMuted
                font.pointSize: Theme.label
                font.weight: tab.checked ? Font.DemiBold : Font.Normal
            }
        }
    }
    background: Rectangle {
        radius: Theme.radiusControl
        color: tab.hovered && !tab.checked ? Theme.hover : "transparent"
        Rectangle {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom
                      leftMargin: Theme.s2; rightMargin: Theme.s2 }
            height: 2; radius: 1
            color: Theme.accent
            visible: tab.checked
        }
        FocusRing { target: tab }
    }
}
