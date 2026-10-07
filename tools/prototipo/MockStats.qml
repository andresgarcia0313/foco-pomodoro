import QtQuick

QtObject {
    property int todayCount: 6
    property int todayMinutes: 150
    property int streak: 4
    property int weekCount: 21
    property int weekMinutes: 525
    property var week: [
        { label: "J", name: "jueves", count: 4, minutes: 100, today: false },
        { label: "V", name: "viernes", count: 1, minutes: 25, today: false },
        { label: "S", name: "sábado", count: 0, minutes: 0, today: false },
        { label: "D", name: "domingo", count: 2, minutes: 50, today: false },
        { label: "L", name: "lunes", count: 5, minutes: 125, today: false },
        { label: "M", name: "martes", count: 3, minutes: 75, today: false },
        { label: "M", name: "miércoles", count: 6, minutes: 150, today: true }
    ]
}
