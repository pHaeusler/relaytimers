import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import Qt.labs.settings 1.0

Rectangle
{
    id: relayControls
    width: 120
    height: standardColumns.height

    color: "transparent"

    border.color: "lightsteelblue"
    border.width: 2

    property int relayIndex
    property int interval
    property alias enabled: selectorSwitch.checked
    property int intervalMultiplier
    property alias name: relayName.text
    property bool notesVisible: false

    onHeightChanged: relayGrid.cellHeight = height*1.05

    Settings {
        id: settings
        category: "relay"+relayIndex
        property alias interval: relayControls.interval
        property alias enabled: relayControls.enabled
        property alias intervalMultiplier: relayControls.intervalMultiplier
        property alias name: relayControls.name
    }

    onIntervalMultiplierChanged: controller.setRelayInterval(relayIndex, interval*intervalMultiplier)

    Component.onCompleted: {
        controller.setRelayEnabled(relayIndex, enabled)
        controller.setRelayInterval(relayIndex, interval*intervalMultiplier)
    }

    Rectangle{
        anchors.fill: parent
        color: "transparent"

        ColumnLayout {
            id: standardColumns
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            visible: !notesVisible
            spacing: 15

            Item{
                height: 1
            }

            TextInput {
                id: relayName
                text: "Relay " + relayIndex
                color: "black"; font.pixelSize: 16;
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Switch{
                id: selectorSwitch
                anchors.horizontalCenter: parent.horizontalCenter
                checked: true
                onCheckedChanged: controller.setRelayEnabled(relayIndex, checked)
            }

            Label {
                id: intervalLabel
                text: interval
                color: "black"; font.pixelSize: 16;
                anchors.horizontalCenter: parent.horizontalCenter
            }

            RowLayout {
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                     id: minusButton
                     color: "lightsteelblue"
                     width: 30; height: 30; smooth: true
                     scale: minusButtonArea.pressed ? 1.2 : 1
                     border.color: "dimgray"
                     border.width: 1
                     Text {
                         anchors.centerIn: parent;
                         color: "black";
                         font.pixelSize: 16;
                         text: "-"
                     }
                     MouseArea {
                         id: minusButtonArea;
                         anchors.fill: parent;
                         onClicked: {
                             if (interval > 0){
                                 interval -= 1
                                 controller.setRelayInterval(relayIndex, interval*intervalMultiplier)
                             }
                         }
                     }
                }

                Rectangle {
                     id: plusButton
                     color: "lightsteelblue"
                     width: 30; height: 30; smooth: true
                     scale: plusButtonArea.pressed ? 1.2 : 1
                     border.color: "dimgray"
                     border.width: 1
                     Text {
                         anchors.centerIn: parent;
                         color: "black";
                         font.pixelSize: 16;
                         text: "+"
                     }
                     MouseArea {
                         id: plusButtonArea;
                         anchors.fill: parent;
                         onClicked: {
                             interval += 1
                             controller.setRelayInterval(relayIndex, interval*intervalMultiplier)
                         }
                     }
                }
            }

            Rectangle {
                 id: onceOffButton
                 anchors.horizontalCenter: parent.horizontalCenter
                 color:"white"
                 width: 60
                 height: 30
                 smooth: true
                 scale: onceOffButtonArea.pressed ? 1.2 : 1
                 border.color: "lightsteelblue"
                 border.width: 1
                 visible: !controller.running

                 Text {
                     anchors.centerIn: parent;
                     color: "black";
                     font.pixelSize: 16;
                     text: "Test"
                 }
                 MouseArea {
                     id: onceOffButtonArea;
                     anchors.fill: parent;
                     onClicked: controller.relayState(relayIndex) ? controller.stopRelay(relayIndex) : controller.startRelay(relayIndex)
                 }
            }

            /*
            Label {
                id: index
                text: "Relay: " + relayIndex
                color: "black"; font.pixelSize: 12;
                anchors.horizontalCenter: parent.horizontalCenter
            }
            */

            Item{
                height: 1
            }
        }

        Rectangle{
            id: notesContainer
            anchors { top:parent.top; bottom: dispNotesBox.top; left: parent.left; right: parent.right }
            visible: notesVisible
            color: "transparent"

            TextArea {
                id: notes
                wrapMode: Text.WordWrap
                textColor: "black"; font.pixelSize: 12;
                textMargin: 3
                anchors{ fill: parent; margins: 5 }
                backgroundVisible: false
            }
        }


        Rectangle {
            id: dispNotesBox
            anchors { bottom: parent.bottom; right: parent.right; margins: 10}
            color: notes.text.length > 1 ? "violet" : "lavender"
            width: 10
            height: 10

            border.width: 1
            border.color: "steelblue"

            MouseArea {
                id: dispNotesMouseArea
                anchors.fill: parent
                onClicked: {
                    if ( notesVisible ){
                        notesVisible = false
                        console.log(notes.getText().length)
                    } else {
                        notesVisible = true
                        notes.forceActiveFocus()
                    }
                }
            }
        }
    }
}


