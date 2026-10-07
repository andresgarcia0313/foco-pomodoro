import QtQuick
import QtQuick.Controls.impl

// Monochrome Lucide icon tinted with a theme color.
IconImage {
    property string glyph
    property int size: 20
    source: glyph ? Qt.resolvedUrl("icons/" + glyph + ".svg") : ""
    sourceSize: Qt.size(size, size)
    color: Theme.text
}
