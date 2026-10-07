import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Names the current focus. Opens a menu with pending tasks.
AbstractButton {
    id: chip
    required property QtObject tasks
    readonly property var active: tasks.items.find(t => t.id === tasks.activeId)
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    implicitHeight: Theme.hit + Theme.s1
    implicitWidth: row.implicitWidth + Theme.s5
    text: active ? qsTr("%1 · %2 de %3").arg(active.title).arg(active.done).arg(active.estimate)
                 : qsTr("Elegir tarea")
    Accessible.name: qsTr("Tarea activa: %1").arg(text)
    onClicked: menu.popup(chip, 0, chip.height)

    contentItem: Item {
        RowLayout {
            id: row
            anchors.centerIn: parent
            width: Math.min(implicitWidth, chip.width - Theme.s5)
            spacing: Theme.s2
            Icon { glyph: "star"; size: 16; color: chip.active ? Theme.accent : Theme.textMuted }
            Text {
                Layout.fillWidth: true
                text: chip.text
                elide: Text.ElideRight
                color: chip.active ? Theme.text : Theme.textMuted
                font.pointSize: Theme.body
            }
            Icon { glyph: "chevron-down"; size: 16; color: Theme.textMuted }
        }
    }
    background: Rectangle {
        radius: height / 2
        color: chip.down ? Theme.selected : chip.hovered ? Theme.hover : Theme.raised
        FocusRing { target: chip }
    }

    ThemedMenu {
        id: menu
        Instantiator {
            model: chip.tasks.items.filter(t => !t.completed)
            delegate: ThemedMenuItem {
                required property var modelData
                text: modelData.title
                checkable: true
                checked: modelData.id === chip.tasks.activeId
                onTriggered: chip.tasks.setActive(modelData.id)
            }
            onObjectAdded: (i, item) => menu.insertItem(i, item)
            onObjectRemoved: (i, item) => menu.removeItem(item)
        }
        MenuSeparator {}
        ThemedMenuItem { text: qsTr("Nueva tarea…"); onTriggered: chip.tasks.newRequested() }
    }
}
