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

pragma Singleton

import QtQml 2.12

QtObject {
  readonly property real expandableViewWidth: 275
  readonly property int expandableViewAnimationDuration: 150
  readonly property int expandableViewHeaderHeight: 50

  readonly property string bgDarkImagesDir: ":/assets/images/bg_dark"
  readonly property string bgLightImagesDir: ":/assets/images/bg_light"

  readonly property string title: qsTr("qml-beautiful-widgets - github.com/fuzun/qml-beautiful-widgets - fuzun, 2020")
  readonly property string title_alt: qsTr("qml-beautiful-widgets\ngithub.com/fuzun/qml-beautiful-widgets\nfuzun, 2020")

  function randomInt(min, max) {
    return Math.floor(Math.random() * (max - min) + min);
  }
}
