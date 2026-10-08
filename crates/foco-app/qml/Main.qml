import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Dialogs
import QtMultimedia
import Foco
import FocoApp

// Wires the Rust objects into the interface: windows, tray, chime, export and the tick.
MainWindow {
    id: win
    timer: pomodoro
    tasks: taskStore
    stats: statsStore
    settings: appSettings
    trayAvailable: tray.available
    visible: true
    // --mute: never play the chime (tests, CI, shared rooms).
    readonly property bool muted: Qt.application.arguments.indexOf("--mute") >= 0
    property bool trayHintShown: false

    PomodoroTimer { id: pomodoro }
    TaskStore { id: taskStore }
    StatsStore { id: statsStore }
    AppSettings { id: appSettings; onApplied: pomodoro.sync() }

    Binding { target: Theme; property: "appearance"; value: appSettings.appearance }
    Binding { target: Theme; property: "reduceMotion"; value: appSettings.reduceMotion }

    Connections {
        target: pomodoro
        function onPhaseEnded(finished, next, counted) {
            if (counted) { taskStore.refresh(); statsStore.refresh() }
            if (appSettings.sound && !win.muted) chime.play()
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
    SoundEffect {
        id: chime
        source: "qrc:/qt/qml/FocoApp/assets/chime.wav"
        volume: appSettings.volume
    }

    Tray {
        id: tray
        timer: pomodoro
        onShowRequested: win.bringBack()
        onQuitRequested: win.quitRequested()
    }
    SettingsWindow { id: settingsWindow; settings: appSettings }
    MiniWindow {
        id: miniWindow
        timer: pomodoro
        onExpand: { miniWindow.hide(); win.bringBack() }
    }
    FileDialog {
        id: exportDialog
        title: qsTr("Exportar historial")
        fileMode: FileDialog.SaveFile
        defaultSuffix: "csv"
        nameFilters: [qsTr("CSV (*.csv)")]
        onAccepted: statsStore.exportCsv(selectedFile.toString())
    }

    function bringBack() {
        win.show(); win.raise(); win.requestActivate()
    }

    onSettingsRequested: { settingsWindow.show(); settingsWindow.raise(); settingsWindow.requestActivate() }
    onMiniRequested: { win.hide(); miniWindow.show() }
    onExportRequested: exportDialog.open()
    onQuitRequested: { win.quitting = true; Qt.quit() }
    onHiddenToTray: {
        if (trayHintShown) return
        trayHintShown = true
        tray.showMessage(qsTr("Foco"), qsTr("Foco sigue en la bandeja. Para cerrarlo del todo, usa Salir."))
    }
    onClosing: if (win.quitting || !appSettings.keepInTray || !tray.available) Qt.quit()
    onVisibleChanged: if (visible) statsStore.refresh()
}
