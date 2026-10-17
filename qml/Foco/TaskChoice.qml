import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Pick one pending task or type a new one. The active task comes preselected, so confirming
// without touching anything keeps what was proposed; the field never takes focus by itself.
ColumnLayout {
    id: choice
    required property QtObject tasks
    property int selectedId: tasks.activeId
    readonly property var pending: tasks.items.filter(t => !t.completed)
    readonly property bool ready: field.text.trim() !== "" || selectedId > 0
    property real maxListHeight: Theme.basePt * 24
    spacing: Theme.s2

    // Returns the chosen task id; a typed title becomes a new task first.
    function commit() {
        const title = field.text.trim()
        if (title !== "") selectedId = tasks.add(title, 1)
        field.clear()
        return selectedId
    }

    ListView {
        id: list
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(contentHeight, choice.maxListHeight)
        clip: true
        model: choice.pending
        boundsBehavior: Flickable.StopAtBounds
        ScrollBar.vertical: ScrollBar { policy: list.contentHeight > list.height
                                        ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff }
        delegate: ItemDelegate {
            id: row
            required property var modelData
            readonly property bool chosen: modelData.id === choice.selectedId
                                           && field.text.trim() === ""
            width: ListView.view.width
            implicitHeight: Math.max(Theme.hit + Theme.s3, implicitContentHeight + Theme.s3)
            hoverEnabled: true
            Accessible.role: Accessible.RadioButton
            Accessible.checked: chosen
            Accessible.name: modelData.title
            onClicked: { choice.selectedId = modelData.id; field.clear() }
            contentItem: RowLayout {
                spacing: Theme.s3
                Icon { glyph: row.chosen ? "circle-check" : "circle"
                       color: row.chosen ? Theme.accent : Theme.textMuted }
                Text {
                    Layout.fillWidth: true
                    text: row.modelData.title
                    elide: Text.ElideRight
                    color: Theme.text
                    font.pointSize: Theme.body * 1.1
                }
                Digits {
                    text: qsTr("%1/%2").arg(row.modelData.done).arg(row.modelData.estimate)
                    color: Theme.textMuted
                    font.pointSize: Theme.caption
                }
            }
            background: Rectangle {
                radius: Theme.radiusControl
                color: row.chosen ? Theme.tint(Theme.accent, 0.14)
                     : row.hovered ? Theme.hover : "transparent"
                FocusRing { target: row }
            }
        }
    }
    ThemedTextField {
        id: field
        Layout.fillWidth: true
        placeholderText: choice.pending.length ? qsTr("Otra tarea…") : qsTr("Escribe la tarea…")
        Accessible.name: qsTr("Otra tarea")
    }
}
