import QtQuick

SettingRow {
    id: row
    property int value
    property int from: 1
    property int to: 60
    property string suffix: qsTr(" min")
    signal edited(int value)
    ThemedSpinBox {
        from: row.from; to: row.to; value: row.value
        textFromValue: (v, locale) => v + row.suffix
        valueFromText: (text, locale) => parseInt(text)
        Accessible.name: row.label
        onValueModified: row.edited(value)
    }
}
