import QtQuick
import QtQuick.Controls

// Main window: shell, app menu, shortcuts. Closing hides to the tray when enabled.
ApplicationWindow {
    id: win
    required property QtObject timer
    required property QtObject tasks
    required property QtObject stats
    required property QtObject settings
    property bool quitting: false
    signal settingsRequested()
    signal miniRequested()
    signal exportRequested()
    signal quitRequested()
    signal hiddenToTray()

    title: qsTr("Foco")
    width: 400; height: 640
    minimumWidth: Math.max(340, Theme.basePt * 26)
    minimumHeight: 520
    color: Theme.base
    flags: Qt.Window | (settings.alwaysOnTop ? Qt.WindowStaysOnTopHint : 0)

    AppShell {
        id: shell
        anchors.fill: parent
        timer: win.timer; tasks: win.tasks; stats: win.stats
        onMenuRequested: menu.popup(shell.menuButton, shell.menuButton.width - menu.width,
                                    shell.menuButton.height)
    }
    AppMenu {
        id: menu
        alwaysOnTop: win.settings.alwaysOnTop
        onSettingsRequested: win.settingsRequested()
        onMiniRequested: win.miniRequested()
        onAlwaysOnTopToggled: win.settings.alwaysOnTop = !win.settings.alwaysOnTop
        onExportRequested: win.exportRequested()
        onShortcutsRequested: shortcutsDialog.open()
        onAboutRequested: aboutDialog.open()
        onQuitRequested: win.quitRequested()
    }
    WindowShortcuts {
        window: win
        timer: win.timer
        tasks: win.tasks
        shell: shell
    }
    ShortcutsDialog { id: shortcutsDialog }
    AboutDialog { id: aboutDialog }

    onClosing: close => {
        if (!quitting && settings.keepInTray) {
            close.accepted = false
            win.hide()
            win.hiddenToTray()
        }
    }
}
