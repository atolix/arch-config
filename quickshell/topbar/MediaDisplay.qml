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
        tickerRow.x = 0;
        if (root.visible && root.overflowing)
            marquee.restart();
    })
    onOverflowingChanged: {
        if (!overflowing)
            tickerRow.x = 0;
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

        Row {
            id: tickerRow
            x: 0
            height: parent.height
            spacing: 40

            BarText {
                id: trackText
                width: implicitWidth
                height: parent.height
                text: root.label
                elide: Text.ElideNone
            }

            BarText {
                visible: root.overflowing
                width: implicitWidth
                height: parent.height
                text: root.label
                elide: Text.ElideNone
            }

            NumberAnimation on x {
                id: marquee
                running: root.visible && root.overflowing
                loops: Animation.Infinite
                from: 0
                to: -(trackText.implicitWidth + tickerRow.spacing)
                duration: Math.max(3500, (trackText.implicitWidth + tickerRow.spacing) * 35)
                easing.type: Easing.Linear
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
