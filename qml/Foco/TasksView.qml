import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Tasks section: input, pending list, collapsible completed list, empty state, undo toast.
Item {
    id: view
    required property QtObject tasks
    property bool showCompleted: false
    readonly property var pending: tasks.items.filter(t => !t.completed)
    readonly property var completed: tasks.items.filter(t => t.completed)
    function focusInput() { input.field.forceActiveFocus() }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.s4
        spacing: Theme.s3

        TaskInput { id: input; Layout.fillWidth: true; tasks: view.tasks }

        Text {
            visible: view.tasks.items.length === 0
            Layout.fillWidth: true
            Layout.topMargin: Theme.s6
            text: qsTr("Aún no hay tareas. Escribe la primera y pulsa Intro.")
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            color: Theme.textMuted
            font.pointSize: Theme.body
        }
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 2
            model: view.showCompleted ? view.pending.concat(view.completed) : view.pending
            delegate: TaskRow {
                required property var modelData
                task: modelData
                tasks: view.tasks
            }
            footer: DisclosureButton {
                visible: view.completed.length > 0
                text: qsTr("Completadas (%1)").arg(view.completed.length)
                expanded: view.showCompleted
                onClicked: view.showCompleted = !view.showCompleted
            }
            ScrollBar.vertical: ScrollBar {}
        }
    }
    UndoToast {
        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom
                  bottomMargin: Theme.s4 }
        shown: view.tasks.canUndo
        message: qsTr("Tarea eliminada")
        onUndo: view.tasks.undoRemove()
    }
}
