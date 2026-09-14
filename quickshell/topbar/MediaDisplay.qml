import QtQuick
import Quickshell.Services.Mpris
import "../shared/Theme.js" as Theme
import "../shared"

Item {
    id: root

    readonly property var player: selectPlayer()
    readonly property string title: player?.trackTitle ?? ""
    readonly property string artist: player?.trackArtist ?? ""
    readonly property string label: artist.length > 0 && title.length > 0
        ? artist + " — " + title
        : title.length > 0 ? title : artist
    readonly property bool overflowing: trackText.implicitWidth > textViewport.width

    onLabelChanged: Qt.callLater(() => {
        trackText.x = 0;
        if (root.visible && root.overflowing)
            marquee.restart();
    })
    onOverflowingChanged: {
        if (!overflowing)
            trackText.x = 0;
    }

    function selectPlayer() {
        const players = Mpris.players.values ?? [];
        for (const candidate of players) {
            if (candidate.isPlaying && (candidate.trackTitle || candidate.trackArtist))
                return candidate;
        }
        for (const candidate of players) {
            if (candidate.trackTitle || candidate.trackArtist)
                return candidate;
        }
        return null;
    }

    visible: player !== null && label.length > 0 && width >= 72
    implicitWidth: Math.min(300, playbackIcon.width + 5 + trackText.implicitWidth)
    height: 22
    clip: true
    Accessible.name: visible
        ? (player.isPlaying ? "Now playing " : "Paused ") + label
        : ""

    BarText {
        id: playbackIcon
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 22
        height: 22
        text: root.player?.isPlaying ? "󰏤" : "󰐊"
        font.family: "JetBrainsMono Nerd Font Mono"
        font.pixelSize: 15
        color: Theme.accent
        horizontalAlignment: Text.AlignHCenter
    }

    Item {
        id: textViewport
        anchors.left: playbackIcon.right
        anchors.leftMargin: 5
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 22
        clip: true

        BarText {
            id: trackText
            x: 0
            width: implicitWidth
            height: parent.height
            text: root.label
            elide: Text.ElideNone

            SequentialAnimation on x {
                id: marquee
                running: root.visible && root.overflowing
                loops: Animation.Infinite

                PauseAnimation { duration: 1600 }
                NumberAnimation {
                    to: -(trackText.implicitWidth - textViewport.width)
                    duration: Math.max(2400, (trackText.implicitWidth - textViewport.width) * 35)
                    easing.type: Easing.InOutSine
                }
                PauseAnimation { duration: 1300 }
                NumberAnimation {
                    to: 0
                    duration: Math.max(1600, (trackText.implicitWidth - textViewport.width) * 24)
                    easing.type: Easing.InOutSine
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.player?.canTogglePlaying ?? false
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.player.togglePlaying()
    }
}
