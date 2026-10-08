import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Read-only cheat sheet of the keyboard map.
ThemedDialog {
    title: qsTr("Atajos de teclado")
    readonly property var rows: [
        [qsTr("Iniciar o pausar"), qsTr("Espacio")],
        [qsTr("Reiniciar fase"), "Ctrl+R"],
        [qsTr("Añadir o quitar un minuto"), "+ · -"],
        [qsTr("Saltar fase"), "Ctrl+Shift+S"],
        [qsTr("Ir a Temporizador, Tareas, Estadísticas"), "Ctrl+1 · 2 · 3"],
        [qsTr("Nueva tarea"), "Ctrl+N"],
        [qsTr("Deshacer eliminación"), "Ctrl+Z"],
        [qsTr("Ajustes"), "Ctrl+,"],
        [qsTr("Modo mini"), "Ctrl+Shift+M"],
        [qsTr("Cerrar a la bandeja"), "Ctrl+W"],
        [qsTr("Salir"), "Ctrl+Q"]]
    GridLayout {
        columns: 2
        columnSpacing: Theme.s5
        rowSpacing: Theme.s2
        Repeater {
            model: rows.length * 2
            delegate: Text {
                required property int index
                text: rows[Math.floor(index / 2)][index % 2]
                color: index % 2 ? Theme.accent : Theme.text
                font.pointSize: Theme.body
                font.family: index % 2 ? "monospace" : Qt.application.font.family
            }
        }
    }
}
