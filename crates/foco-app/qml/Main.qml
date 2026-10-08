import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Dialogs
import Foco
import FocoApp
// QtCore's Settings needs Qt 6.5; the labs one also runs on the 6.4 of Debian 12.
import Qt.labs.settings

// Wires the Rust objects into the interface: windows, tray, chime, export and the tick.
MainWindow {
    id: win
    timer: pomodoro
    tasks: taskStore
    stats: statsStore
    settings: appSettings
    trayAvailable: tray.available
    visible: false
    // --mute: never play the chime (tests, CI, shared rooms).
    readonly property bool muted: Qt.application.arguments.indexOf("--mute") >= 0
    property bool trayHintShown: false

    PomodoroTimer { id: pomodoro }
    TaskStore { id: taskStore }
    StatsStore { id: statsStore }
    AppSettings { id: appSettings; onApplied: pomodoro.sync() }
    AppServices { id: services }
    // Window size and mode come back exactly as they were left.
    Settings {
        id: uiState
        fileName: services.stateFile
        property bool mini: false
        property alias width: win.width
        property alias height: win.height
    }

    Binding { target: Theme; property: "appearance"; value: appSettings.appearance }
    Binding { target: Theme; property: "reduceMotion"; value: appSettings.reduceMotion }

    Connections {
        target: pomodoro
        function onPhaseEnded(finished, next, counted) {
            if (counted) { taskStore.refresh(); statsStore.refresh() }
            if (chime.item) chime.item.play()
        }
    }
    Timer {
        interval: 250; repeat: true
        running: pomodoro.state === 1
        onTriggered: pomodoro.tick()
    }
    Timer {
        interval: 6000
        running: taskStore.canUndo
        onTriggered: taskStore.commitRemove()
    }
    Timer { interval: 5000; repeat: true; running: true; onTriggered: services.beat() }
    // Wayland drops keep-above whenever a window is hidden, so it is set again on every show.
    Timer {
        id: aboveSync
        interval: 300
        onTriggered: {
            if (win.visible) services.keepAbove(win.title, appSettings.alwaysOnTop)
            if (miniWindow.visible) services.keepAbove(miniWindow.title, true)
        }
    }
    Loader {
        id: chime
        active: appSettings.sound && !win.muted
        source: "Chime.qml"
    }
    Binding { target: chime.item; property: "volume"; value: appSettings.volume; when: chime.item !== null }

    Tray {
        id: tray
        timer: pomodoro
        onShowRequested: { services.track("tray_show"); win.bringBack() }
        onQuitRequested: win.quitRequested()
    }
    SettingsWindow { id: settingsWindow; settings: appSettings }
    MiniWindow {
        id: miniWindow
        timer: pomodoro
        onExpand: { services.track("mini_expand"); win.bringBack() }
        onVisibleChanged: aboveSync.restart()
    }
    FileDialog {
        id: exportDialog
        title: qsTr("Exportar historial")
        fileMode: FileDialog.SaveFile
        defaultSuffix: "csv"
        nameFilters: [qsTr("CSV (*.csv)")]
        onAccepted: { services.track("export"); statsStore.exportCsv(selectedFile.toString()) }
    }

    // Full window and mini mode are exclusive: showing one always hides the other.
    function bringBack() {
        miniWindow.hide(); uiState.mini = false
        win.show(); win.raise(); win.requestActivate()
    }
    function showMini() {
        win.hide(); uiState.mini = true
        miniWindow.show(); miniWindow.raise()
    }

    Component.onCompleted: {
        services.beat()
        if (uiState.mini) showMini(); else win.show()
    }
    onSettingsRequested: {
        services.track("settings_open")
        settingsWindow.show(); settingsWindow.raise(); settingsWindow.requestActivate()
    }
    onMiniRequested: { services.track("mini"); showMini() }
    onExportRequested: exportDialog.open()
    onQuitRequested: { win.quitting = true; Qt.quit() }
    onHiddenToTray: {
        if (trayHintShown) return
        trayHintShown = true
        tray.showMessage(qsTr("Foco"), qsTr("Foco sigue en la bandeja. Para cerrarlo del todo, usa Salir."))
    }
    onClosing: if (win.quitting || !appSettings.keepInTray || !tray.available) Qt.quit()
    onVisibleChanged: { if (visible) statsStore.refresh(); aboveSync.restart() }
    Connections { target: appSettings; function onAlwaysOnTopChanged() { aboveSync.restart() } }
}
