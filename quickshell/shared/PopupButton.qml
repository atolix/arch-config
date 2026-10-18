import QtQuick
import QtQuick.Controls
import "Theme.js" as Theme

Button {
    id: control

    property real cornerRadius: 5
    property color normalColor: Theme.button
    property color hoverColor: Theme.border
    property color pressedColor: Theme.buttonHover
    property color disabledColor: normalColor
    property color labelColor: enabled ? Theme.text : Theme.muted
    property string labelFontFamily: "JetBrainsMono"
    property int labelPixelSize: 13

    contentItem: BarText {
        text: control.text
        color: control.labelColor
        font.family: control.labelFontFamily
        font.pixelSize: control.labelPixelSize
        horizontalAlignment: Text.AlignHCenter
    }

    background: Rectangle {
        radius: control.cornerRadius
        color: !control.enabled
            ? control.disabledColor
            : control.down
                ? control.pressedColor
                : control.hovered ? control.hoverColor : control.normalColor
    }
}
