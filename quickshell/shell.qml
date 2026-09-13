import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Services.Notifications

Scope {
    id: root

    property var brightness: null
    Osd {
        onBrightnessReported: value => root.brightness = value
    }

    property var stats: ({ network: "…", network_type: "offline", signal: 0, cpu: 0, mem: 0, temp: null, fan: null, input: "—" })

    IpcHandler {
        target: "input"
        function setLayout(layout: string): void {
            root.stats = { network: root.stats.network, network_type: root.stats.network_type, signal: root.stats.signal, cpu: root.stats.cpu, mem: root.stats.mem, temp: root.stats.temp, fan: root.stats.fan, input: layout };
        }
    }
    readonly property var audio: Pipewire.defaultAudioSink?.audio ?? null
    readonly property var battery: UPower.displayDevice
    property var notifications: []

    NotificationServer {
        id: notificationServer
        bodySupported: true
        bodyMarkupSupported: false
        actionsSupported: true
        imageSupported: true
        onNotification: notification => {
            notification.tracked = true;
            root.notifications = root.notifications.concat([notification]);
        }
    }
    function percent(value) {
        return value === null || value === undefined ? "—" : Math.round(value) + "%";
    }

    function appLabel(appId) {
        const names = {
            "com.mitchellh.ghostty": "Ghostty",
            "chromium": "Chromium",
        };
        return names[appId] ?? appId;
    }

    function networkIcon() {
        if (root.stats.network_type === "ethernet") return "󰈀";
        if (root.stats.network_type !== "wifi") return "󰤭";
        const signal = Number(root.stats.signal ?? 0);
        if (signal >= 70) return "󰤨";
        if (signal >= 40) return "󰤥";
        return "󰤢";
    }

    function workspaceFor(id) {
        const workspaces = Hyprland.workspaces?.values ?? [];
        for (const workspace of workspaces) {
            if (workspace.id === id) return workspace;
        }
        return null;
    }

    function workspaceOccupied(id) {
        const workspace = workspaceFor(id);
        return workspace !== null && (workspace.toplevels?.values?.length ?? 0) > 0;
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

            NotificationPopup {
                server: notificationServer
                notifications: root.notifications
                anchor.window: bar
                anchor.rect.x: bar.width - width - 8
                anchor.rect.y: bar.height + 8
            }


            BarText {
                id: powerIcon
                anchors.left: parent.left
                anchors.leftMargin: 8
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

            WorkspaceSwitcher {
                id: workspaceSwitcher
                workspaceOccupied: root.workspaceOccupied
                anchors.left: powerIcon.right
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
            }

            BarText {
                id: clockText
                anchors.centerIn: parent
                text: Qt.formatDateTime(clock.date, "MM/dd ddd HH:mm:ss")
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        volumePopup.visible = false;
                        calendarPopup.visible = !calendarPopup.visible;
                    }
                }
            }

            BarText {
                id: timezoneText
                anchors.left: clockText.right
                anchors.leftMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                text: Qt.formatDateTime(clock.date, "t")
                Accessible.name: "Timezone " + text
            }

            BarText {
                id: yearText
                anchors.right: clockText.left
                anchors.rightMargin: 0
                anchors.verticalCenter: parent.verticalCenter
                text: Qt.formatDateTime(clock.date, "yyyy/")
                Accessible.name: "Year " + text
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
                    width: 22
                    horizontalAlignment: Text.AlignHCenter
                    text: root.networkIcon()
                    font.family: "JetBrainsMono Nerd Font Mono"
                    font.pixelSize: 17
                    Accessible.name: root.stats.network
                }
            }

            LeftRail {
                screenRef: bar.screen
                stats: root.stats
                appLabel: root.appLabel
            }
        }
    }
}
