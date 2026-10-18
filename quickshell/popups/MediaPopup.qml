import QtQuick
import Quickshell
import "../shared/Theme.js" as Theme
import "../shared"

AnimatedPopup {
    id: popup

    required property var player

    function formattedTime(value) {
        if (!isFinite(value) || value < 0)
            return "--:--";
        const total = Math.floor(value);
        const minutes = Math.floor(total / 60);
        const seconds = total % 60;
        return minutes + ":" + seconds.toString().padStart(2, "0");
    }

    onPlayerChanged: if (player === null) opened = false
    onOpenedChanged: if (opened && player?.positionSupported) player.positionChanged()

    implicitWidth: 410
    implicitHeight: 190

    Timer {
        interval: 1000
        repeat: true
        running: popup.opened && (popup.player?.isPlaying ?? false)
        onTriggered: if (popup.player?.positionSupported) popup.player.positionChanged()
    }

    component ControlButton: PopupButton {
        required property string iconText
        width: 38
        height: 32
        text: iconText
        cornerRadius: 7
        disabledColor: "transparent"
        labelFontFamily: "JetBrainsMono Nerd Font Mono"
        labelPixelSize: 17
    }

        Rectangle {
            id: artFrame
            x: 16
            y: 16
            width: 118
            height: 118
            radius: 8
            color: Theme.button
            clip: true

            BarText {
                anchors.centerIn: parent
                visible: albumArt.status !== Image.Ready
                text: "󰎆"
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 34
                color: Theme.muted
            }

            Image {
                id: albumArt
                anchors.fill: parent
                source: popup.player?.trackArtUrl ?? ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
            }
        }

        Column {
            x: 152
            y: 15
            width: parent.width - x - 16
            spacing: 2

            BarText {
                width: parent.width
                height: 24
                text: popup.player?.trackTitle || "Unknown title"
                font.bold: true
                font.pixelSize: 15
                elide: Text.ElideRight
            }

            BarText {
                width: parent.width
                height: 20
                text: popup.player?.trackArtist || popup.player?.identity || "Unknown artist"
                color: Theme.secondaryText
                elide: Text.ElideRight
            }

            BarText {
                width: parent.width
                height: 18
                text: popup.player?.trackAlbum ?? ""
                color: Theme.muted
                font.pixelSize: 11
                elide: Text.ElideRight
            }
        }

        Row {
            x: 152
            y: 88
            spacing: 8

            ControlButton {
                iconText: "󰒮"
                enabled: popup.player?.canGoPrevious ?? false
                onClicked: popup.player.previous()
            }
            ControlButton {
                iconText: popup.player?.isPlaying ? "󰏤" : "󰐊"
                enabled: popup.player?.canTogglePlaying ?? false
                onClicked: popup.player.togglePlaying()
            }
            ControlButton {
                iconText: "󰒭"
                enabled: popup.player?.canGoNext ?? false
                onClicked: popup.player.next()
            }
        }

        StyledSlider {
            id: positionSlider
            x: 16
            y: 142
            width: parent.width - 32
            height: 24
            from: 0
            to: popup.player?.lengthSupported ? popup.player.length : 1
            value: popup.player?.positionSupported ? popup.player.position : 0
            enabled: (popup.player?.canSeek ?? false) && (popup.player?.positionSupported ?? false)
                && (popup.player?.lengthSupported ?? false)
            onMoved: popup.player.position = value
            handleSize: 12
            disabledFillColor: Theme.accent
        }

        BarText {
            x: 16
            y: 166
            text: popup.formattedTime(popup.player?.position ?? -1)
            color: Theme.muted
            font.pixelSize: 10
        }

        BarText {
            anchors.right: parent.right
            anchors.rightMargin: 16
            y: 166
            text: popup.formattedTime(popup.player?.length ?? -1)
            color: Theme.muted
            font.pixelSize: 10
        }
}
