import QtQuick

QtObject {
    property int focusMinutes: 25
    property int shortBreakMinutes: 5
    property int longBreakMinutes: 15
    property int longBreakEvery: 4
    property bool autoStartBreaks: false
    property bool autoStartFocus: true
    property bool notifications: true
    property bool sound: true
    property real volume: 0.6
    property bool keepInTray: true
    property bool alwaysOnTop: false
    property int appearance: 0
    property int languageIndex: 0
    property bool reduceMotion: false
}
