import QtQuick
import Quickshell
import Quickshell.Hyprland

PopupWindow {
    id: root

    default property alias content: popupBody.data
    property bool opened: false
    property bool animationVisible: false

    color: "transparent"
    visible: animationVisible
    onOpenedChanged: {
        if (opened) {
            closeAnimation.stop();
            animationVisible = true;
            openAnimation.restart();
        } else if (animationVisible) {
            openAnimation.stop();
            closeAnimation.restart();
        }
    }

    PopupFrame {
        id: popupBody

        anchors.fill: parent
    }

    HyprlandFocusGrab {
        active: root.opened
        windows: [root]
        onCleared: root.opened = false
    }

    SequentialAnimation {
        id: openAnimation

        ScriptAction {
            script: {
                popupBody.transformOrigin = Item.Top;
                popupBody.opacity = 0;
                popupBody.scale = 0.97;
            }
        }

        ParallelAnimation {
            NumberAnimation {
                target: popupBody
                property: "opacity"
                to: 1
                duration: 140
                easing.type: Easing.OutCubic
            }

            NumberAnimation {
                target: popupBody
                property: "scale"
                to: 1
                duration: 140
                easing.type: Easing.OutCubic
            }

        }

    }

    SequentialAnimation {
        id: closeAnimation

        ParallelAnimation {
            NumberAnimation {
                target: popupBody
                property: "opacity"
                to: 0
                duration: 100
                easing.type: Easing.InCubic
            }

            NumberAnimation {
                target: popupBody
                property: "scale"
                to: 0.97
                duration: 100
                easing.type: Easing.InCubic
            }

        }

        ScriptAction {
            script: {
                if (!root.opened)
                    root.animationVisible = false;

            }
        }

    }

}
