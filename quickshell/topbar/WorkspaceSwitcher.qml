import QtQuick
import Quickshell.Hyprland
import "../shared/Theme.js" as Theme

Row {
    id: root

    required property var workspaceOccupied

    spacing: 3

    Repeater {
        model: [1, 2, 3, 4, 5]

        delegate: Rectangle {
            required property int modelData
            width: 18
            height: 22
            color: "transparent"
            Accessible.name: "Workspace " + modelData

            Rectangle {
                anchors.centerIn: parent
                readonly property bool focused: Hyprland.focusedWorkspace?.id === parent.modelData
                readonly property bool occupied: root.workspaceOccupied(parent.modelData)
                width: focused ? 14 : 7
                height: focused ? 5 : 7
                radius: height / 2
                color: focused ? Theme.accent : occupied ? Theme.accent : "transparent"
                border.width: focused || occupied ? 0 : 1
                border.color: Theme.muted
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("workspace " + parent.modelData)
            }
        }
    }
}
