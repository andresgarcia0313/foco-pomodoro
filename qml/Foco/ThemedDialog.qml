import QtQuick
import QtQuick.Controls

// Modal sheet with a single obvious way out (Esc or the Close button).
Dialog {
    id: dialog
    modal: true
    anchors.centerIn: Overlay.overlay
    padding: Theme.s5
    standardButtons: Dialog.Close
    background: Rectangle { radius: Theme.radiusCard; color: Theme.raised
                            border.color: Theme.tint(Theme.border, 0.5) }
    header: Text {
        text: dialog.title
        padding: Theme.s5
        bottomPadding: 0
        color: Theme.text
        font.pointSize: Theme.title
        font.weight: Font.DemiBold
    }
    Overlay.modal: Rectangle { color: Theme.tint(Theme.dark ? "#191A21" : "#1F1F1F", 0.55) }
}
