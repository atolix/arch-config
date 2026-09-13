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

        Column {
            width: 18
            spacing: 0

            Repeater {
                id: appNameRepeater
                model: (Hyprland.focusedWorkspace?.toplevels?.values ?? []).slice().reverse()

                delegate: Item {
                    required property var modelData
                    required property int index
                    width: 18
                    height: appName.implicitWidth + 8

                    BarText {
                        id: appName
                        anchors.centerIn: parent
                        width: implicitWidth
                        height: 18
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 11
                        rotation: -90
                        text: (index < appNameRepeater.count - 1 ? "/ " : "") + rail.appLabel(modelData.wayland?.appId ?? modelData.handle?.appId ?? "")
                        color: modelData.activated ? "#a5b4fc" : "#eaeaea"
                    }
                }
            }
        }

        StatsText {
            stats: rail.stats
        }
    }
}
