import QtQuick

// Keyboard focus indicator drawn 2 px outside its parent shape.
Rectangle {
    property Item target: parent
    anchors.fill: parent
    anchors.margins: -4
    radius: (parent && parent.radius !== undefined ? parent.radius : Theme.radiusControl) + 4
    color: "transparent"
    border.width: 2
    border.color: Theme.accent
    visible: target ? target.visualFocus : false
}
