pragma Singleton
import QtQuick

// Design tokens. Source of truth for docs/03-ui-ux/sistema-de-diseno.md.
QtObject {
    id: theme

    // 0 = Dracula, 1 = Alucard, 2 = follow the system appearance
    property int appearance: 0
    property bool reduceMotion: false
    readonly property bool dark: appearance === 0
        || (appearance === 2 && Qt.styleHints.colorScheme !== Qt.Light)

    readonly property color base: dark ? "#282A36" : "#FFFBEB"
    readonly property color raised: dark ? "#343746" : "#EFEDDC"
    readonly property color hover: dark ? "#424450" : "#ECE9DF"
    readonly property color selected: dark ? "#44475A" : "#DEDCCF"
    readonly property color text: dark ? "#F8F8F2" : "#1F1F1F"
    readonly property color textMuted: dark ? "#B6BCD8" : "#5C5848"
    readonly property color border: dark ? "#6272A4" : "#6C664B"
    readonly property color accent: dark ? "#BD93F9" : "#644AC9"
    readonly property color accentLabel: dark ? "#282A36" : "#FFFBEB"
    readonly property color focusPhase: dark ? "#FF79C6" : "#A3144D"
    readonly property color shortBreak: dark ? "#50FA7B" : "#14710A"
    readonly property color longBreak: dark ? "#8BE9FD" : "#036A96"
    readonly property color danger: dark ? "#FF5555" : "#CB3A2A"

    function phaseColor(phase) {
        return phase === 1 ? shortBreak : phase === 2 ? longBreak : focusPhase
    }
    function tint(color, alpha) {
        return Qt.rgba(color.r, color.g, color.b, alpha)
    }

    // Type scale relative to the system font so the OS text size setting is respected.
    property real basePt: Qt.application.font.pointSize > 0
        ? Qt.application.font.pointSize : 10
    readonly property real display: basePt * 5.2
    readonly property real displayMini: basePt * 2.4
    readonly property real title: basePt * 1.35
    readonly property real body: basePt
    readonly property real label: basePt * 0.92
    readonly property real caption: Math.max(9, basePt * 0.85)

    readonly property int s1: 4
    readonly property int s2: 8
    readonly property int s3: 12
    readonly property int s4: 16
    readonly property int s5: 24
    readonly property int s6: 32
    readonly property int s7: 48

    readonly property int radiusControl: 6
    readonly property int radiusCard: 10
    readonly property int hit: 32

    readonly property int fast: reduceMotion ? 0 : 120
    readonly property int normal: reduceMotion ? 0 : 200
    readonly property int slow: reduceMotion ? 0 : 320
}
