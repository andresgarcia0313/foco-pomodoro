import QtQuick

SettingRow {
    id: row
    property alias checked: toggle.checked
    signal toggled()
    ThemedSwitch { id: toggle; Accessible.name: row.label; onToggled: row.toggled() }
}
