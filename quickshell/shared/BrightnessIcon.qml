import QtQuick
import "Theme.js" as Theme

Item {
    id: icon
    property var brightness: null
    property bool active: false
    readonly property real level: brightness === null ? 0 : Math.max(0, Math.min(1, brightness / 100))

    implicitWidth: 24
    implicitHeight: 22

    Repeater {
        model: 8
        Rectangle {
            required property int index
            readonly property real angle: index * 45
            readonly property real radians: angle * Math.PI / 180
            x: icon.width / 2 + Math.cos(radians) * 7
            y: icon.height / 2 + Math.sin(radians) * 7 - height / 2
            width: icon.brightness === null ? 0 : 0.8 + icon.level * 3
            height: 1
            radius: height / 2
            rotation: angle
            transformOrigin: Item.Left
            color: icon.active ? Theme.accent : Theme.text
            opacity: icon.brightness === null ? 0 : 0.2 + icon.level * 0.8

            Behavior on width { NumberAnimation { duration: 120 } }
            Behavior on opacity { NumberAnimation { duration: 120 } }
        }
    }

    BarIcon {
        anchors.centerIn: parent
        text: "󰌵"
        color: icon.brightness === null ? Theme.muted : icon.active ? Theme.accent : Theme.text
        font.pixelSize: 13
    }
}
