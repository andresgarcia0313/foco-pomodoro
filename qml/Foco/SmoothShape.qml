import QtQuick
import QtQuick.Shapes

// Shape with the curve renderer (smooth arcs, Qt 6.6+) when it exists; Qt 6.4 and 6.5 keep
// the default renderer instead of failing to load the whole interface.
Shape {
    id: shape
    Component.onCompleted: if (shape.preferredRendererType !== undefined)
        shape.preferredRendererType = Shape.CurveRenderer
}
