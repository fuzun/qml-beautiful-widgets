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

Item {
  id: root

  implicitHeight: checkBox.height
  implicitWidth: row.implicitWidth

  property bool autoState: false

  property real autoBindInterval: 125

  signal increase(var pressed)
  signal decrease(var pressed)
  signal autoChanged(var auto)

  Row {
    id: row
    anchors.fill: parent
    anchors.horizontalCenter: parent.horizontalCenter

    spacing: 1

    RoundButton {
      implicitHeight: parent.height
      implicitWidth: implicitHeight

      text: "+"

      onPressed: {
        increase(true)
      }

      onReleased: {
        increase(false)
      }
    }

    CheckBox {
      id: checkBox
      text: qsTr("Auto")
      font.pointSize: 8

      height: implicitHeight * 0.75

      checked: autoState

      onReleased: {
        if(checked) {
          autoChanged(true)
        }
        else {
          autoChanged(false)
        }

        checkBinder.restart()
      }

      Timer {
        id: checkBinder
        interval: autoBindInterval
        repeat: false

        onTriggered: {
          checkBox.checked = Qt.binding(function() {return root.autoState;})
        }
      }
    }

    RoundButton {
      implicitHeight: parent.height

      implicitWidth: implicitHeight

      text: "-"

      onPressed: {
        decrease(true)
      }

      onReleased: {
        decrease(false)
      }
    }
  }
}
