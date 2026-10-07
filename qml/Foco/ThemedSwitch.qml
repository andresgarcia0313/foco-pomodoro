import QtQuick
import QtQuick.Controls

Switch {
    id: control
    implicitHeight: Theme.hit
    implicitWidth: 40 + leftPadding + rightPadding
    indicator: Rectangle {
        implicitWidth: 40; implicitHeight: 22
        x: control.leftPadding; y: (control.height - height) / 2
        radius: height / 2
        color: control.checked ? Theme.accent : Theme.selected
        border.color: control.checked ? Theme.accent : Theme.border
        Rectangle {
            x: control.checked ? parent.width - width - 3 : 3
            y: 3; width: 16; height: 16; radius: 8
            color: control.checked ? Theme.accentLabel : Theme.text
            Behavior on x { NumberAnimation { duration: Theme.fast } }
        }
        FocusRing { target: control }
    }
    contentItem: Item {}
}
