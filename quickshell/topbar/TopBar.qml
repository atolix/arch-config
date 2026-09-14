import QtQuick
import "../shared"

Item {
    id: root

    required property var audio
    required property bool headphonesConnected
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
    required property int countdownDuration
    required property int countdownRemaining
    required property bool countdownRunning
    required property var openCountdown
    required property var openMedia

    readonly property alias statusItem: status
    readonly property alias countdownItem: countdownDisplay
    readonly property alias mediaItem: mediaDisplay

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
        id: workspaceSwitcher
        workspaceOccupied: root.workspaceOccupied
        anchors.left: powerIcon.right
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
    }

    ClockDisplay {
        id: clockDisplay
        anchors.fill: parent
        value: root.clockValue
        openCalendar: root.openCalendar
    }

    CountdownDisplay {
        id: countdownDisplay
        readonly property real areaLeft: workspaceSwitcher.x + workspaceSwitcher.width + 16
        readonly property real areaRight: clockDisplay.contentLeft - 20

        x: areaLeft + Math.max(0, (areaRight - areaLeft - width) / 2)
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(implicitWidth, Math.max(0, areaRight - areaLeft))
        durationSeconds: root.countdownDuration
        remainingSeconds: root.countdownRemaining
        running: root.countdownRunning
        openPopup: root.openCountdown
    }

    MediaDisplay {
        id: mediaDisplay
        readonly property real areaLeft: clockDisplay.contentRight + 20
        readonly property real areaRight: status.x - 16

        x: areaLeft + Math.max(0, (areaRight - areaLeft - width) / 2)
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(implicitWidth, Math.max(0, areaRight - areaLeft))
        openPopup: root.openMedia
    }

    StatusIndicators {
        id: status
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        audio: root.audio
        headphonesConnected: root.headphonesConnected
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
