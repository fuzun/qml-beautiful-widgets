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
import QtQuick.Controls 2.12

import QtGraphicalEffects 1.0

Item {
  id: root

  implicitHeight: childrenRect.height
  implicitWidth:  childrenRect.width

  property var contentComponent: undefined
  property alias title: headerText.text

  readonly property bool isExpanded: root.state === "expanded" ? true : false

  property bool isThemeDark: false

  property point pos: Qt.point(root.x, root.y)
  property var blurSource: undefined

  property real widgetWidth: 300
  property int animationDuration: 150
  property real headerHeight: 50

  property real contentMargin: 10

  onIsExpandedChanged: {
    if (isExpanded) {
      glow.visible = false
    }
  }

  state: "retracted"

  states: [
    State {
      name: "retracted"
    },

    State {
      name: "expanded"
    }
  ]

  transitions: [
    Transition {
      from: "retracted"
      to: "expanded"

      ParallelAnimation {
        RotationAnimation { target: arrow; to: 180; duration: animationDuration }
        NumberAnimation { target: content; property: "implicitHeight";
          to: actualContent.implicitHeight + actualContent.anchors.topMargin + actualContent.anchors.bottomMargin + timeStamp.implicitHeight;
          duration: animationDuration; easing.type: Easing.InSine }
      }
    },

    Transition {
      from: "expanded"
      to: "retracted"

      ParallelAnimation {
        RotationAnimation { target: arrow; to: 0; duration: animationDuration }
        NumberAnimation { target: content; property: "implicitHeight"; to: 0; duration: animationDuration; easing.type: Easing.OutSine }
      }
    }
  ]

  Item {
    id: header

    z: 1

    width: widgetWidth
    height: headerHeight

    MouseArea {
      anchors.fill: parent

      onClicked: {
        root.state = isExpanded ? "retracted" : "expanded"
      }
    }

    FastBlur {
      anchors.fill: parent

      radius: 96
      source: ShaderEffectSource {
        sourceItem: blurSource
        sourceRect: Qt.rect(pos.x, pos.y, header.width, header.height)
      }
    }

    Rectangle {
      id: headerBgRect

      anchors.fill: parent
      color: isThemeDark ? "darkgray" : "lightgray"
      opacity: 0.5
    }

    Label {
      id: headerText
      text: !!actualContent.item.title ? actualContent.item.title : "N/A"

      font.pointSize: 11

      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: 10
    }

    Label {
      id: arrow
      text: "\u02C5"

      font.pointSize: 14
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.rightMargin: 10
    }
  }

  RectangularGlow {
    id: glow

    anchors.fill: isExpanded ? root : header
    glowRadius: 18
    spread: 0.2
    color: isThemeDark ? (_send ? "darkred" : "lime") : (_send ? "red" : "green")

    visible: false

    property bool _send: false

    function activate(send) {
      glow._send = send
      glowAnimation.restart()
    }

    NumberAnimation {
      id: glowAnimation
      target: glow
      properties: "glowRadius"

      from: 18
      to: isExpanded ? 0 : 8
      duration: 500
      easing.type: Easing.OutSine

      onStopped: {
        if (isExpanded)
          glow.visible = false
      }
      onStarted: {
        glow.visible = true
      }
    }
  }

  Item {
    id: content

    z: 0
    anchors.top: header.bottom

    implicitHeight: 0
    implicitWidth: header.width

    clip: true

    FastBlur {
      anchors.fill: parent

      radius: 64
      source: ShaderEffectSource {
        sourceItem: blurSource
        sourceRect: Qt.rect(pos.x, pos.y + header.height, content.width, content.height)
      }
    }

    Rectangle {
      anchors.fill: parent
      color: headerBgRect.color
      opacity: 0.3
    }

    Loader {
      id: actualContent

      anchors.top: parent.top
      anchors.left: parent.left
      anchors.right: parent.right

      anchors.topMargin: root.contentMargin
      anchors.bottomMargin: root.contentMargin
      anchors.leftMargin: root.contentMargin
      anchors.rightMargin: root.contentMargin

      sourceComponent: contentComponent

      Connections {
        target: actualContent.item

        ignoreUnknownSignals: true

        onReceived: {
          glow.activate(false)
          activityLabel.updateTime()
        }

        onSent: {
          glow.activate(true)
          activityLabel.updateTime()
        }
      }
    }

    Column {
      id: timeStamp

      // last received date
      anchors {
        top: actualContent.bottom
        left: parent.left
        right: parent.right
        topMargin: 5
      }

      spacing: 5

      Rectangle {
        opacity: 0.5
        color: isThemeDark ? "darkgray" : "lightgray"

        height: 1
        width: parent.width
      }

      Label {
        id: activityLabel

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: root.contentMargin

        function updateTime() {
          let date = new Date()
          activityLabel.text = qsTr("%1/%2 - %3:%4:%5::%6").arg(date.getDay())
                                                           .arg(date.getMonth())
                                                           .arg(date.getHours())
                                                           .arg(date.getMinutes())
                                                           .arg(date.getSeconds())
                                                           .arg(date.getMilliseconds())
        }

        text: "N/A"
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignBottom
      }
    }
  }
}
