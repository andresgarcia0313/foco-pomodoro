import QtQuick
import QtQuick.Shapes

// Signature element: inner arc = phase progress, outer segments = focus cycle.
Item {
    id: ring
    property real progress: 0          // 0..1 elapsed in the current phase
    property int cycleLength: 4
    property int cycleDone: 0
    property color color: Theme.focusPhase
    property bool paused: false
    property real stroke: Math.max(8, width * 0.042)

    readonly property real cx: width / 2
    readonly property real cy: height / 2
    readonly property real arcRadius: width / 2 - stroke / 2 - 14
    readonly property real cycleRadius: width / 2 - 2
    readonly property color activeColor: paused ? Theme.textMuted : color

    Accessible.role: Accessible.ProgressBar

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath { // track
            strokeColor: Theme.selected
            strokeWidth: ring.stroke
            fillColor: "transparent"
            PathAngleArc {
                centerX: ring.cx; centerY: ring.cy
                radiusX: ring.arcRadius; radiusY: ring.arcRadius
                startAngle: 0; sweepAngle: 360
            }
        }
        ShapePath { // remaining time, drains clockwise from 12 o'clock
            strokeColor: ring.activeColor
            strokeWidth: ring.stroke
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"
            PathAngleArc {
                centerX: ring.cx; centerY: ring.cy
                radiusX: ring.arcRadius; radiusY: ring.arcRadius
                startAngle: -90 + 360 * ring.progress
                sweepAngle: 360 * (1 - ring.progress)
            }
        }
    }

    Repeater { // cycle segments
        model: ring.cycleLength
        delegate: Shape {
            required property int index
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer
            readonly property real gap: 6
            readonly property real span: 360 / ring.cycleLength
            ShapePath {
                strokeColor: index < ring.cycleDone ? ring.color : Theme.selected
                strokeWidth: 3
                capStyle: ShapePath.RoundCap
                fillColor: "transparent"
                PathAngleArc {
                    centerX: ring.cx; centerY: ring.cy
                    radiusX: ring.cycleRadius; radiusY: ring.cycleRadius
                    startAngle: -90 + index * span + gap / 2
                    sweepAngle: span - gap
                }
            }
        }
    }
}
