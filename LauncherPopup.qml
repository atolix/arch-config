import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland

PopupWindow {
    id: popup
    required property bool opened
    property string searchText: ""

    implicitWidth: 520
    implicitHeight: 430
    color: "transparent"
    visible: opened

    onOpenedChanged: {
        if (opened) {
            searchText = "";
            search.forceActiveFocus();
        }
    }

    HyprlandFocusGrab {
        active: popup.opened
        windows: [popup]
        onCleared: popup.opened = false
    }

    Rectangle {
        anchors.fill: parent
        color: "#f222242b"
        radius: 12
        border.color: "#414552"

        TextField {
            id: search
            x: 16
            y: 14
            width: parent.width - 32
            height: 42
            placeholderText: "Search applications"
            text: popup.searchText
            color: "#eaeaea"
            placeholderTextColor: "#777d91"
            font.family: "JetBrainsMono"
            font.pixelSize: 15
            background: Rectangle {
                color: "#2c3040"
                radius: 7
                border.color: "#50566a"
            }
            onTextChanged: popup.searchText = text
            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    popup.opened = false;
                    event.accepted = true;
                } else if (event.key === Qt.Key_Down) {
                    resultList.currentIndex = Math.min(resultList.count - 1, resultList.currentIndex + 1);
                    event.accepted = true;
                } else if (event.key === Qt.Key_Up) {
                    resultList.currentIndex = Math.max(0, resultList.currentIndex - 1);
                    event.accepted = true;
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    if (resultList.currentItem) resultList.currentItem.launch();
                    event.accepted = true;
                }
            }
        }

        ListView {
            id: resultList
            x: 12
            y: 68
            width: parent.width - 24
            height: parent.height - 78
            spacing: 3
            clip: true
            model: DesktopEntries.applications
            currentIndex: 0

            delegate: Rectangle {
                required property var modelData
                readonly property bool matches: !modelData.noDisplay && modelData.name.length > 0 && (popup.searchText.trim().length === 0 || (modelData.name + " " + modelData.genericName + " " + modelData.comment).toLowerCase().includes(popup.searchText.trim().toLowerCase()))
                width: resultList.width
                height: matches ? 42 : 0
                visible: matches
                radius: 6
                color: ListView.isCurrentItem ? "#414552" : "transparent"

                function launch() {
                    modelData.execute();
                    popup.opened = false;
                }

                BarText {
                    x: 12
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 24
                    text: modelData.name
                    color: ListView.isCurrentItem ? "#a5b4fc" : "#eaeaea"
                    elide: Text.ElideRight
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: resultList.currentIndex = index
                    onClicked: parent.launch()
                }
            }
        }
    }
}
