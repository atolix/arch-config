import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland

PopupWindow {
    id: popup
    implicitWidth: 190
    implicitHeight: 218
    color: "transparent"

    HyprlandFocusGrab {
        active: popup.visible
        windows: [popup]
        onCleared: popup.visible = false
    }

    component ActionButton: Button {
        required property string label
        required property var command
        width: 158
        height: 34
        onClicked: {
            popup.visible = false;
            Quickshell.execDetached(command);
        }
        contentItem: BarText {
            text: label
            horizontalAlignment: Text.AlignHCenter
        }
        background: Rectangle {
            radius: 6
            color: parent.down ? "#50566a" : parent.hovered ? "#414552" : "#363b49"
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#f222242b"
        radius: 10
        border.color: "#414552"

        BarText {
            x: 16
            y: 14
            text: "Power"
        }

        Column {
            x: 16
            y: 45
            spacing: 6

            ActionButton { label: "Lock"; command: ["hyprlock"] }
            ActionButton { label: "Suspend"; command: ["systemctl", "suspend"] }
            ActionButton { label: "Reboot"; command: ["systemctl", "reboot"] }
            ActionButton { label: "Shutdown"; command: ["systemctl", "poweroff"] }
        }
    }
}
