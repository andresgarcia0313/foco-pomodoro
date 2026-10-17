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
        { name: "13-letra-doble-minima", w: 340, h: 520, fontScale: 2 },
        { name: "14-ajustes-dracula", kind: "settings", w: 460, h: 900 },
        { name: "15-ajustes-alucard", kind: "settings", appearance: 1, w: 460, h: 900 },
        { name: "16-mini-dracula", kind: "mini", w: 260, h: 96 },
        { name: "17-mini-descanso-alucard", kind: "mini", appearance: 1, phase: 1, w: 260, h: 96 },
        { name: "18-descanso-pregunta-dracula", kind: "break", step: "review", phase: 1,
          remaining: 4 * 60 + 52, cycleDone: 2, w: 1280, h: 800 },
        { name: "19-descanso-cuenta-dracula", kind: "break", step: "rest", phase: 1,
          remaining: 3 * 60 + 7, cycleDone: 2, w: 1280, h: 800 },
        { name: "20-descanso-siguiente-dracula", kind: "break", step: "next", phase: 0, state: 0,
          remaining: 25 * 60, cycleDone: 2, w: 1280, h: 800 },
        { name: "21-descanso-otra-pantalla", kind: "break", questions: false, phase: 2,
          remaining: 14 * 60 + 30, cycleDone: 4, w: 1280, h: 800 },
        { name: "22-descanso-pregunta-alucard", kind: "break", step: "review", appearance: 1,
          phase: 1, remaining: 4 * 60 + 52, cycleDone: 2, w: 1280, h: 800 },
        { name: "24-descanso-terminado-otra-pantalla", kind: "break", questions: false, phase: 0,
          state: 0, remaining: 25 * 60, w: 1280, h: 800 },
        { name: "23-descanso-letra-doble", kind: "break", step: "next", phase: 0, state: 0,
          fontScale: 2, remaining: 25 * 60, w: 1024, h: 640 }
    ]
}
