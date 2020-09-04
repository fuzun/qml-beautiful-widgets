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

  implicitWidth: label.width * 2
  implicitHeight: label.height * 1.5

  clip: true

  // determines what the label turns into (text field or a combobox) when hovered:
  property bool isTextField: comboBoxModel.count > 0 ? false : true
  property bool textFieldAcceptOnlyFloat: false

  property var text: "N/A"

  onTextChanged: {
    if (!isTextField)
      loader.item.updateIndex()
  }

  property var comboBoxModel: []

  readonly property var _comboBoxModelCount: comboBoxModel.count
  on_ComboBoxModelCountChanged: {
    if (!isTextField)
      loader.item.updateIndex()
  }

  property real animationDuration: 250
  property bool instantFocus: true

  signal comboBoxSet(var selected)
  signal textFieldChanged(var string)

  function bindVisibility() {
    loader.visible = Qt.binding(function () {return ((isTextField && loader.item.length > 0)
                                             || (!isTextField && loader.item.popup.opened)
                                             || mouseArea.containsMouse);} )

    label.visible = Qt.binding(function () {return (!mouseArea.containsMouse);} )
  }

  Component.onCompleted: {
    bindVisibility()
  }

  MouseArea {
    id: mouseArea

    anchors.fill: parent

    hoverEnabled: true

    property point _capturedMousePos: Qt.point(-1, -1)

    function captureMousePos() {
      if (mouseArea._capturedMousePos === Qt.point(-1, -1))
        return

      if (mouseArea.mouseX !== mouseArea._capturedMousePos.x || mouseArea.mouseY !== mouseArea._capturedMousePos.y) {
        bindVisibility()
        mouseArea._capturedMousePos = Qt.point(-1, -1)
      }
    }

    onMouseXChanged: {
      captureMousePos()
    }

    onMouseYChanged: {
      captureMousePos()
    }

    onClicked: {
      bindVisibility()
    }

    NumberAnimation {
      id: animationLoader
      target: loader
      properties: "x"
      from: 0
      to: loader.width
      duration: animationDuration

      easing.type: Easing.InBack

      onStarted: {
        label.visible = false
        loader.visible = true
      }

      onStopped: {
        loader.visible = false
        loader.x = 0

        animationLabel.restart()
      }
    }

    NumberAnimation {
      id: animationLabel
      target: label
      properties: "x"
      from: -(label.implicitWidth)
      to: 0
      duration: animationLoader.duration * 6 / 7

      easing.type: Easing.OutBack

      onStarted: {
        label.visible = true
      }

      onStopped: {
        mouseArea._capturedMousePos = Qt.point(mouseArea.mouseX, mouseArea.mouseY)
      }
    }

    Label {
      id: label
      text: root.text
    }

    Component {
      id: textFieldComponent

      TextField {
        id: textField
        placeholderText: label.text

        focus: true

        onHoveredChanged: {
          if (root.instantFocus && hovered)
            textField.forceActiveFocus()
        }

        validator: RegExpValidator { regExp: root.textFieldAcceptOnlyFloat ? /[\-\+]?[0-9]*(\.[0-9]+)?/ : /[\s\S]*/}

        Keys.onEnterPressed: {
          if (!animationLoader.running && !animationLabel.running && loader.visible)
            textFieldButton.clicked()
        }

        Keys.onReturnPressed: {
            textField.Keys.enterPressed(null)
        }

        Button {
          id: textFieldButton

          anchors.top: parent.top
          anchors.bottom: parent.bottom
          anchors.right: parent.right

          text: "\u2713"

          onClicked: {
            root.textFieldChanged(textField.text)
            textField.clear()

            animationLoader.restart()
          }
        }
      }
    }

    Component {
      id: comboBoxComponent

      ComboBox {
        id: comboBox
        model: root.comboBoxModel

        textRole: "text"

        function updateIndex() {
          for(let i = 0; i < comboBox.model.count; ++i) {
            if (comboBox.model.get(i).text === root.text) {
              comboBox.currentIndex = i
              return
            }
          }
          comboBox.currentIndex = -1
        }

        Component.onCompleted: {
          updateIndex()
        }

        focus: true

        onHoveredChanged: {
          if (root.instantFocus && hovered)
            comboBox.forceActiveFocus()
        }
      }
    }

    Connections {
      target: loader.item

      ignoreUnknownSignals: true

      // combobox
      onActivated: {
        root.comboBoxSet(comboBoxModel.get(loader.item.currentIndex))

        loader.item.updateIndex()

        animationLoader.restart()
      }
    }

    Loader {
      id: loader

      width: parent.width
      height: parent.height

      sourceComponent: isTextField ? textFieldComponent : comboBoxComponent
    }
  }
}
