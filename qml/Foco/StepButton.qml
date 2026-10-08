import QtQuick

// Adds or removes one minute; held down, it keeps stepping.
IconButton {
    id: step
    required property QtObject timer
    required property int minutes
    implicitWidth: Theme.hit
    implicitHeight: Theme.hit
    iconName: minutes > 0 ? "plus" : "minus"
    tip: minutes > 0 ? qsTr("Añadir un minuto (+)") : qsTr("Quitar un minuto (-)")
    tint: Theme.textMuted
    autoRepeat: true
    autoRepeatDelay: 450
    autoRepeatInterval: 120
    onClicked: step.timer.adjust(step.minutes)
}
