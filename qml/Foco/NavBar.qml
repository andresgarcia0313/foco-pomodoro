import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Top-level sections (icon + label) and the app menu button.
RowLayout {
    id: nav
    property int current: 0
    property alias menuButton: menuButton
    signal selected(int index)
    signal menuRequested()
    spacing: Theme.s1
    // Labels collapse to icons when they would push the menu button out of the window.
    readonly property bool compact: width < labels.width + Theme.basePt * 12 + Theme.hit * 2
    TextMetrics { id: labels; font.pointSize: Theme.label; font.weight: Font.DemiBold
        text: qsTr("Temporizador") + qsTr("Tareas") + qsTr("Estadísticas") }

    Repeater {
        model: [{ icon: "timer", label: qsTr("Temporizador") },
                { icon: "list-checks", label: qsTr("Tareas") },
                { icon: "chart-column", label: qsTr("Estadísticas") }]
        delegate: NavTab {
            required property var modelData
            required property int index
            iconName: modelData.icon
            text: modelData.label
            checked: nav.current === index
            compact: nav.compact
            onClicked: nav.selected(index)
        }
    }
    Item { Layout.fillWidth: true }
    IconButton {
        id: menuButton
        iconName: "menu"
        tip: qsTr("Menú")
        tint: Theme.textMuted
        onClicked: nav.menuRequested()
    }
}
