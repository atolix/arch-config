import QtQuick
import "Theme.js" as Theme

Item {
    id: icon
    required property var audio
    required property bool headphones
    property bool active: false
    readonly property bool available: audio !== null
    readonly property bool muted: available && audio.muted
    readonly property real volume: available ? audio.volume : 0
    readonly property int waveCount: muted || volume <= 0 ? 0 : Math.min(3, Math.ceil(volume * 3))
    readonly property color iconColor: active ? Theme.accent : available ? Theme.text : Theme.muted

    implicitWidth: 24
    implicitHeight: 22

    onAvailableChanged: canvas.requestPaint()
    onHeadphonesChanged: canvas.requestPaint()
    onMutedChanged: canvas.requestPaint()
    onWaveCountChanged: canvas.requestPaint()
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

            if (icon.headphones) {
                // Headband and ear cups.
                ctx.beginPath();
                ctx.arc(12, 11, 7, -Math.PI, 0);
                ctx.stroke();
                ctx.lineWidth = 3.5;
                ctx.beginPath();
                ctx.moveTo(5, 11);
                ctx.lineTo(5, 16);
                ctx.moveTo(19, 11);
                ctx.lineTo(19, 16);
                ctx.stroke();

                if (icon.muted) {
                    ctx.lineWidth = 1.5;
                    ctx.beginPath();
                    ctx.moveTo(9, 9);
                    ctx.lineTo(15, 15);
                    ctx.moveTo(15, 9);
                    ctx.lineTo(9, 15);
                    ctx.stroke();
                }
                return;
            }

            // Speaker body.
            ctx.beginPath();
            ctx.moveTo(2, 8);
            ctx.lineTo(5, 8);
            ctx.lineTo(9, 4.5);
            ctx.lineTo(9, 17.5);
            ctx.lineTo(5, 14);
            ctx.lineTo(2, 14);
            ctx.closePath();
            ctx.fill();

            if (icon.muted) {
                ctx.beginPath();
                ctx.moveTo(13, 7);
                ctx.lineTo(19, 15);
                ctx.moveTo(19, 7);
                ctx.lineTo(13, 15);
                ctx.stroke();
                return;
            }

            // One wave for low, two for medium, three for high volume.
            for (let wave = 1; wave <= icon.waveCount; wave++) {
                ctx.beginPath();
                ctx.arc(8.5, 11, 2.5 + wave * 2.5, -0.65, 0.65);
                ctx.stroke();
            }
        }
    }
}
