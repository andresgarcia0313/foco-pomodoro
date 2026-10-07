import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Transient confirmation with an undo action. Ctrl+Z does the same from the window.
Rectangle {
    id: toast
    property bool shown: false
    property string message
    signal undo()
    visible: opacity > 0
    opacity: shown ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: Theme.normal } }
    implicitWidth: row.implicitWidth + Theme.s5
    implicitHeight: Theme.hit + Theme.s3
    radius: height / 2
    color: Theme.selected
    Accessible.role: Accessible.AlertMessage
    Accessible.name: message

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: Theme.s3
        Text { text: toast.message; color: Theme.text; font.pointSize: Theme.body }
        AbstractButton {
            id: action
            text: qsTr("Deshacer")
            focusPolicy: Qt.StrongFocus
            hoverEnabled: true
            Accessible.name: qsTr("Deshacer (Ctrl+Z)")
            onClicked: toast.undo()
            contentItem: Text { text: action.text; color: Theme.accent; font.pointSize: Theme.body
                                font.weight: Font.DemiBold; font.underline: action.hovered }
            background: FocusRing { target: action }
        }
    }
}
