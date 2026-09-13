import QtQuick
import Quickshell.Services.UPower

Item {
    id: icon
    required property var battery
    readonly property bool available: battery.ready && battery.isPresent
    readonly property real level: available ? Math.max(0, Math.min(1, battery.percentage)) : 0
    readonly property bool charging: available && (battery.state === UPowerDeviceState.Charging || battery.state === UPowerDeviceState.PendingCharge)
    readonly property color levelColor: charging ? "#a6e3a1" : level <= 0.15 ? "#f38ba8" : level <= 0.3 ? "#f9e2af" : "#eaeaea"

    implicitWidth: 28
    implicitHeight: 22
    visible: available

    onAvailableChanged: canvas.requestPaint()
    onLevelChanged: canvas.requestPaint()
    onChargingChanged: canvas.requestPaint()
    onLevelColorChanged: canvas.requestPaint()

    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            ctx.lineWidth = 1.5;
            ctx.lineJoin = "round";

            // Battery outline and positive terminal.
            ctx.strokeStyle = icon.levelColor.toString();
            ctx.strokeRect(2.5, 5.5, 20, 11);
            ctx.fillStyle = icon.levelColor.toString();
            ctx.fillRect(23.5, 8.5, 2, 5);

            // Charge level, with a small inset so the outline remains clear.
            ctx.fillRect(4.5, 7.5, 16 * icon.level, 7);

            if (icon.charging) {
                // A contrasting bolt remains visible at every charge level.
                ctx.fillStyle = "#181a22";
                ctx.beginPath();
                ctx.moveTo(14.5, 3.5);
                ctx.lineTo(9.5, 11.5);
                ctx.lineTo(13, 11.5);
                ctx.lineTo(11.5, 18.5);
                ctx.lineTo(18, 9.5);
                ctx.lineTo(14.2, 9.5);
                ctx.closePath();
                ctx.fill();
                ctx.strokeStyle = "#f9e2af";
                ctx.lineWidth = 1;
                ctx.stroke();
            }
        }
    }
}
