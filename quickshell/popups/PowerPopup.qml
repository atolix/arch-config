import QtQuick
import QtQuick.Controls
import Quickshell
import "../shared/Theme.js" as Theme
import "../shared"

AnimatedPopup {
    id: popup
    implicitWidth: 190
    implicitHeight: 218
    color: "transparent"

    component ActionButton: Button {
        required property string label
        required property var command
        width: 158
        height: 34
        onClicked: {
            popup.opened = false;
            Quickshell.execDetached(command);
        }
        contentItem: BarText {
            text: label
            horizontalAlignment: Text.AlignHCenter
        }
        background: Rectangle {
            radius: 6
            color: parent.down ? Theme.buttonHover : parent.hovered ? Theme.border : Theme.button
        }
    }

    PopupFrame {
        id: popupBody
        anchors.fill: parent

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

    animatedItem: popupBody
}
