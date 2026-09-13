import QtQuick

Item {
    id: icon
    required property string kind
    required property var signal
    readonly property bool wifi: kind === "wifi"
    readonly property bool connected: wifi || kind === "ethernet"
    readonly property int waveCount: wifi && signal !== null ? Math.max(0, Math.min(3, Math.ceil(signal / 34))) : 0
    readonly property color iconColor: connected ? "#eaeaea" : "#646978"

    implicitWidth: 24
    implicitHeight: 22

    onKindChanged: canvas.requestPaint()
    onSignalChanged: canvas.requestPaint()
    onIconColorChanged: canvas.requestPaint()

    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            ctx.strokeStyle = icon.iconColor.toString();
            ctx.fillStyle = icon.iconColor.toString();
            ctx.lineWidth = 1.5;
            ctx.lineCap = "round";
            ctx.lineJoin = "round";

            if (icon.wifi) {
                ctx.beginPath();
                ctx.arc(12, 18, 1.4, 0, Math.PI * 2);
                ctx.fill();
                for (let wave = 1; wave <= icon.waveCount; wave++) {
                    ctx.beginPath();
                    ctx.arc(12, 18, 3.5 + wave * 3, -2.35, -0.79);
                    ctx.stroke();
                }
            } else if (icon.kind === "ethernet") {
                ctx.strokeRect(5, 7, 14, 10);
                ctx.beginPath();
                ctx.moveTo(8, 17); ctx.lineTo(8, 20);
                ctx.moveTo(12, 17); ctx.lineTo(12, 20);
                ctx.moveTo(16, 17); ctx.lineTo(16, 20);
                ctx.stroke();
            } else {
                ctx.beginPath();
                ctx.moveTo(7, 7); ctx.lineTo(17, 17);
                ctx.moveTo(17, 7); ctx.lineTo(7, 17);
                ctx.stroke();
            }
        }
    }
}
