import QtQuick
import "shared"

Item {
    id: root

    required property date value
    required property var openCalendar

    BarText {
        id: clockText
        anchors.centerIn: parent
        text: Qt.formatDateTime(root.value, "MM/dd ddd HH:mm:ss")
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.openCalendar()
        }
    }

    BarText {
        anchors.left: clockText.right
        anchors.leftMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        text: Qt.formatDateTime(root.value, "t")
        Accessible.name: "Timezone " + text
    }

    BarText {
        anchors.right: clockText.left
        anchors.rightMargin: 0
        anchors.verticalCenter: parent.verticalCenter
        text: Qt.formatDateTime(root.value, "yyyy/")
        Accessible.name: "Year " + text
    }
}
