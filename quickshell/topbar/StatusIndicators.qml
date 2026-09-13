import QtQuick
import Quickshell
import "../shared"

Row {
    id: root

    required property var audio
    required property var brightness
    required property var battery
    required property string input
    required property var percent
    required property var networkIcon
    required property var openVolumePopup

    readonly property alias volumeItem: volumeText

    spacing: 10

    BarText {
        width: 24
        height: 22
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        text: root.input
        Accessible.name: "Keyboard layout " + text
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: Quickshell.execDetached(["python3", Quickshell.shellPath("scripts/input-toggle.py")])
        }
    }

    VolumeIcon {
        id: volumeText
        audio: root.audio
        Accessible.name: "Volume"
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor
            onClicked: mouse => {
                if (mouse.button === Qt.RightButton) {
                    if (root.audio) root.audio.muted = !root.audio.muted;
                } else {
                    root.openVolumePopup();
                }
            }
            onWheel: wheel => {
                if (root.audio && wheel.angleDelta.y !== 0)
                    root.audio.volume = Math.max(0, Math.min(1, root.audio.volume + (wheel.angleDelta.y > 0 ? 0.05 : -0.05)));
            }
        }
    }

    BrightnessIcon {
        brightness: root.brightness
        Accessible.name: "Brightness"
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: Quickshell.execDetached(["python3", Quickshell.shellPath("scripts/osd-control.py"), "brightness", "show"])
        }
    }

    BatteryStatus {
        battery: root.battery
        percent: root.percent
    }

    BarText {
        height: 22
        verticalAlignment: Text.AlignVCenter
        width: 22
        horizontalAlignment: Text.AlignHCenter
        text: root.networkIcon()
        font.family: "JetBrainsMono Nerd Font Mono"
        font.pixelSize: 17
        Accessible.name: "Network"
    }
}
