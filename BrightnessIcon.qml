import QtQuick

Item {
    id: icon
    property var brightness: null
    readonly property real level: brightness === null ? 0 : Math.max(0, Math.min(1, brightness / 100))

    implicitWidth: 28
    implicitHeight: 24

    Repeater {
        model: 8
        Rectangle {
            required property int index
            readonly property real angle: index * 45
            readonly property real radians: angle * Math.PI / 180
            x: icon.width / 2 + Math.cos(radians) * 8
            y: icon.height / 2 + Math.sin(radians) * 8 - height / 2
            width: icon.brightness === null ? 0 : 1 + icon.level * 4
            height: 1.2
            radius: height / 2
            rotation: angle
            transformOrigin: Item.Left
            color: "#eaeaea"
            opacity: icon.brightness === null ? 0 : 0.2 + icon.level * 0.8

            Behavior on width { NumberAnimation { duration: 120 } }
            Behavior on opacity { NumberAnimation { duration: 120 } }
        }
    }

    Text {
        anchors.centerIn: parent
        text: "󰌵"
        color: icon.brightness === null ? "#646978" : "#eaeaea"
        font.family: "JetBrainsMono Nerd Font Mono"
        font.pixelSize: 15
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }
}
