import QtQuick
import Quickshell.Services.UPower
import "Theme.js" as Theme

Item {
    id: icon
    required property var battery
    readonly property bool available: battery.ready && battery.isPresent
    readonly property real level: available ? Math.max(0, Math.min(1, battery.percentage)) : 0
    readonly property bool charging: available && (battery.state === UPowerDeviceState.Charging || battery.state === UPowerDeviceState.PendingCharge)
    readonly property color levelColor: charging ? Theme.success : level <= 0.15 ? Theme.danger : level <= 0.3 ? Theme.warning : Theme.text

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

            function roundedRect(x, y, width, height, radius, fill) {
                const r = Math.min(radius, width / 2, height / 2);
                ctx.beginPath();
                ctx.moveTo(x + r, y);
                ctx.lineTo(x + width - r, y);
                ctx.quadraticCurveTo(x + width, y, x + width, y + r);
                ctx.lineTo(x + width, y + height - r);
                ctx.quadraticCurveTo(x + width, y + height, x + width - r, y + height);
                ctx.lineTo(x + r, y + height);
                ctx.quadraticCurveTo(x, y + height, x, y + height - r);
                ctx.lineTo(x, y + r);
                ctx.quadraticCurveTo(x, y, x + r, y);
                ctx.closePath();
                fill ? ctx.fill() : ctx.stroke();
            }

            // Battery outline and positive terminal.
            ctx.strokeStyle = icon.levelColor.toString();
            roundedRect(2.5, 5.5, 20, 11, 3, false);
            ctx.fillStyle = icon.levelColor.toString();
            roundedRect(23.5, 8.5, 2, 5, 1, true);

            // Charge level, with a small inset so the outline remains clear.
            if (icon.level > 0)
                roundedRect(4.5, 7.5, 16 * icon.level, 7, 1.8, true);
        }
    }
}
