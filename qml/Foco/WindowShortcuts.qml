import QtQuick

// Keyboard map from docs/03-ui-ux/textos.md. Ctrl reads as Cmd on macOS.
Item {
    id: keys
    required property var window
    required property QtObject timer
    required property QtObject tasks
    required property Item shell
    readonly property bool typing: window.activeFocusItem
        && window.activeFocusItem.hasOwnProperty("cursorPosition")

    Shortcut { sequence: "Space"; enabled: !keys.typing; onActivated: keys.timer.toggle() }
    Shortcut { sequence: "Ctrl+R"; onActivated: keys.timer.reset() }
    Shortcut { sequences: ["+", "="]; enabled: !keys.typing; onActivated: keys.timer.adjust(1) }
    Shortcut { sequence: "-"; enabled: !keys.typing; onActivated: keys.timer.adjust(-1) }
    Shortcut { sequence: "Ctrl+Shift+S"; onActivated: keys.timer.skip() }
    Shortcut { sequence: "Ctrl+1"; onActivated: keys.shell.section = 0 }
    Shortcut { sequence: "Ctrl+2"; onActivated: keys.shell.section = 1 }
    Shortcut { sequence: "Ctrl+3"; onActivated: keys.shell.section = 2 }
    Shortcut { sequences: [StandardKey.New]; onActivated: keys.shell.showTasksInput() }
    Shortcut { sequences: [StandardKey.Undo]; enabled: keys.tasks.canUndo && !keys.typing
               onActivated: keys.tasks.undoRemove() }
    Shortcut { sequences: [StandardKey.Preferences]; onActivated: keys.window.settingsRequested() }
    Shortcut { sequence: "Ctrl+Shift+M"; onActivated: keys.window.miniRequested() }
    Shortcut { sequences: [StandardKey.Close]; onActivated: keys.window.close() }
    Shortcut { sequences: [StandardKey.Quit, "Ctrl+Q"]; onActivated: keys.window.quitRequested() }
}
