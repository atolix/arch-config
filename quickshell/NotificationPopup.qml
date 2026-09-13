import QtQuick
import Quickshell

PopupWindow {
    id: popup
    property var server
    property var notifications: []

    implicitWidth: 360
    implicitHeight: Math.min(520, Math.max(80, notificationList.contentHeight + 12))
    color: "transparent"
    visible: notifications.length > 0

    ListView {
        id: notificationList
        anchors.fill: parent
        anchors.margins: 6
        spacing: 8
        model: popup.notifications
        clip: true

        delegate: Rectangle {
            required property var modelData
            width: notificationList.width
            height: bodyText.visible ? 92 : 68
            radius: 9
            color: "#f222242b"
            border.color: modelData.urgency === 2 ? "#f38ba8" : "#414552"

            Column {
                x: 14
                y: 10
                width: parent.width - 52
                spacing: 3

                BarText {
                    width: parent.width
                    height: 20
                    text: modelData.summary || modelData.appName || "Notification"
                    font.bold: true
                    elide: Text.ElideRight
                }

                BarText {
                    id: bodyText
                    width: parent.width
                    height: 38
                    visible: text.length > 0
                    text: modelData.body
                    color: "#c6c9d4"
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }
            }

            BarText {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.rightMargin: 10
                anchors.topMargin: 8
                width: 24
                height: 24
                text: "×"
                color: closeArea.containsMouse ? "#ffffff" : "#9da3b8"
                font.pixelSize: 18
                horizontalAlignment: Text.AlignHCenter
                MouseArea {
                    id: closeArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: modelData.dismiss()
                }
            }

            Connections {
                target: modelData
                function onClosed() {
                    popup.notifications = popup.notifications.filter(item => item !== modelData);
                }
            }
        }
    }
}
