import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ThemedDialog {
    title: qsTr("Acerca de Foco")
    ColumnLayout {
        spacing: Theme.s2
        Text { text: qsTr("Foco %1").arg(Qt.application.version); color: Theme.text
               font.pointSize: Theme.body; font.weight: Font.DemiBold }
        Text { text: qsTr("Técnica Pomodoro para concentrarte sin mirar el reloj.")
               color: Theme.textMuted; font.pointSize: Theme.body }
        Text { text: qsTr("Rust, Qt 6 y la paleta Dracula. Licencia GPL 3.0 o posterior.")
               color: Theme.textMuted; font.pointSize: Theme.caption }
    }
}
