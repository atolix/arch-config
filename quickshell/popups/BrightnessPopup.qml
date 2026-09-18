import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import "../shared/Theme.js" as Theme
import "../shared"

AnimatedPopup {
    id: popup
    required property var brightness

    implicitWidth: 280
    implicitHeight: 120
    color: "transparent"

    HyprlandFocusGrab {
        active: popup.opened
        windows: [popup]
        onCleared: popup.opened = false
    }

    Rectangle {
        id: popupBody
        anchors.fill: parent
        color: Theme.surface
        radius: 10
        border.color: Theme.border

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

        Slider {
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
