import QtQuick 2.0
import SddmComponents 2.0

Rectangle {
  id: root

  width: 1920
  height: 1080
  color: "#141414"

  property color fieldColor: "#e61f222b"
  property color fieldFocusColor: "#e62c3040"
  property color textColor: "#eaeaea"
  property color errorColor: "#f38ba8"

  function tryLogin() {
    if (username.text === "") {
      username.forceActiveFocus()
      return
    }

    statusText.text = ""
    loginBusy = true
    sddm.login(username.text, password.text, sessionModel.lastIndex)
  }

  property bool loginBusy: false

  Connections {
    target: sddm

    onLoginSucceeded: {
      root.loginBusy = false
    }

    onLoginFailed: {
      root.loginBusy = false
      password.text = ""
      statusText.text = textConstants.loginFailed
      password.forceActiveFocus()
    }

    onInformationMessage: {
      root.loginBusy = false
      statusText.text = message
    }
  }

  TextConstants {
    id: textConstants
  }

  Image {
    anchors.fill: parent
    source: "pictures/wallpapers/v1.jpg"
    fillMode: Image.PreserveAspectCrop
    horizontalAlignment: Image.AlignHCenter
    verticalAlignment: Image.AlignVCenter
  }

  Rectangle {
    anchors.fill: parent
    color: "#b8141414"
  }

  Column {
    id: loginForm

    anchors.centerIn: parent
    width: Math.min(320, parent.width - 48)
    spacing: 16

    Rectangle {
      width: parent.width
      height: 58
      radius: 6
      color: username.activeFocus ? root.fieldFocusColor : root.fieldColor
      border.color: username.activeFocus ? "#a5b4fc" : "#414552"
      border.width: 1

      Text {
        anchors.fill: parent
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        text: textConstants.userName
        color: "#777d91"
        font.pixelSize: 17
        verticalAlignment: Text.AlignVCenter
        visible: username.text === "" && !username.activeFocus
      }

      TextInput {
        id: username

        anchors.fill: parent
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        color: root.textColor
        selectionColor: "#66ffffff"
        selectedTextColor: root.textColor
        font.pixelSize: 18
        verticalAlignment: TextInput.AlignVCenter
        selectByMouse: true
        enabled: !root.loginBusy

        KeyNavigation.tab: password

        Keys.onReturnPressed: password.forceActiveFocus()
        Keys.onEnterPressed: password.forceActiveFocus()
      }
    }

    Rectangle {
      width: parent.width
      height: 58
      radius: 6
      color: password.activeFocus ? root.fieldFocusColor : root.fieldColor
      border.color: password.activeFocus ? "#a5b4fc" : "#414552"
      border.width: 1

      Text {
        anchors.fill: parent
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        text: textConstants.password
        color: "#777d91"
        font.pixelSize: 17
        verticalAlignment: Text.AlignVCenter
        visible: password.text === "" && !password.activeFocus
      }

      TextInput {
        id: password

        anchors.fill: parent
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        color: root.textColor
        selectionColor: "#66ffffff"
        selectedTextColor: root.textColor
        font.pixelSize: 18
        verticalAlignment: TextInput.AlignVCenter
        echoMode: TextInput.Password
        selectByMouse: true
        enabled: !root.loginBusy

        KeyNavigation.tab: username

        Keys.onReturnPressed: root.tryLogin()
        Keys.onEnterPressed: root.tryLogin()
      }
    }

    Text {
      id: statusText

      width: parent.width
      color: root.errorColor
      font.pixelSize: 14
      horizontalAlignment: Text.AlignHCenter
      wrapMode: Text.WordWrap
      visible: text !== ""
    }
  }

  Component.onCompleted: username.forceActiveFocus()
}
