import QtQuick

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
        color: root.battery.percentage <= 0.15 ? "#f38ba8" : root.battery.percentage <= 0.3 ? "#f9e2af" : "#eaeaea"
        Accessible.name: "Battery percentage " + text
    }

    BatteryIcon {
        battery: root.battery
        Accessible.name: "Battery " + root.percent(root.battery.percentage * 100)
    }
}
