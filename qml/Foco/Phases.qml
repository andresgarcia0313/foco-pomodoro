pragma Singleton
import QtQuick

// Visible names and formatting shared by every view.
QtObject {
    readonly property var names: [qsTr("Enfoque"), qsTr("Descanso"), qsTr("Descanso largo")]

    readonly property var shortNames: [qsTr("Enfoque"), qsTr("Corto"), qsTr("Largo")]

    function name(phase) { return names[phase] ?? names[0] }

    function clock(seconds) {
        const s = Math.max(0, Math.round(seconds))
        const mm = Math.floor(s / 60), ss = s % 60
        return (mm < 10 ? "0" : "") + mm + ":" + (ss < 10 ? "0" : "") + ss
    }

    // Spanish and English only need one/many; both strings stay translatable.
    function count(n, one, many) { return (n === 1 ? one : many).arg(n) }
    function focuses(n) { return count(n, qsTr("%1 enfoque"), qsTr("%1 enfoques")) }
    function days(n) { return count(n, qsTr("%1 día seguido"), qsTr("%1 días seguidos")) }

    function duration(minutes) {
        const h = Math.floor(minutes / 60), m = minutes % 60
        if (h === 0) return qsTr("%1 min").arg(m)
        return m === 0 ? qsTr("%1 h").arg(h) : qsTr("%1 h %2 min").arg(h).arg(m)
    }
}
