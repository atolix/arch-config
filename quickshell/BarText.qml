import QtQuick
import "Theme.js" as Theme

Text {
    color: Theme.text
    font.family: "JetBrainsMono"
    font.pixelSize: 13
    textFormat: Text.PlainText
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
}
