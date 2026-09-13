import QtQuick

Item {
    id: root

    required property var stats

    width: 18
    height: 420

    BarText {
        anchors.centerIn: parent
        width: 420
        height: 18
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 11
        rotation: -90
        text: "cpu: " + root.stats.cpu + "% / mem: " + root.stats.mem + "% / temp: " + (root.stats.temp === null ? "—" : root.stats.temp) + "°C / fan: " + (root.stats.fan === null ? "—" : root.stats.fan) + " RPM"
    }
}
