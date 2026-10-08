import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// One task: complete toggle, title, pomodoros done/estimated, star (active), delete on hover.
ItemDelegate {
    id: row
    required property var task
    required property QtObject tasks
    readonly property bool isActive: task.id === tasks.activeId
    width: ListView.view ? ListView.view.width : implicitWidth
    implicitHeight: Theme.hit + Theme.s3
    hoverEnabled: true
    padding: 0
    leftPadding: Theme.s1
    rightPadding: Theme.s1
    Accessible.name: qsTr("%1, %2 de %3 pomodoros").arg(task.title).arg(task.done).arg(task.estimate)
    Keys.onSpacePressed: tasks.toggleCompleted(task.id)
    Keys.onDeletePressed: tasks.remove(task.id)
    Keys.onReturnPressed: tasks.setActive(task.id)

    contentItem: RowLayout {
        spacing: Theme.s2
        IconButton {
            iconName: row.task.completed ? "circle-check" : "circle"
            tint: row.task.completed ? Theme.shortBreak : Theme.textMuted
            tip: row.task.completed ? qsTr("Marcar como pendiente") : qsTr("Completar")
            onClicked: row.tasks.toggleCompleted(row.task.id)
        }
        Text {
            Layout.fillWidth: true
            text: row.task.title
            elide: Text.ElideRight
            color: row.task.completed ? Theme.textMuted : Theme.text
            font.strikeout: row.task.completed
            font.pointSize: Theme.body
        }
        Digits {
            text: qsTr("%1/%2").arg(row.task.done).arg(row.task.estimate)
            color: Theme.textMuted
            font.pointSize: Theme.caption
        }
        IconButton {
            iconName: "trash-2"
            tip: qsTr("Eliminar (Supr)")
            tint: Theme.danger
            opacity: row.hovered || activeFocus ? 1 : 0
            onClicked: row.tasks.remove(row.task.id)
        }
        IconButton {
            iconName: "star"
            tip: row.isActive ? qsTr("Tarea activa") : qsTr("Trabajar en esta tarea (Intro)")
            tint: row.isActive ? Theme.accent : Theme.textMuted
            visible: !row.task.completed
            onClicked: row.tasks.setActive(row.task.id)
        }
    }
    background: Rectangle {
        radius: Theme.radiusControl
        color: row.isActive ? Theme.tint(Theme.accent, 0.10) : row.hovered ? Theme.hover : "transparent"
        FocusRing { target: row }
    }
}
