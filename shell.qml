import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower

Scope {
    id: root

    property var brightness: null
    Osd {
        onBrightnessReported: value => root.brightness = value
    }

    property var stats: ({ network: "…", input: "—" })

    IpcHandler {
        target: "input"
        function setLayout(layout: string): void {
            root.stats = { network: root.stats.network, input: layout };
        }
    }
    readonly property var audio: Pipewire.defaultAudioSink?.audio ?? null
    readonly property var battery: UPower.displayDevice
    readonly property string appName: {
        const app = ToplevelManager.activeToplevel?.appId ?? "";
        const names = {
            "com.mitchellh.ghostty": "Ghostty",
            "org.kde.dolphin": "Dolphin",
            "chromium": "Chromium",
            "firefox": "Firefox"
        };
        return names[app] ?? app;
    }

    function percent(value) {
        return value === null || value === undefined ? "—" : Math.round(value) + "%";
    }

    PwObjectTracker {
        objects: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : []
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Process {
        id: metrics
        command: ["python3", Quickshell.shellPath("scripts/metrics.py")]
        running: true
        stdout: SplitParser {
            onRead: data => {
                try {
                    root.stats = JSON.parse(data);
                    root.brightness = root.stats.brightness ?? null;
                }
                catch (error) { console.warn("Invalid metrics:", error); }
            }
        }
    }

    // Recover if the helper exits unexpectedly, without overlapping processes.
    Timer {
        interval: 5000
        running: !metrics.running
        repeat: true
        onTriggered: metrics.running = true
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            required property var modelData
            screen: modelData
            anchors { top: true; left: true; right: true }
            implicitHeight: 30
            color: "#cc141414"

            VolumePopup {
                id: volumePopup
                audio: root.audio
                anchor.window: bar
                anchor.rect.x: Math.max(8, Math.min(bar.width - width - 8, status.x + volumeText.x + volumeText.width / 2 - width / 2))
                anchor.rect.y: bar.height + 6
            }

            CalendarPopup {
                id: calendarPopup
                today: clock.date
                anchor.window: bar
                anchor.rect.x: (bar.width - width) / 2
                anchor.rect.y: bar.height + 6
            }

            PowerPopup {
                id: powerPopup
                anchor.window: bar
                anchor.rect.x: 8
                anchor.rect.y: bar.height + 6
            }

            BarText {
                id: powerIcon
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                width: 22
                height: 22
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 17
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: "󰐥"
                Accessible.name: "Power"
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        volumePopup.visible = false;
                        calendarPopup.visible = false;
                        powerPopup.visible = !powerPopup.visible;
                    }
                }
            }

            BarText {
                anchors.left: parent.left
                anchors.leftMargin: 42
                anchors.verticalCenter: parent.verticalCenter
                width: Math.max(0, Math.min(290, clockText.x - 54))
                height: 22
                verticalAlignment: Text.AlignVCenter
                text: root.appName
            }

            BarText {
                id: clockText
                anchors.centerIn: parent
                text: Qt.formatDateTime(clock.date, "MMM d ddd HH:mm:ss")
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        volumePopup.visible = false;
                        calendarPopup.visible = !calendarPopup.visible;
                    }
                }
            }

            Row {
                id: status
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                BarText {
                    id: inputLayout
                    width: 24
                    height: 22
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: root.stats.input
                    Accessible.name: "Keyboard layout " + text
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Quickshell.execDetached(["python3", Quickshell.shellPath("scripts/input-toggle.py")])
                    }
                }

                VolumeIcon {
                    id: volumeText
                    audio: root.audio
                    Accessible.name: "Volume"
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mouse => {
                            if (mouse.button === Qt.RightButton) {
                                if (root.audio) root.audio.muted = !root.audio.muted;
                            } else {
                                calendarPopup.visible = false;
                                volumePopup.visible = !volumePopup.visible;
                            }
                        }
                        onWheel: wheel => {
                            if (root.audio && wheel.angleDelta.y !== 0)
                                root.audio.volume = Math.max(0, Math.min(1, root.audio.volume + (wheel.angleDelta.y > 0 ? 0.05 : -0.05)));
                        }
                    }
                }

                BrightnessIcon {
                    brightness: root.brightness
                    Accessible.name: "Brightness"
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Quickshell.execDetached(["python3", Quickshell.shellPath("scripts/osd-control.py"), "brightness", "show"])
                    }
                }

                Row {
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

                BarText {
                    height: 22
                    verticalAlignment: Text.AlignVCenter
                    text: root.stats.network
                    width: Math.min(implicitWidth, 180)
                    Accessible.name: root.stats.network
                }
            }
        }
    }
}
