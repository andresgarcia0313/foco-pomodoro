import QtQuick
import QtQuick.Layouts

// Label on the left, control on the right; the label names the control for screen readers.
RowLayout {
    id: row
    property string label
    default property alias control: slot.data
    Layout.fillWidth: true
    spacing: Theme.s3
    Text {
        Layout.fillWidth: true
        text: row.label
        wrapMode: Text.WordWrap
        color: Theme.text
        font.pointSize: Theme.body
    }
    Item {
        id: slot
        implicitWidth: childrenRect.width
        implicitHeight: Math.max(Theme.hit, childrenRect.height)
    }
}
