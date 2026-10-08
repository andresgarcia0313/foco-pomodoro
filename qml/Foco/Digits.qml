import QtQuick

// Text whose digits share one width (tabular figures, Qt 6.6+), so a running clock does not
// jitter; Qt 6.4 and 6.5 keep proportional digits instead of failing to load.
Text {
    Component.onCompleted: if (font.features !== undefined) font.features = { "tnum": 1 }
}
