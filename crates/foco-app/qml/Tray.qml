import QtQuick
import Qt.labs.platform as Platform
import Foco

// Tray icon (RF-06): state and time in the tooltip; start or pause, skip, show and quit.
Platform.SystemTrayIcon {
    id: tray
    required property QtObject timer
    signal showRequested()
    signal quitRequested()

    visible: true
    icon.source: "qrc:/qt/qml/FocoApp/assets/foco.svg"
    tooltip: (timer.state === 2 ? qsTr("En pausa") : Phases.name(timer.phase))
             + " · " + Phases.clock(timer.remainingSeconds)
    onActivated: reason => {
        if (reason === Platform.SystemTrayIcon.Trigger) tray.showRequested()
    }

    menu: Platform.Menu {
        Platform.MenuItem {
            text: tray.timer.state === 1 ? qsTr("Pausar") : qsTr("Iniciar")
            onTriggered: tray.timer.toggle()
        }
        Platform.MenuItem { text: qsTr("Saltar fase"); onTriggered: tray.timer.skip() }
        Platform.MenuSeparator {}
        Platform.MenuItem { text: qsTr("Mostrar ventana"); onTriggered: tray.showRequested() }
        Platform.MenuItem { text: qsTr("Salir"); onTriggered: tray.quitRequested() }
    }
}
