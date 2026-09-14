import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import "../shared/Theme.js" as Theme
import "../shared"

PopupWindow {
    id: popup

    required property int durationSeconds
    required property int remainingSeconds
    required property bool running
    required property var setDuration
    required property var toggleTimer
    required property var resetTimer
    required property var clearTimer

    function formattedTime() {
        if (durationSeconds === 0)
            return "--:--";
        const minutes = Math.floor(remainingSeconds / 60);
        const seconds = remainingSeconds % 60;
        return minutes.toString().padStart(2, "0") + ":" + seconds.toString().padStart(2, "0");
    }

    implicitWidth: 286
    implicitHeight: 210
    color: "transparent"

    HyprlandFocusGrab {
        active: popup.visible
        windows: [popup]
        onCleared: popup.visible = false
    }

    component ActionButton: Button {
        required property string label
        width: 76
        height: 30
        contentItem: BarText {
            text: parent.label
            horizontalAlignment: Text.AlignHCenter
            color: parent.enabled ? Theme.text : Theme.muted
        }
        background: Rectangle {
            radius: 6
            color: !parent.enabled ? "transparent" : parent.down ? Theme.buttonHover : parent.hovered ? Theme.border : Theme.button
            border.color: parent.enabled ? "transparent" : Theme.border
        }
    }

    component PresetButton: Button {
        required property int minutes
        width: 54
        height: 28
        onClicked: popup.setDuration(minutes)
        contentItem: BarText {
            text: parent.minutes + "m"
            horizontalAlignment: Text.AlignHCenter
            color: popup.durationSeconds === parent.minutes * 60 ? "#181a22" : Theme.text
        }
        background: Rectangle {
            radius: 6
            color: popup.durationSeconds === parent.minutes * 60
                ? Theme.accent
                : parent.down ? Theme.buttonHover : parent.hovered ? Theme.border : Theme.button
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.surface
        radius: 10
        border.color: Theme.border

        BarText {
            anchors.top: parent.top
            anchors.topMargin: 14
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Timer"
            font.bold: true
        }

        BarText {
            anchors.top: parent.top
            anchors.topMargin: 38
            anchors.horizontalCenter: parent.horizontalCenter
            text: popup.formattedTime()
            color: popup.durationSeconds > 0 ? Theme.text : Theme.muted
            font.pixelSize: 32
            font.bold: true
        }

        Row {
            anchors.top: parent.top
            anchors.topMargin: 88
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8

            PresetButton { minutes: 5 }
            PresetButton { minutes: 15 }
            PresetButton { minutes: 25 }
            PresetButton { minutes: 45 }
        }

        Row {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 18
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8

            ActionButton {
                label: popup.running ? "Pause" : "Start"
                enabled: popup.durationSeconds > 0
                onClicked: popup.toggleTimer()
            }
            ActionButton {
                label: "Reset"
                enabled: popup.durationSeconds > 0
                onClicked: popup.resetTimer()
            }
            ActionButton {
                label: "Clear"
                enabled: popup.durationSeconds > 0
                onClicked: popup.clearTimer()
            }
        }
    }
}
