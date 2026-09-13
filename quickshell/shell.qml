import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Services.Notifications
import "shared/HyprlandHelpers.js" as HyprlandHelpers
import "shared/Theme.js" as Theme
import "shared"
import "popups"

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
        return HyprlandHelpers.appLabel(appId);
    }

    function networkIcon() {
        return HyprlandHelpers.networkIcon(root.stats.network_type, root.stats.signal);
    }

    function workspaceFor(id) {
        return HyprlandHelpers.workspaceFor(Hyprland.workspaces?.values ?? [], id);
    }

    function workspaceOccupied(id) {
        return HyprlandHelpers.workspaceOccupied(Hyprland.workspaces?.values ?? [], id);
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
            color: Theme.background

            VolumePopup {
                id: volumePopup
                audio: root.audio
                anchor.window: bar
                anchor.rect.x: Math.max(8, Math.min(bar.width - width - 8, status.x + status.volumeItem.x + status.volumeItem.width / 2 - width / 2))
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

            function toggleVolumePopup() {
                calendarPopup.visible = false;
                volumePopup.visible = !volumePopup.visible;
            }

            function toggleCalendarPopup() {
                volumePopup.visible = false;
                calendarPopup.visible = !calendarPopup.visible;
            }

            function togglePowerPopup() {
                volumePopup.visible = false;
                calendarPopup.visible = false;
                powerPopup.visible = !powerPopup.visible;
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
                    onClicked: bar.togglePowerPopup()
                }
            }

            WorkspaceSwitcher {
                id: workspaceSwitcher
                workspaceOccupied: root.workspaceOccupied
                anchors.left: powerIcon.right
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
            }

            ClockDisplay {
                anchors.fill: parent
                value: clock.date
                openCalendar: bar.toggleCalendarPopup
            }

            StatusIndicators {
                id: status
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                audio: root.audio
                brightness: root.brightness
                battery: root.battery
                input: root.stats.input
                percent: root.percent
                networkIcon: root.networkIcon
                openVolumePopup: bar.toggleVolumePopup
            }

            LeftRail {
                screenRef: bar.screen
                stats: root.stats
                appLabel: root.appLabel
            }
        }
    }
}
