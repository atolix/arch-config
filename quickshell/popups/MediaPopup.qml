import QtQuick
import QtQuick.Controls
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
    color: "transparent"

    Timer {
        interval: 1000
        repeat: true
        running: popup.opened && (popup.player?.isPlaying ?? false)
        onTriggered: if (popup.player?.positionSupported) popup.player.positionChanged()
    }

    component ControlButton: Button {
        required property string iconText
        width: 38
        height: 32
        contentItem: BarText {
            text: parent.iconText
            color: parent.enabled ? Theme.text : Theme.muted
            font.family: "JetBrainsMono Nerd Font Mono"
            font.pixelSize: 17
            horizontalAlignment: Text.AlignHCenter
        }
        background: Rectangle {
            radius: 7
            color: !parent.enabled ? "transparent" : parent.down ? Theme.buttonHover : parent.hovered ? Theme.border : Theme.button
        }
    }

    Rectangle {
        id: popupBody
        anchors.fill: parent
        color: Theme.surface
        radius: 10
        border.color: Theme.border

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
                color: "#c6c9d4"
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

        Slider {
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

            background: Rectangle {
                x: positionSlider.leftPadding
                y: positionSlider.topPadding + positionSlider.availableHeight / 2 - height / 2
                width: positionSlider.availableWidth
                height: 4
                radius: 2
                color: Theme.border
                Rectangle {
                    width: positionSlider.visualPosition * parent.width
                    height: parent.height
                    radius: 2
                    color: Theme.accent
                }
            }
            handle: Rectangle {
                x: positionSlider.leftPadding + positionSlider.visualPosition * (positionSlider.availableWidth - width)
                y: positionSlider.topPadding + positionSlider.availableHeight / 2 - height / 2
                width: 12
                height: 12
                radius: 6
                color: positionSlider.pressed ? Theme.white : Theme.accent
            }
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

    animatedItem: popupBody
}
