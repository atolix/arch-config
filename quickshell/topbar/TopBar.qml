import QtQuick
import "../shared"
import "../shared/Theme.js" as Theme

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
    required property var openBrightness
    required property int notificationCount
    required property var openNotifications
    required property var openMedia
    required property bool powerPopupOpen
    required property bool calendarPopupOpen
    required property bool volumePopupOpen
    required property bool brightnessPopupOpen
    required property bool notificationPopupOpen
    required property bool mediaPopupOpen

    readonly property alias statusItem: status
    readonly property alias mediaItem: mediaDisplay

    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    height: parent.height

    BarIcon {
        id: powerIcon
        anchors.left: parent.left
        anchors.leftMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        width: 22
        height: 22
        verticalAlignment: Text.AlignVCenter
        text: "󰐥"
        color: root.powerPopupOpen ? Theme.accent : Theme.text
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
        popupOpen: root.calendarPopupOpen
    }

    MediaDisplay {
        id: mediaDisplay
        readonly property real areaLeft: clockDisplay.contentRight + 20
        readonly property real areaRight: status.x - 16

        x: areaLeft + Math.max(0, (areaRight - areaLeft - width) / 2)
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(implicitWidth, Math.max(0, areaRight - areaLeft))
        openPopup: root.openMedia
        popupOpen: root.mediaPopupOpen
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
        openBrightnessPopup: root.openBrightness
        volumePopupOpen: root.volumePopupOpen
        brightnessPopupOpen: root.brightnessPopupOpen
        notificationCount: root.notificationCount
        openNotifications: root.openNotifications
        notificationPopupOpen: root.notificationPopupOpen
    }
}
