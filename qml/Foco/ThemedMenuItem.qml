import QtQuick
import QtQuick.Controls

MenuItem {
    id: item
    implicitHeight: Theme.hit
    contentItem: Text {
        leftPadding: item.checkable ? Theme.s5 : Theme.s2
        text: item.text
        color: item.enabled ? Theme.text : Theme.textMuted
        font.pointSize: Theme.body
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
    indicator: Icon {
        x: Theme.s2; anchors.verticalCenter: parent.verticalCenter
        glyph: "check"; size: 16; color: Theme.accent
        visible: item.checkable && item.checked
    }
    background: Rectangle {
        radius: Theme.radiusControl
        color: item.highlighted ? Theme.hover : "transparent"
    }
}
