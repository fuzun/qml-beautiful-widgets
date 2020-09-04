/*
 * MIT License
 * Copyright (c) 2020 fuzun
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
*/

import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Universal 2.12

import QtGraphicalEffects 1.0

import Qt.labs.settings 1.1

import "."

ApplicationWindow {
  id: root

  visible: true

  width: 1280
  height: 720

  Universal.theme: windowSettings.isThemeDark ? Universal.Dark : Universal.Light
  Universal.accent: Universal.Violet

  readonly property bool isThemeDark: Universal.theme === Universal.Dark ? true : false

  property alias bgItem: root.background

  Settings {
    id: windowSettings

    property alias x: root.x
    property alias y: root.y
    property alias width: root.width
    property alias height: root.height

    property bool isThemeDark: root.Universal.theme
    property bool bgImageEnabled: true
    property bool bgRandomize: true
  }

  AppMenu {
    id: appMenu

    settings: [windowSettings, mainView.viewSettings]
  }

  header: Item {
    id: headerItem
    implicitHeight: title.height

    FastBlur {
      anchors.fill: parent

      radius: 64
      source: ShaderEffectSource {
        sourceItem: bgItem
        sourceRect: Qt.rect(0, 0, headerItem.width, headerItem.height)
        visible: false
      }
    }

    ToolButton {
      id: menuButton

      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter

      implicitHeight: parent.implicitHeight

      text: "\u2630"

      onClicked: {
        appMenu.popup()
      }
    }

    Label {
      id: title
      anchors.centerIn: parent
      text: AppSettings.title_alt
      font.pointSize: 11

      horizontalAlignment: Text.AlignHCenter
    }

    Switch {
      id: themeSwitch
      anchors.right: parent.right

      anchors.verticalCenter: parent.verticalCenter
      checked: windowSettings.isThemeDark
      text: qsTr("Dark mode")

      onCheckedChanged: {
        if(checked) {
          darkBg.randomize()
          windowSettings.isThemeDark = true
        }
        else {
          lightBg.randomize()
          windowSettings.isThemeDark = false
        }
      }
    }
  }

  title: AppSettings.title

  minimumWidth: AppSettings.expandableViewWidth * 1.5
  minimumHeight: 360

  function getBgImage(isDark, _random) {
    let dir = isDark === true ? AppSettings.bgDarkImagesDir : AppSettings.bgLightImagesDir
    let imgList = intf.getDirFileList(dir)

    if (_random === false)
      return 'qrc' + imgList[0]

    let random = AppSettings.randomInt(0, imgList.length)

    return 'qrc' + imgList[random]
  }

  background: Item {

    state: isThemeDark ? "dark" : "light"

    states: [
      State {
        name: "dark"
      },

      State {
        name: "light"
      }
    ]

    transitions: [
      Transition {
        from: "dark"
        to: "light"

        ParallelAnimation {
          NumberAnimation { target: darkBg; property: "opacity"; from: 1.0; to: 0.0; duration: 250; easing.type: Easing.OutSine }
          NumberAnimation { target: lightBg; property: "opacity"; from: 0.0; to: 1.0; duration: 250; easing.type: Easing.InSine }
        }
      },

      Transition {
        from: "light"
        to: "dark"

        ParallelAnimation {
          NumberAnimation { target: darkBg; property: "opacity"; from: 0.0; to: 1.0; duration: 250; easing.type: Easing.InSine }
          NumberAnimation { target: lightBg; property: "opacity"; from: 1.0; to: 0.0; duration: 250; easing.type: Easing.OutSine }
        }
      }
    ]

    Image {
      id: darkBg
      anchors.fill: parent
      source: getBgImage(true, windowSettings.bgRandomize)
      fillMode: Image.PreserveAspectCrop
      opacity: isThemeDark ? 1.0 : 0.0

      function randomize() {
        source = getBgImage(true, windowSettings.bgRandomize)
      }
    }

    Image {
      id: lightBg
      anchors.fill: parent
      source: getBgImage(false, windowSettings.bgRandomize)
      fillMode: Image.PreserveAspectCrop
      opacity: isThemeDark ? 0.0 : 1.0

      function randomize() {
        source = getBgImage(false, windowSettings.bgRandomize)
      }
    }

    Rectangle {
      anchors.fill: parent
      color: isThemeDark ? "black" : "white"
      visible: !windowSettings.bgImageEnabled
    }
  }

  MainView {
    id: mainView

    z: -1
    anchors.fill: parent
    anchors.margins: 20
  }
}
