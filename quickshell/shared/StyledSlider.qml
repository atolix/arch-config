import QtQuick
import QtQuick.Controls
import "Theme.js" as Theme

Slider {
    id: control

    property real trackHeight: 4
    property real handleSize: 14
    property color disabledFillColor: Theme.disabled

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        width: control.availableWidth
        height: control.trackHeight
        radius: height / 2
        color: Theme.border

        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            radius: parent.radius
            color: control.enabled ? Theme.accent : control.disabledFillColor
        }
    }

    handle: Rectangle {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        width: control.handleSize
        height: control.handleSize
        radius: width / 2
        color: control.pressed ? Theme.white : Theme.accent
    }
}
