import QtQuick
import Quickshell.Hyprland
import "../shared/Theme.js" as Theme
import "../shared"

Column {
    id: root

    required property var appLabel

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
                text: (index < appNameRepeater.count - 1 ? "/ " : "") + root.appLabel(modelData.wayland?.appId ?? modelData.handle?.appId ?? "")
                color: modelData.activated ? Theme.accent : Theme.text
            }
        }
    }
}
