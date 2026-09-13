import QtQuick
import "shared/Theme.js" as Theme
import "shared"

Row {
    id: root

    required property var battery
    required property var percent

    spacing: 3

    BarText {
        visible: root.battery.ready && root.battery.isPresent
        height: 22
        verticalAlignment: Text.AlignVCenter
        text: root.percent(root.battery.percentage * 100)
        color: root.battery.percentage <= 0.15 ? Theme.danger : root.battery.percentage <= 0.3 ? Theme.warning : Theme.text
        Accessible.name: "Battery percentage " + text
    }

    BatteryIcon {
        battery: root.battery
        Accessible.name: "Battery " + root.percent(root.battery.percentage * 100)
    }
}
