import QtQuick
import "../shared/Theme.js" as Theme
import "../shared"

Item {
    id: root

    required property int durationSeconds
    required property int remainingSeconds
    required property bool running
    required property var openPopup

    readonly property real progress: durationSeconds > 0
        ? Math.max(0, Math.min(1, remainingSeconds / durationSeconds))
        : 0

    function formattedTime() {
        const minutes = Math.floor(remainingSeconds / 60);
        const seconds = remainingSeconds % 60;
        return minutes.toString().padStart(2, "0") + ":" + seconds.toString().padStart(2, "0");
    }

    implicitWidth: meter.width + (durationSeconds > 0 ? 8 + timeText.implicitWidth : 0)
    implicitHeight: 22
    visible: width >= 72
    Accessible.name: durationSeconds > 0 ? "Timer " + formattedTime() : "Set timer"

    Rectangle {
        id: meter
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 110
        height: 5
        radius: height / 2
        color: Theme.border

        Rectangle {
            anchors.left: parent.left
            width: parent.width * root.progress
            height: parent.height
            radius: parent.radius
            color: root.running ? Theme.accent : Theme.muted

            Behavior on width {
                NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
            }
        }
    }

    BarText {
        id: timeText
        visible: root.durationSeconds > 0
        anchors.left: meter.right
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        height: 22
        text: root.formattedTime()
        color: root.running ? Theme.text : Theme.muted
        font.bold: root.running
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.openPopup()
    }
}
