import QtQuick
import QtQuick.Controls

ComboBox {
    id: control
    implicitHeight: Theme.hit + Theme.s1
    implicitWidth: 180
    font.pointSize: Theme.body
    contentItem: Text {
        leftPadding: Theme.s3
        text: control.displayText
        color: Theme.text
        font: control.font
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
    indicator: Icon {
        x: control.width - width - Theme.s2; y: (control.height - height) / 2
        glyph: "chevron-down"; size: 16; color: Theme.textMuted
    }
    background: Rectangle {
        radius: Theme.radiusControl
        color: control.hovered ? Theme.hover : Theme.selected
        FocusRing { target: control }
    }
    delegate: ThemedMenuItem {
        required property int index
        required property var modelData
        width: control.popup.width
        text: modelData
        highlighted: control.highlightedIndex === index
    }
    popup.background: Rectangle { radius: Theme.radiusCard; color: Theme.raised
                                  border.color: Theme.tint(Theme.border, 0.5) }
}
