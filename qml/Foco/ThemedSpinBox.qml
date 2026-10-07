import QtQuick
import QtQuick.Controls

// Compact numeric stepper with theme colors; arrows and wheel change the value.
SpinBox {
    id: control
    editable: true
    implicitHeight: Theme.hit + Theme.s2
    implicitWidth: 104
    font.pointSize: Theme.body
    contentItem: TextInput {
        text: control.displayText
        color: Theme.text
        font: control.font
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: Qt.ImhDigitsOnly
    }
    up.indicator: Text {
        x: control.width - width - Theme.s2; height: control.height
        text: "+"; color: control.up.pressed ? Theme.accent : Theme.textMuted
        font.pointSize: Theme.title; verticalAlignment: Text.AlignVCenter
    }
    down.indicator: Text {
        x: Theme.s2; height: control.height
        text: "−"; color: control.down.pressed ? Theme.accent : Theme.textMuted
        font.pointSize: Theme.title; verticalAlignment: Text.AlignVCenter
    }
    background: Rectangle {
        radius: Theme.radiusControl
        color: Theme.raised
        border.width: control.activeFocus ? 2 : 1
        border.color: control.activeFocus ? Theme.accent : Theme.tint(Theme.border, 0.6)
    }
}
