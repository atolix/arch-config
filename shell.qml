import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower

Scope {
    id: root

    property var stats: ({ cpu: null, memory: null, network: "…" })
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
                try { root.stats = JSON.parse(data); }
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

                BarText { text: "cpu: " + root.percent(root.stats.cpu) }
                BarText { text: "mem: " + root.percent(root.stats.memory) }

                BarText {
                    id: volumeText
                    text: !root.audio ? "vol: —" : root.audio.muted ? "vol: mute" : "vol: " + root.percent(root.audio.volume * 100)
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

                BarText {
                    visible: root.battery.ready && root.battery.isPresent
                    text: "bat: " + root.percent(root.battery.percentage * 100) + (root.battery.state === UPowerDeviceState.Charging ? " +" : "")
                    color: root.battery.percentage <= 0.15 ? "#f38ba8" : "#eaeaea"
                }

                BarText {
                    text: root.stats.network
                    width: Math.min(implicitWidth, 180)
                }
            }
        }
    }
}
