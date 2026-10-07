import QtQuick
import QtQuick.Controls

// Popup menu painted with theme tokens (Basic style base).
Menu {
    id: menu
    padding: Theme.s1
    background: Rectangle {
        implicitWidth: 220
        radius: Theme.radiusCard
        color: Theme.raised
        border.color: Theme.tint(Theme.border, 0.5)
    }
    delegate: ThemedMenuItem {}
}
