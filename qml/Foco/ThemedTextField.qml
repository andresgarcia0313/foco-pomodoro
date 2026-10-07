import QtQuick
import QtQuick.Controls

TextField {
    id: control
    implicitHeight: Theme.hit + Theme.s2
    color: Theme.text
    placeholderTextColor: Theme.textMuted
    selectionColor: Theme.tint(Theme.accent, 0.4)
    selectedTextColor: Theme.text
    font.pointSize: Theme.body
    leftPadding: Theme.s3
    background: Rectangle {
        radius: Theme.radiusControl
        color: Theme.raised
        border.width: control.activeFocus ? 2 : 1
        border.color: control.activeFocus ? Theme.accent : Theme.tint(Theme.border, 0.6)
    }
}
