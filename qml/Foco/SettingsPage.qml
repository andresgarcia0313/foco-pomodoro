import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// All preferences on one scrollable page; every change applies at once (no Save button).
Rectangle {
    id: page
    required property QtObject settings
    color: Theme.base

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        ColumnLayout {
            width: parent.width
            spacing: Theme.s5
            Item { implicitHeight: Theme.s1 }
            SettingGroup {
                Layout.leftMargin: Theme.s5; Layout.rightMargin: Theme.s5
                title: qsTr("Temporizador")
                MinutesRow { label: qsTr("Enfoque"); value: page.settings.focusMinutes; to: 180
                             onEdited: v => page.settings.focusMinutes = v }
                MinutesRow { label: qsTr("Descanso"); value: page.settings.shortBreakMinutes; to: 60
                             onEdited: v => page.settings.shortBreakMinutes = v }
                MinutesRow { label: qsTr("Descanso largo"); value: page.settings.longBreakMinutes
                             to: 120; onEdited: v => page.settings.longBreakMinutes = v }
                MinutesRow { label: qsTr("Descanso largo cada (enfoques)"); suffix: ""; from: 2; to: 12
                             value: page.settings.longBreakEvery
                             onEdited: v => page.settings.longBreakEvery = v }
            }
            SettingGroup {
                Layout.leftMargin: Theme.s5; Layout.rightMargin: Theme.s5
                title: qsTr("Automatización")
                SwitchRow { label: qsTr("Iniciar descansos automáticamente")
                            checked: page.settings.autoStartBreaks
                            onToggled: page.settings.autoStartBreaks = checked }
                SwitchRow { label: qsTr("Iniciar enfoques automáticamente")
                            checked: page.settings.autoStartFocus
                            onToggled: page.settings.autoStartFocus = checked }
            }
            SettingGroup {
                Layout.leftMargin: Theme.s5; Layout.rightMargin: Theme.s5
                title: qsTr("Avisos")
                SwitchRow { label: qsTr("Notificaciones"); checked: page.settings.notifications
                            onToggled: page.settings.notifications = checked }
                SwitchRow { label: qsTr("Sonido al terminar"); checked: page.settings.sound
                            onToggled: page.settings.sound = checked }
                SettingRow {
                    label: qsTr("Volumen")
                    ThemedSlider { value: page.settings.volume; enabled: page.settings.sound
                                   Accessible.name: qsTr("Volumen")
                                   onMoved: page.settings.volume = value }
                }
            }
            SettingGroup {
                Layout.leftMargin: Theme.s5; Layout.rightMargin: Theme.s5
                title: qsTr("Ventana y apariencia")
                SwitchRow { label: qsTr("Mantener en la bandeja al cerrar")
                            checked: page.settings.keepInTray
                            onToggled: page.settings.keepInTray = checked }
                SwitchRow { label: qsTr("Siempre encima"); checked: page.settings.alwaysOnTop
                            onToggled: page.settings.alwaysOnTop = checked }
                ComboRow { label: qsTr("Apariencia"); currentIndex: page.settings.appearance
                           model: [qsTr("Drácula"), qsTr("Alucard"), qsTr("Según el sistema")]
                           onActivated: i => page.settings.appearance = i }
                ComboRow { label: qsTr("Idioma"); currentIndex: page.settings.languageIndex
                           model: [qsTr("Según el sistema"), "Español", "English"]
                           onActivated: i => page.settings.languageIndex = i }
                SwitchRow { label: qsTr("Reducir movimiento"); checked: page.settings.reduceMotion
                            onToggled: page.settings.reduceMotion = checked }
            }
            Item { implicitHeight: Theme.s3 }
        }
    }
}
