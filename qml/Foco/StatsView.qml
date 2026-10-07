import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Progress written as sentences (no big-number tiles) plus the week chart.
Item {
    id: view
    required property QtObject stats
    readonly property bool empty: stats.weekCount === 0

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.s5
        spacing: Theme.s3

        Text {
            text: qsTr("Hoy: %1").arg(Phases.focuses(view.stats.todayCount))
                  + " · " + Phases.duration(view.stats.todayMinutes)
            color: Theme.text
            font.pointSize: Theme.title
            font.weight: Font.DemiBold
        }
        Text {
            visible: view.stats.streak > 0
            text: qsTr("Racha: %1").arg(Phases.days(view.stats.streak))
            color: Theme.text
            font.pointSize: Theme.body
        }
        Text {
            visible: view.empty
            Layout.fillWidth: true
            text: qsTr("Completa tu primer enfoque para ver tu semana.")
            wrapMode: Text.WordWrap
            color: Theme.textMuted
            font.pointSize: Theme.body
        }
        WeekChart {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: Theme.s4
            Layout.maximumHeight: 220
            days: view.stats.week
        }
        Text {
            text: qsTr("Esta semana: %1").arg(Phases.focuses(view.stats.weekCount))
                  + " · " + Phases.duration(view.stats.weekMinutes)
            color: Theme.textMuted
            font.pointSize: Theme.body
        }
        Item { Layout.fillHeight: true }
    }
}
