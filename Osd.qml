import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Scope {
    id: osd
    property string kind: "volume"
    property int percent: 0
    property bool muted: false
    signal brightnessReported(int value)

    IpcHandler {
        target: "osd"
        function display(kind: string, percent: int, muted: bool): void {
            if (kind !== "volume" && kind !== "brightness") return;
            osd.kind = kind;
            osd.percent = Math.max(0, Math.min(100, percent));
            osd.muted = muted;
            if (kind === "brightness") osd.brightnessReported(osd.percent);
            hideTimer.restart();
        }
    }

    Timer { id: hideTimer; interval: 1800 }

    Variants {
        model: Quickshell.screens
        PanelWindow {
            required property var modelData
            screen: modelData
            visible: hideTimer.running
            anchors.bottom: true
            margins.bottom: 70
            implicitWidth: 280
            implicitHeight: 76
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            mask: Region {}
            WlrLayershell.namespace: "quickshell-osd"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            Rectangle {
                anchors.fill: parent
                radius: 12
                color: "#f222242b"
                border.color: "#414552"
                BarText {
                    x: 18; y: 14
                    text: osd.kind === "brightness" ? "Brightness" : "Volume"
                }
                BarText {
                    anchors.right: parent.right
                    anchors.rightMargin: 18
                    y: 14
                    text: osd.muted ? "Muted" : osd.percent + "%"
                }
                Rectangle {
                    x: 18; y: 46
                    width: parent.width - 36
                    height: 6
                    radius: 3
                    color: "#414552"
                    Rectangle {
                        width: parent.width * (osd.muted ? 0 : osd.percent / 100)
                        height: parent.height
                        radius: 3
                        color: "#a5b4fc"
                        Behavior on width { NumberAnimation { duration: 100 } }
                    }
                }
            }
        }
    }
}
