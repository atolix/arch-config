import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland

PopupWindow {
    id: popup
    required property date today
    property date month: new Date(today.getFullYear(), today.getMonth(), 1, 12)
    readonly property int firstWeekday: month.getDay()
    implicitWidth: 304
    implicitHeight: 344
    color: "transparent"

    function showToday() {
        month = new Date(today.getFullYear(), today.getMonth(), 1, 12);
    }

    function moveMonth(offset) {
        month = new Date(month.getFullYear(), month.getMonth() + offset, 1, 12);
    }

    onVisibleChanged: if (visible) showToday()

    HyprlandFocusGrab {
        active: popup.visible
        windows: [popup]
        onCleared: popup.visible = false
    }

    component CalendarButton: Button {
        implicitWidth: 32
        implicitHeight: 28
        contentItem: BarText {
            text: parent.text
            horizontalAlignment: Text.AlignHCenter
        }
        background: Rectangle {
            radius: 5
            color: parent.down ? "#50566a" : parent.hovered ? "#414552" : "#363b49"
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#f222242b"
        radius: 10
        border.color: "#414552"

        CalendarButton {
            x: 16; y: 16
            text: "‹"
            Accessible.name: "Previous month"
            onClicked: popup.moveMonth(-1)
        }
        BarText {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 16
            height: 28
            text: popup.month.toLocaleDateString(Qt.locale("en_US"), "MMMM yyyy")
        }
        CalendarButton {
            anchors.right: parent.right
            anchors.rightMargin: 16
            y: 16
            text: "›"
            Accessible.name: "Next month"
            onClicked: popup.moveMonth(1)
        }

        Row {
            x: 16; y: 56
            Repeater {
                model: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                BarText {
                    required property string modelData
                    required property int index
                    width: 38.85
                    height: 26
                    text: modelData
                    horizontalAlignment: Text.AlignHCenter
                    color: index === 0 ? "#f38ba8" : index === 6 ? "#a5b4fc" : "#aeb3c2"
                }
            }
        }

        Grid {
            x: 16; y: 84
            columns: 7
            Repeater {
                model: 42
                Rectangle {
                    id: dayCell
                    required property int index
                    readonly property date day: new Date(popup.month.getFullYear(), popup.month.getMonth(), 1 - popup.firstWeekday + index, 12)
                    readonly property bool inMonth: day.getMonth() === popup.month.getMonth()
                    readonly property bool isToday: day.getFullYear() === popup.today.getFullYear() && day.getMonth() === popup.today.getMonth() && day.getDate() === popup.today.getDate()
                    width: 38.85
                    height: 34
                    radius: 7
                    color: isToday ? "#a5b4fc" : "transparent"
                    BarText {
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        text: dayCell.day.getDate()
                        color: dayCell.isToday ? "#181a22" : !dayCell.inMonth ? "#646978" : dayCell.index % 7 === 0 ? "#f38ba8" : dayCell.index % 7 === 6 ? "#a5b4fc" : "#eaeaea"
                    }
                }
            }
        }

        CalendarButton {
            x: 16; y: 300
            width: 70
            text: "Today"
            onClicked: popup.showToday()
        }
        CalendarButton {
            anchors.right: parent.right
            anchors.rightMargin: 16
            y: 300
            width: 70
            text: "Close"
            onClicked: popup.visible = false
        }
    }
}
