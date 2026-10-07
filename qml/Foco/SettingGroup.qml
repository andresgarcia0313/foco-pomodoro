import QtQuick
import QtQuick.Layouts

// Titled card grouping related settings.
ColumnLayout {
    id: group
    property string title
    default property alias rows: card.data
    Layout.fillWidth: true
    spacing: Theme.s2
    Text {
        text: group.title
        color: Theme.textMuted
        font.pointSize: Theme.label
        font.weight: Font.DemiBold
        Accessible.role: Accessible.Heading
    }
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: card.implicitHeight + Theme.s4 * 2
        radius: Theme.radiusCard
        color: Theme.raised
        ColumnLayout {
            id: card
            anchors.fill: parent
            anchors.margins: Theme.s4
            spacing: Theme.s3
        }
    }
}
