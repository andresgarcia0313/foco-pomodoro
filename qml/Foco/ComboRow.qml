import QtQuick

SettingRow {
    id: row
    property alias model: combo.model
    property alias currentIndex: combo.currentIndex
    signal activated(int index)
    ThemedComboBox { id: combo; Accessible.name: row.label; onActivated: i => row.activated(i) }
}
