import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Universal 2.12

import Qt.labs.settings 1.1

import "Widgets" as Widgets

Item {
    id: mainView

    Settings {
        id: viewSettings

        property alias sample1_state: sample1.state
        property alias sample2_state: sample2.state
        property alias sample3_state: sample3.state
        property alias sample4_state: sample4.state
        property alias sample5_state: sample5.state
        property alias sample6_state: sample6.state
        property alias sample7_state: sample7.state
    }

    Component {
        id: sampleComponent1

        Item {
            id: _item1
            implicitHeight: childrenRect.height

            property string title: "Sample 1"

            signal received()
            signal sent()

            Grid {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top

                rowSpacing: 5
                columnSpacing: 10

                columns: 2

                Label {
                    text: "Lorem Ipsum:"
                }
                Label {
                    text: "Dolor Sit"
                }
                Label {
                    text: "Interactive Label (1):"
                }
                Widgets.InteractiveLabel {
                    implicitWidth: _item1.width - x

                    isTextField: true

                    text: "ABCD"

                    onTextFieldChanged: {
                        _item1.received()
                    }
                }

                Label {
                    text: "Interactive Label (2):"
                }
                Widgets.InteractiveLabel {
                    implicitWidth: _item1.width - x

                    isTextField: true

                    text: "-34.26"
                    textFieldAcceptOnlyFloat: true

                    onTextFieldChanged: {
                        _item1.received()
                    }
                }

                Label {
                    text: "Interactive Label (3):"
                }

                Widgets.InteractiveLabel {
                    implicitWidth: _item1.width - x

                    text: "Item2"


                    comboBoxModel: Widgets.MapModel {
                        map: (new Map([
                                          [2, "Item1"],
                                          [4, "Item2"],
                                          [8, "Item3"],
                                          [16, "Item4"]
                                      ]))
                    }

                    onComboBoxSet: {
                        _item1.sent()
                    }
                }

                Label {
                    text: "Inc/Dec Field:"
                }
                Widgets.IncDecBar {
                    onIncrease: {
                        if(pressed)
                            sent()
                    }

                    onDecrease: {
                        if(pressed)
                            received()
                    }

                    onAutoChanged: {
                        sent()
                    }
                }
            }
        }
    }

    Component {
        id: sampleComponent2

        Item {

            property string title: "Sample 2"

            implicitHeight: childrenRect.height

            Grid {
                rowSpacing: 5
                columnSpacing: 10

                columns: 2

                Label {
                    text: "test1"
                }
                Label {
                    text: "test2"
                }
                Label {
                    text: "test3"
                }
                Label {
                    text: "test4"
                }
            }
        }
    }

    Component {
        id: sampleComponent3

        Item {
            property string title: "Sample 4"
            implicitHeight: childrenRect.height

            Image {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                source: "qrc:/assets/images/mona-lisa.jpg"
                fillMode: Image.PreserveAspectCrop
            }
        }
    }

    BaseExpandableView {
        id: sample1

        contentComponent: sampleComponent1
    }

    BaseExpandableView {
        id: sample2

        contentComponent: sampleComponent2
    }

    BaseExpandableView {
        id: sample3

        contentComponent: sampleComponent1
    }
    BaseExpandableView {
        id: sample4

        contentComponent: sampleComponent3
    }
    BaseExpandableView {
        id: sample5

        contentComponent: sampleComponent1
    }
    BaseExpandableView {
        id: sample6

        contentComponent: sampleComponent2
    }
    BaseExpandableView {
        id: sample7

        contentComponent: sampleComponent1
    }

    Widgets.AdaptiveGridView {
        id: adaptiveGridView
        anchors.fill: parent

        bgItem: root.bgItem

        model: [sample1, sample2, sample3, sample4, sample5, sample6, sample7]
    }
}
