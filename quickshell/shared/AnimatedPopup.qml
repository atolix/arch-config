import QtQuick
import Quickshell

PopupWindow {
    id: root

    required property Item animatedItem
    property bool opened: false
    property bool animationVisible: false

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

    SequentialAnimation {
        id: openAnimation
        ScriptAction {
            script: {
                root.animatedItem.transformOrigin = Item.Top;
                root.animatedItem.opacity = 0;
                root.animatedItem.scale = 0.97;
            }
        }
        ParallelAnimation {
            NumberAnimation {
                target: root.animatedItem
                property: "opacity"
                to: 1
                duration: 140
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: root.animatedItem
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
                target: root.animatedItem
                property: "opacity"
                to: 0
                duration: 100
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                target: root.animatedItem
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
