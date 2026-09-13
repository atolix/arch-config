import QtQuick
import Quickshell
import Quickshell.Hyprland

PanelWindow {
    id: rail

    required property var screenRef
    required property var stats
    required property var appLabel

    screen: screenRef
    anchors { left: true; top: true; bottom: true }
    implicitWidth: 38
    color: "#cc141414"

    Column {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        AppList {
            appLabel: rail.appLabel
        }

        StatsText {
            stats: rail.stats
        }
    }
}
