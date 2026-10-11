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
import "topbar"
import "leftrail"

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
    property bool headphonesConnected: false
    property var notifications: []
    property int countdownDuration: 0
    property int countdownRemaining: 0
    property bool countdownRunning: false
    property double countdownDeadline: 0

    function setCountdown(minutes) {
        root.countdownRunning = false;
        root.countdownDuration = minutes * 60;
        root.countdownRemaining = root.countdownDuration;
        root.countdownDeadline = 0;
    }

    function toggleCountdown() {
        if (root.countdownDuration === 0)
            return;
        if (root.countdownRunning) {
            root.countdownRemaining = Math.max(0, Math.ceil((root.countdownDeadline - Date.now()) / 1000));
            root.countdownRunning = false;
        } else {
            if (root.countdownRemaining === 0)
                root.countdownRemaining = root.countdownDuration;
            root.countdownDeadline = Date.now() + root.countdownRemaining * 1000;
            root.countdownRunning = true;
        }
    }

    function resetCountdown() {
        root.countdownRunning = false;
        root.countdownRemaining = root.countdownDuration;
        root.countdownDeadline = 0;
    }

    function clearCountdown() {
        root.countdownRunning = false;
        root.countdownDuration = 0;
        root.countdownRemaining = 0;
        root.countdownDeadline = 0;
    }

    Timer {
        interval: 250
        repeat: true
        running: root.countdownRunning
        onTriggered: {
            root.countdownRemaining = Math.max(0, Math.ceil((root.countdownDeadline - Date.now()) / 1000));
            if (root.countdownRemaining === 0) {
                root.countdownRunning = false;
                Quickshell.execDetached(["notify-send", "Timer", "Time is up"]);
            }
        }
    }

    function removeNotification(notification) {
        root.notifications = root.notifications.filter(item => item !== notification);
    }

    function clearNotifications() {
        const pending = root.notifications.slice();
        root.notifications = [];
        for (const notification of pending)
            notification.dismiss();
    }

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

    Process {
        id: audioOutputQuery
        command: ["python3", Quickshell.shellPath("scripts/audio-output.py")]
        running: true
        stdout: SplitParser {
            onRead: data => root.headphonesConnected = data.trim() === "headphones"
        }
    }

    Process {
        id: audioEvents
        command: ["pactl", "subscribe"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                if (!audioOutputQuery.running)
                    audioOutputQuery.running = true;
            }
        }
    }

    Timer {
        interval: 3000
        running: !audioEvents.running
        repeat: true
        onTriggered: audioEvents.running = true
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

    // Reserve work area at the top without constraining the visual bar horizontally.
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            anchors { top: true; left: true; right: true }
            implicitHeight: 30
            exclusiveZone: 30
            color: "transparent"
            mask: Region {}
            WlrLayershell.namespace: "quickshell-top-reservation"
        }
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
            exclusionMode: ExclusionMode.Ignore

            VolumePopup {
                id: volumePopup
                audio: root.audio
                anchor.window: bar
                anchor.rect.x: Math.max(8, Math.min(bar.width - width - 8, topBar.x + topBar.statusItem.x + topBar.statusItem.volumeItem.x + topBar.statusItem.volumeItem.width / 2 - width / 2))
                anchor.rect.y: bar.height + 6
            }

            BrightnessPopup {
                id: brightnessPopup
                brightness: root.brightness
                anchor.window: bar
                anchor.rect.x: Math.max(8, Math.min(bar.width - width - 8, topBar.x + topBar.statusItem.x + topBar.statusItem.brightnessItem.x + topBar.statusItem.brightnessItem.width / 2 - width / 2))
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
                id: notificationPopup
                server: notificationServer
                notifications: root.notifications
                removeNotification: root.removeNotification
                clearNotifications: root.clearNotifications
                anchor.window: bar
                anchor.rect.x: bar.width - width - 8
                anchor.rect.y: bar.height + 8
            }

            CountdownPopup {
                id: countdownPopup
                durationSeconds: root.countdownDuration
                remainingSeconds: root.countdownRemaining
                running: root.countdownRunning
                setDuration: root.setCountdown
                toggleTimer: root.toggleCountdown
                resetTimer: root.resetCountdown
                clearTimer: root.clearCountdown
                anchor.window: bar
                anchor.rect.x: Math.max(8, Math.min(bar.width - width - 8, topBar.x + topBar.countdownItem.x + topBar.countdownItem.width / 2 - width / 2))
                anchor.rect.y: bar.height + 6
            }

            MediaPopup {
                id: mediaPopup
                player: topBar.mediaItem.player
                anchor.window: bar
                anchor.rect.x: Math.max(8, Math.min(bar.width - width - 8, topBar.x + topBar.mediaItem.x + topBar.mediaItem.width / 2 - width / 2))
                anchor.rect.y: bar.height + 6
            }

            PanelWindow {
                id: countdownDismissLayer
                screen: bar.screen
                visible: countdownPopup.opened
                anchors { top: true; bottom: true; left: true; right: true }
                color: "transparent"
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.namespace: "quickshell-countdown-dismiss"
                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

                MouseArea {
                    anchors.fill: parent
                    onClicked: countdownPopup.opened = false
                }
            }

            PanelWindow {
                id: mediaDismissLayer
                screen: bar.screen
                visible: mediaPopup.opened
                anchors { top: true; bottom: true; left: true; right: true }
                color: "transparent"
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.namespace: "quickshell-media-dismiss"
                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

                MouseArea {
                    anchors.fill: parent
                    onClicked: mediaPopup.opened = false
                }
            }

            function toggleVolumePopup() {
                brightnessPopup.opened = false;
                calendarPopup.opened = false;
                powerPopup.opened = false;
                notificationPopup.opened = false;
                countdownPopup.opened = false;
                mediaPopup.opened = false;
                volumePopup.opened = !volumePopup.opened;
            }

            function toggleBrightnessPopup() {
                volumePopup.opened = false;
                calendarPopup.opened = false;
                powerPopup.opened = false;
                notificationPopup.opened = false;
                countdownPopup.opened = false;
                mediaPopup.opened = false;
                brightnessPopup.opened = !brightnessPopup.opened;
            }

            function toggleCalendarPopup() {
                volumePopup.opened = false;
                brightnessPopup.opened = false;
                powerPopup.opened = false;
                notificationPopup.opened = false;
                countdownPopup.opened = false;
                mediaPopup.opened = false;
                calendarPopup.opened = !calendarPopup.opened;
            }

            function togglePowerPopup() {
                volumePopup.opened = false;
                calendarPopup.opened = false;
                brightnessPopup.opened = false;
                notificationPopup.opened = false;
                countdownPopup.opened = false;
                mediaPopup.opened = false;
                powerPopup.opened = !powerPopup.opened;
            }

            function toggleNotificationPopup() {
                volumePopup.opened = false;
                calendarPopup.opened = false;
                powerPopup.opened = false;
                brightnessPopup.opened = false;
                countdownPopup.opened = false;
                mediaPopup.opened = false;
                notificationPopup.opened = !notificationPopup.opened;
            }

            function toggleCountdownPopup() {
                volumePopup.opened = false;
                calendarPopup.opened = false;
                powerPopup.opened = false;
                notificationPopup.opened = false;
                brightnessPopup.opened = false;
                mediaPopup.opened = false;
                countdownPopup.opened = !countdownPopup.opened;
            }

            function toggleMediaPopup() {
                volumePopup.opened = false;
                calendarPopup.opened = false;
                powerPopup.opened = false;
                notificationPopup.opened = false;
                countdownPopup.opened = false;
                brightnessPopup.opened = false;
                mediaPopup.opened = !mediaPopup.opened;
            }

            TopBar {
                id: topBar
                audio: root.audio
                headphonesConnected: root.headphonesConnected
                brightness: root.brightness
                battery: root.battery
                stats: root.stats
                clockValue: clock.date
                percent: root.percent
                networkIcon: root.networkIcon
                workspaceOccupied: root.workspaceOccupied
                togglePower: bar.togglePowerPopup
                openCalendar: bar.toggleCalendarPopup
                openVolume: bar.toggleVolumePopup
                openBrightness: bar.toggleBrightnessPopup
                powerPopupOpen: powerPopup.opened
                calendarPopupOpen: calendarPopup.opened
                volumePopupOpen: volumePopup.opened
                brightnessPopupOpen: brightnessPopup.opened
                notificationCount: root.notifications.length
                openNotifications: bar.toggleNotificationPopup
                notificationPopupOpen: notificationPopup.opened
                countdownDuration: root.countdownDuration
                countdownRemaining: root.countdownRemaining
                countdownRunning: root.countdownRunning
                openCountdown: bar.toggleCountdownPopup
                countdownPopupOpen: countdownPopup.opened
                openMedia: bar.toggleMediaPopup
                mediaPopupOpen: mediaPopup.opened
            }

            LeftRail {
                screenRef: bar.screen
                stats: root.stats
                appLabel: root.appLabel
            }
        }
    }
}
