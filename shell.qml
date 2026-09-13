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

    property var stats: ({ network: "…" })
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
        precision: SystemClock.Minutes
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

            BarText {
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                width: Math.max(0, Math.min(320, clockText.x - 24))
                text: root.appName
            }

            BarText {
                id: clockText
                anchors.centerIn: parent
                text: Qt.formatDateTime(clock.date, "MMM d ddd hh:mm AP")
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

                BatteryIcon {
                    battery: root.battery
                    Accessible.name: "Battery " + root.percent(root.battery.percentage * 100)
                }

                BarText {
                    text: root.stats.network
                    width: Math.min(implicitWidth, 180)
                    Accessible.name: root.stats.network
                }
            }
        }
    }
}
