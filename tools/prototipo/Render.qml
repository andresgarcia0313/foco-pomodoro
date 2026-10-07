import QtQuick
import Foco

// Renders every design scenario to PNG for visual review (docs/03-ui-ux/galeria).
Window {
    id: win
    visible: true
    color: "black"
    property string out: Qt.application.arguments[Qt.application.arguments.length - 1]
    property var scenarios: Scenarios.list
    property int i: -1

    Loader { id: loader; anchors.fill: parent }

    function next() {
        i++
        if (i >= scenarios.length) { Qt.quit(); return }
        const s = scenarios[i]
        Theme.appearance = s.appearance ?? 0
        Theme.basePt = (s.fontScale ?? 1) * 10
        win.width = s.w ?? 400; win.height = s.h ?? 640
        loader.setSource("Scene.qml", { config: s })
        shot.restart()
    }
    Timer {
        id: shot; interval: 350
        onTriggered: if (!loader.item) { console.log("FALLA", win.scenarios[win.i].name); win.next() }
        else loader.item.grabToImage(r => {
            r.saveToFile(win.out + "/" + win.scenarios[win.i].name + ".png")
            console.log("ok", win.scenarios[win.i].name)
            win.next()
        })
    }
    Component.onCompleted: next()
}
