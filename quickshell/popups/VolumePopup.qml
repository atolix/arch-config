import QtQuick
import QtQuick.Controls
import Quickshell
import "../shared/Theme.js" as Theme
import "../shared"

AnimatedPopup {
    id: popup
    required property var audio
    implicitWidth: 280
    implicitHeight: 120
    color: "transparent"

    PopupFrame {
        id: popupBody
        anchors.fill: parent

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

        Slider {
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
            background: Rectangle {
                x: slider.leftPadding
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                width: slider.availableWidth
                height: 4
                radius: 2
                color: Theme.border
                Rectangle {
                    width: slider.visualPosition * parent.width
                    height: parent.height
                    radius: 2
                    color: slider.enabled ? Theme.accent : "#666666"
                }
            }
            handle: Rectangle {
                x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                width: 14
                height: 14
                radius: 7
                color: slider.pressed ? Theme.white : Theme.accent
            }
        }

        Button {
            x: 16
            y: 78
            width: 110
            height: 28
            enabled: popup.audio !== null
            onClicked: popup.audio.muted = !popup.audio.muted
            contentItem: BarText {
                text: popup.audio?.muted ? "Unmute" : "Mute"
                horizontalAlignment: Text.AlignHCenter
            }
            background: Rectangle { radius: 5; color: parent.down ? Theme.buttonHover : Theme.button }
        }
        Button {
            anchors.right: parent.right
            anchors.rightMargin: 16
            y: 78
            width: 60
            height: 28
            onClicked: popup.opened = false
            contentItem: BarText { text: "Close"; horizontalAlignment: Text.AlignHCenter }
            background: Rectangle { radius: 5; color: parent.down ? Theme.buttonHover : Theme.button }
        }
    }

    animatedItem: popupBody
}
