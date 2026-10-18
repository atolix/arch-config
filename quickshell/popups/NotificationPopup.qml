import QtQuick
import QtQuick.Controls
import Quickshell
import "../shared/Theme.js" as Theme
import "../shared"

AnimatedPopup {
    id: popup
    property var server
    property var notifications: []
    required property var removeNotification
    required property var clearNotifications

    implicitWidth: 380
    implicitHeight: 460
    color: "transparent"

    Rectangle {
        id: popupBody
        anchors.fill: parent
        color: Theme.surface
        radius: 10
        border.color: Theme.border

        BarText {
            x: 16
            y: 12
            height: 28
            text: "Notifications"
            font.bold: true
            font.pixelSize: 14
        }

        BarText {
            visible: popup.notifications.length > 0
            anchors.right: clearText.left
            anchors.rightMargin: 12
            y: 12
            height: 28
            text: popup.notifications.length + (popup.notifications.length === 1 ? " item" : " items")
            color: Theme.muted
            font.pixelSize: 11
        }

        BarText {
            id: clearText
            visible: popup.notifications.length > 0
            anchors.right: parent.right
            anchors.rightMargin: 14
            y: 12
            width: 52
            height: 28
            text: "Clear"
            color: clearArea.containsMouse ? Theme.accent : Theme.text
            horizontalAlignment: Text.AlignHCenter

            MouseArea {
                id: clearArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: popup.clearNotifications()
            }
        }

        Rectangle {
            x: 12
            y: 48
            width: parent.width - 24
            height: 1
            color: Theme.border
        }

        Column {
            visible: popup.notifications.length === 0
            anchors.centerIn: parent
            spacing: 8

            BarText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "󰂛"
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 28
                color: Theme.muted
            }

            BarText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "No notifications"
                color: Theme.muted
            }
        }

        ListView {
            id: notificationList
            x: 10
            y: 58
            width: parent.width - 20
            height: parent.height - 68
            spacing: 8
            model: popup.notifications.slice().reverse()
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            delegate: Rectangle {
                required property var modelData
                width: notificationList.width - 6
                height: bodyText.visible ? 92 : 68
                radius: 9
                color: Theme.button
                border.color: modelData.urgency === 2 ? Theme.danger : Theme.border

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
                    color: closeArea.containsMouse ? Theme.white : "#9da3b8"
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
                        popup.removeNotification(modelData);
                    }
                }
            }
        }
    }

    animatedItem: popupBody
}
