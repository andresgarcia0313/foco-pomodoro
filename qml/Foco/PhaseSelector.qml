import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Text segmented control to jump to a phase; the current one carries the phase color.
RowLayout {
    id: selector
    property int phase: 0
    property bool compact: false
    signal picked(int phase)
    spacing: Theme.s1

    Repeater {
        model: 3
        delegate: AbstractButton {
            id: seg
            required property int index
            readonly property bool current: index === selector.phase
            text: selector.compact ? Phases.shortNames[index] : Phases.name(index)
            hoverEnabled: true
            focusPolicy: Qt.StrongFocus
            checkable: true
            checked: current
            Accessible.name: Phases.name(index)
            Accessible.role: Accessible.RadioButton
            implicitHeight: Theme.hit
            implicitWidth: label.implicitWidth + Theme.s4
            onClicked: selector.picked(index)
            contentItem: Text {
                id: label
                text: seg.text
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: Theme.label
                font.weight: seg.current ? Font.DemiBold : Font.Normal
                color: seg.current ? Theme.phaseColor(seg.index) : Theme.textMuted
            }
            background: Rectangle {
                radius: height / 2
                color: seg.current ? Theme.tint(Theme.phaseColor(seg.index), 0.14)
                     : seg.hovered ? Theme.hover : "transparent"
                FocusRing { target: seg }
            }
        }
    }
}
