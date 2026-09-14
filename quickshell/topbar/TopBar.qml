import QtQuick
import "../shared"

Item {
    id: root

    required property var audio
    required property var brightness
    required property var battery
    required property var stats
    required property date clockValue
    required property var percent
    required property var networkIcon
    required property var workspaceOccupied
    required property var togglePower
    required property var openCalendar
    required property var openVolume
    required property int notificationCount
    required property var openNotifications

    readonly property alias statusItem: status

    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    height: parent.height

    BarText {
        id: powerIcon
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        width: 22
        height: 22
        font.family: "JetBrainsMono Nerd Font Mono"
        font.pixelSize: 17
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: "󰐥"
        Accessible.name: "Power"
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.togglePower()
        }
    }

    WorkspaceSwitcher {
        workspaceOccupied: root.workspaceOccupied
        anchors.left: powerIcon.right
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
    }

    ClockDisplay {
        anchors.fill: parent
        value: root.clockValue
        openCalendar: root.openCalendar
    }

    StatusIndicators {
        id: status
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        audio: root.audio
        brightness: root.brightness
        battery: root.battery
        input: root.stats.input
        percent: root.percent
        networkIcon: root.networkIcon
        openVolumePopup: root.openVolume
        notificationCount: root.notificationCount
        openNotifications: root.openNotifications
    }
}
