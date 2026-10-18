import QtQuick
import Quickshell
import "../shared/Theme.js" as Theme
import "../shared"

AnimatedPopup {
    id: popup
    required property var brightness

    implicitWidth: 280
    implicitHeight: 120
    color: "transparent"

    PopupFrame {
        id: popupBody
        anchors.fill: parent

        BarText {
            x: 16
            y: 14
            text: "Brightness"
        }
        BarText {
            anchors.right: parent.right
            anchors.rightMargin: 16
            y: 14
            text: popup.brightness === null ? "Unavailable" : Math.round(slider.value) + "%"
        }

        StyledSlider {
            id: slider
            x: 16
            y: 40
            width: parent.width - 32
            height: 28
            from: 0
            to: 100
            stepSize: 1
            enabled: popup.brightness !== null
            value: popup.brightness === null ? 0 : popup.brightness
            onMoved: Quickshell.execDetached([
                "python3",
                Quickshell.shellPath("scripts/osd-control.py"),
                "brightness",
                "set",
                Math.round(value).toString()
            ])
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

    animatedItem: popupBody
}
