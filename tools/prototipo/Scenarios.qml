pragma Singleton
import QtQuick

QtObject {
    readonly property var list: [
        { name: "01-temporizador-enfoque-dracula" },
        { name: "02-temporizador-pausa-dracula", state: 2 },
        { name: "03-temporizador-descanso-dracula", phase: 1, remaining: 3 * 60 + 41, cycleDone: 2 },
        { name: "04-temporizador-descanso-largo-dracula", phase: 2, remaining: 12 * 60, cycleDone: 4 },
        { name: "05-tareas-dracula", section: 1, undo: true },
        { name: "06-estadisticas-dracula", section: 2 },
        { name: "07-temporizador-alucard", appearance: 1 },
        { name: "08-tareas-alucard", appearance: 1, section: 1 },
        { name: "09-estadisticas-alucard", appearance: 1, section: 2 },
        { name: "10-minima-340x520", w: 340, h: 520, noActive: true, state: 0, remaining: 1500 },
        { name: "11-tareas-vacias", section: 1, emptyTasks: true },
        { name: "12-estadisticas-vacias", section: 2, emptyStats: true },
        { name: "13-letra-doble-minima", w: 340, h: 520, fontScale: 2 }
    ]
}
