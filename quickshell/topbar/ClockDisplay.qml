import QtQuick
import "../shared"
import "../shared/Theme.js" as Theme

Item {
    id: root

    required property date value
    required property var openCalendar
    required property bool popupOpen
    readonly property real contentLeft: yearText.x
    readonly property real contentRight: timezoneText.x + timezoneText.width

    BarText {
        id: clockText
        anchors.centerIn: parent
        text: Qt.formatDateTime(root.value, "MM/dd ddd HH:mm:ss")
        color: root.popupOpen ? Theme.accent : Theme.text
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.openCalendar()
        }
    }

    BarText {
        id: timezoneText
        anchors.left: clockText.right
        anchors.leftMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        text: Qt.formatDateTime(root.value, "t")
        color: root.popupOpen ? Theme.accent : Theme.text
        Accessible.name: "Timezone " + text
    }

    BarText {
        id: yearText
        anchors.right: clockText.left
        anchors.rightMargin: 0
        anchors.verticalCenter: parent.verticalCenter
        text: Qt.formatDateTime(root.value, "yyyy/")
        color: root.popupOpen ? Theme.accent : Theme.text
        Accessible.name: "Year " + text
    }
}
