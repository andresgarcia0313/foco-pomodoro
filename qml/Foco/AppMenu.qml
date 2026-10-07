import QtQuick
import QtQuick.Controls

// App menu (hamburger on Windows and KDE). Every command here also has a shortcut.
ThemedMenu {
    id: menu
    property bool alwaysOnTop: false
    signal settingsRequested()
    signal miniRequested()
    signal alwaysOnTopToggled()
    signal exportRequested()
    signal shortcutsRequested()
    signal aboutRequested()
    signal quitRequested()

    ThemedMenuItem { text: qsTr("Ajustes…"); onTriggered: menu.settingsRequested() }
    ThemedMenuItem { text: qsTr("Modo mini"); onTriggered: menu.miniRequested() }
    ThemedMenuItem { text: qsTr("Siempre encima"); checkable: true; checked: menu.alwaysOnTop
                     onTriggered: menu.alwaysOnTopToggled() }
    MenuSeparator {}
    ThemedMenuItem { text: qsTr("Exportar historial…"); onTriggered: menu.exportRequested() }
    ThemedMenuItem { text: qsTr("Atajos de teclado"); onTriggered: menu.shortcutsRequested() }
    ThemedMenuItem { text: qsTr("Acerca de Foco"); onTriggered: menu.aboutRequested() }
    MenuSeparator {}
    ThemedMenuItem { text: qsTr("Salir"); onTriggered: menu.quitRequested() }
}
