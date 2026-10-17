import QtQuick
import QtQuick.Layouts

// One question of the break screen: a title, a hint, the task choice and one action.
ColumnLayout {
    id: question
    required property QtObject tasks
    property alias title: heading.text
    property alias hint: hintText.text
    property alias action: button.text
    property alias actionIcon: button.iconName
    property alias maxListHeight: choice.maxListHeight
    signal answered(int taskId)
    spacing: Theme.s4

    function confirm() {
        if (!choice.ready) return
        question.answered(choice.commit())
    }

    Text {
        id: heading
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        color: Theme.text
        font.pointSize: Theme.title * 1.5
        font.weight: Font.DemiBold
        Accessible.role: Accessible.Heading
    }
    Text {
        id: hintText
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        color: Theme.textMuted
        font.pointSize: Theme.body
        visible: text !== ""
    }
    TaskChoice {
        id: choice
        Layout.fillWidth: true
        tasks: question.tasks
    }
    PrimaryButton {
        id: button
        Layout.alignment: Qt.AlignRight
        enabled: choice.ready
        opacity: enabled ? 1 : 0.5
        onClicked: question.confirm()
    }
}
