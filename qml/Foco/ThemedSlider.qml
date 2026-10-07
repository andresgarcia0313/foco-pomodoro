import QtQuick
import QtQuick.Controls

Slider {
    id: control
    implicitWidth: 180
    implicitHeight: Theme.hit
    background: Rectangle {
        x: control.leftPadding; y: control.topPadding + control.availableHeight / 2 - height / 2
        width: control.availableWidth; height: 4; radius: 2
        color: Theme.selected
        Rectangle { width: control.visualPosition * parent.width; height: parent.height
                    radius: 2; color: Theme.accent }
    }
    handle: Rectangle {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        width: 18; height: 18; radius: 9
        color: control.pressed ? Theme.accent : Theme.text
        FocusRing { target: control }
    }
}
