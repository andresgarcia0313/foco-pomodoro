import QtQuick

QtObject {
    property var items: [
        { id: 1, title: "Escribir informe trimestral", estimate: 4, done: 2, completed: false },
        { id: 2, title: "Revisar correos pendientes", estimate: 1, done: 0, completed: false },
        { id: 3, title: "Preparar la clase de Rust", estimate: 3, done: 1, completed: false },
        { id: 4, title: "Leer el capítulo 5", estimate: 2, done: 2, completed: true }
    ]
    property int activeId: 1
    property bool canUndo: false
    signal newRequested()
    function add(title, estimate) {}
    function toggleCompleted(id) {}
    function remove(id) {}
    function undoRemove() {}
    function setActive(id) { activeId = id }
}
