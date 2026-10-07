import QtQuick

// Stand-in for the Rust PomodoroTimer, same QML-facing API.
QtObject {
    property int phase: 0
    property int state: 1          // 0 idle, 1 running, 2 paused
    property int totalSeconds: 25 * 60
    property int remainingSeconds: 24 * 60 + 13
    property int cycleLength: 4
    property int cycleDone: 1
    function toggle() { state = state === 1 ? 2 : 1 }
    function reset() { state = 0; remainingSeconds = totalSeconds }
    function skip() { phase = (phase + 1) % 3 }
    function selectPhase(p) { phase = p }
}
