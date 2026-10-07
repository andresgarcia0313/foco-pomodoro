import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// New task field: Enter adds; the estimate spinner sets pomodoros (1 to 12).
RowLayout {
    id: input
    required property QtObject tasks
    property alias field: field
    spacing: Theme.s2

    function submit() {
        if (field.text.trim() === "") return
        tasks.add(field.text.trim(), estimate.value)
        field.clear()
        estimate.value = 1
    }

    ThemedTextField {
        id: field
        Layout.fillWidth: true
        placeholderText: qsTr("Añadir tarea…")
        Accessible.name: qsTr("Nueva tarea")
        onAccepted: input.submit()
    }
    ThemedSpinBox {
        id: estimate
        from: 1; to: 12; value: 1
        Accessible.name: qsTr("Pomodoros estimados")
        ToolTip.visible: hovered
        ToolTip.text: qsTr("Pomodoros estimados")
    }
    IconButton {
        iconName: "plus"
        tip: qsTr("Añadir tarea (Intro)")
        tint: Theme.accent
        enabled: field.text.trim() !== ""
        onClicked: input.submit()
    }
}
