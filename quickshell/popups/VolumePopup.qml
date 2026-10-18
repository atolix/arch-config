import QtQuick
import Quickshell
import "../shared/Theme.js" as Theme
import "../shared"

AnimatedPopup {
    id: popup
    required property var audio
    implicitWidth: 280
    implicitHeight: 120

        BarText {
            x: 16
            y: 14
            text: "Volume"
        }
        BarText {
            anchors.right: parent.right
            anchors.rightMargin: 16
            y: 14
            text: !popup.audio ? "No output" : popup.audio.muted ? "Muted" : Math.round(popup.audio.volume * 100) + "%"
        }

        StyledSlider {
            id: slider
            x: 16
            y: 40
            width: parent.width - 32
            height: 28
            from: 0
            to: 1
            stepSize: 0.01
            enabled: popup.audio !== null
            value: popup.audio ? popup.audio.volume : 0
            onMoved: {
                if (popup.audio) {
                    popup.audio.volume = value;
                    popup.audio.muted = false;
                }
            }
        }

        PopupButton {
            x: 16
            y: 78
            width: 110
            height: 28
            enabled: popup.audio !== null
            onClicked: popup.audio.muted = !popup.audio.muted
            text: popup.audio?.muted ? "Unmute" : "Mute"
            hoverColor: Theme.button
        }
        PopupButton {
            anchors.right: parent.right
            anchors.rightMargin: 16
            y: 78
            width: 60
            height: 28
            onClicked: popup.opened = false
            text: "Close"
            hoverColor: Theme.button
        }
}
