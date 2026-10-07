import QtQuick
import QtQuick.Layouts

// Reset, start/pause (primary) and skip. Space is handled by the window.
RowLayout {
    id: controls
    required property QtObject timer
    spacing: Theme.s4
    IconButton {
        iconName: "rotate-ccw"
        tip: qsTr("Reiniciar fase (Ctrl+R)")
        tint: Theme.textMuted
        onClicked: controls.timer.reset()
    }
    PrimaryButton {
        text: controls.timer.state === 1 ? qsTr("Pausar")
            : controls.timer.state === 2 ? qsTr("Reanudar") : qsTr("Iniciar")
        iconName: controls.timer.state === 1 ? "pause" : "play"
        focus: true
        onClicked: controls.timer.toggle()
    }
    IconButton {
        iconName: "skip-forward"
        tip: qsTr("Saltar fase (Ctrl+Shift+S)")
        tint: Theme.textMuted
        onClicked: controls.timer.skip()
    }
}
