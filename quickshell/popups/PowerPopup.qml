import QtQuick
import Quickshell
import "../shared"

AnimatedPopup {
    id: popup
    implicitWidth: 190
    implicitHeight: 218
    color: "transparent"

    component ActionButton: PopupButton {
        required property var command
        width: 158
        height: 34
        cornerRadius: 6
        onClicked: {
            popup.opened = false;
            Quickshell.execDetached(command);
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

            ActionButton { text: "Lock"; command: ["hyprlock"] }
            ActionButton { text: "Suspend"; command: ["systemctl", "suspend"] }
            ActionButton { text: "Reboot"; command: ["systemctl", "reboot"] }
            ActionButton { text: "Shutdown"; command: ["systemctl", "poweroff"] }
        }
    }

    animatedItem: popupBody
}
