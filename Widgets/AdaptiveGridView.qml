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

// Width-aware GridView Widget
//
// Description: a widget contains a set of rows and columns
// which behaves like a grid. It adapts to the width changes
// by rearranging containing items hence the name 'adaptive'.

import QtQml 2.12
import QtQml.Models 2.12

import QtQuick 2.12
import QtQuick.Controls 2.12

Item {
  id: root
  anchors.fill: parent

  visible: model.length > 0

  property var bgItem: undefined // background item for pos update

  property var model: []
  property real verticalSpacing: 20

  // currently varied column width is not supported
  readonly property real _columnWidth: model.length > 0 ? model[0].implicitWidth  : 0

  property real safetyMargins: 15

  Component.onCompleted: {
    row.fill()
  }

  onModelChanged: {
    row.fill()
  }

  Row {
    id: row
    anchors.fill: parent

    function arrangeItems() {
      let rowCount = rowModel.count
      let modelCount = root.model.length
      let i

      // clear all:
      for(i = 0; i < rowCount; i++) {
        rowModel.get(i).model.clear()
      }

      if (modelCount === 0 || rowCount === 0)
        return

      // distribute items:
      let tracker = 0
      for(i = 0; i < modelCount; i++) {
        if(tracker === rowCount)
          tracker = 0

        rowModel.get(tracker).model.append(root.model[i])
        tracker++
      }
    }

    Repeater {
      model: ObjectModel {
        id: rowModel

        onCountChanged: {
          row.arrangeItems()
        }
      }
    }

    Item {
      // this is required to prevent a bug
      // which I suspect it to be related to garbage collection
      id: dummyContainer
      visible: false
    }

    function fill() {
      let columnsAvailable = Math.max(Math.floor(row.width / (root._columnWidth + (safetyMargins * 2))), 0)

      if (columnsAvailable === 0) {
        rowModel.clear()
        return
      }

      let curModelCount = rowModel.count

      if (columnsAvailable > curModelCount) {
        for (let i = 0; i < columnsAvailable - curModelCount; i++) {
          rowModel.append(verticalComponent.createObject(dummyContainer, {"height": Qt.binding(function () {return row.height})}))
        }
      }
      else if (columnsAvailable < curModelCount) {
        for (let i = 0; i < curModelCount - columnsAvailable; i++) {
          rowModel.remove(rowModel.count - 1 - i)
        }
      }
      else { // columnsAvailable === curModelCount
        return
      }
    }

    onWidthChanged: {
      fill()
    }
  }

  Component {
    id: verticalComponent

    Flickable {
      id: vertical

      // width must be the same for every item
      implicitWidth: root._columnWidth + (leftMargin + rightMargin)

      clip: true
      contentHeight: column.height
      ScrollBar.vertical: ScrollBar { id: scrollBar }

      // spacing needed for glow effect:
      bottomMargin: safetyMargins
      topMargin: safetyMargins
      leftMargin: safetyMargins
      rightMargin: safetyMargins

      property alias model: repeater.model

      Column {
        id: column

        spacing: root.verticalSpacing

        Repeater {
          id: repeater
          model: ObjectModel { }
        }
      }

      function updateModelPos() {
        for(let i = 0; i < vertical.model.count; ++i) {
          let item = vertical.model.get(i)
          let map = column.mapToItem(bgItem, item.x, item.y)
          item.pos = Qt.point(map.x, map.y)
        }
      }

      onContentXChanged: {
        updateModelPos()
      }

      onContentYChanged: {
        updateModelPos()
      }

      onContentHeightChanged: {
        updateModelPos()
      }
    }
  }
}
