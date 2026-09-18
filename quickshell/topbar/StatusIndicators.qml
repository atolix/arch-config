import QtQuick
import Quickshell
import "../shared/Theme.js" as Theme
import "../shared"

Row {
    id: root

    required property var audio
    required property bool headphonesConnected
    required property var brightness
    required property var battery
    required property string input
    required property var percent
    required property var networkIcon
    required property var openVolumePopup
    required property var openBrightnessPopup
    required property int notificationCount
    required property var openNotifications

    readonly property alias volumeItem: volumeText
    readonly property alias brightnessItem: brightnessIcon

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
        headphones: root.headphonesConnected
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
        id: brightnessIcon
        brightness: root.brightness
        Accessible.name: "Brightness"
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.openBrightnessPopup()
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

    Item {
        width: root.notificationCount > 0 ? 30 : 22
        height: 22
        Accessible.name: root.notificationCount > 0
            ? "Notifications, " + root.notificationCount + " unread"
            : "Notifications"

        BarText {
            anchors.left: parent.left
            width: 22
            height: 22
            horizontalAlignment: Text.AlignHCenter
            text: "󰂚"
            font.family: "JetBrainsMono Nerd Font Mono"
            font.pixelSize: 17
            color: root.notificationCount > 0 ? Theme.accent : Theme.text
        }

        Rectangle {
            visible: root.notificationCount > 0
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: -2
            width: Math.max(14, countText.implicitWidth + 6)
            height: 14
            radius: 7
            color: Theme.danger

            BarText {
                id: countText
                anchors.centerIn: parent
                text: root.notificationCount > 99 ? "99+" : root.notificationCount.toString()
                color: "#181a22"
                font.pixelSize: 9
                font.bold: true
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.openNotifications()
        }
    }
}
