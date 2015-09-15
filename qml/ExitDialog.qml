import QtQuick 2.3

Item {
    id: dialogComponent
    anchors.fill: parent

    // Add a simple animation to fade in the popup
    // let the opacity go from 0 to 1 in 400ms
    PropertyAnimation {
        target: dialogComponent; property: "opacity";
        duration: 400; from: 0; to: 1;
        easing.type: Easing.InOutQuad ; running: true }

    // This rectange is the a overlay to partially show the parent through it
    // and clicking outside of the 'dialog' popup will do 'nothing'
    Rectangle {
        anchors.fill: parent
        id: overlay
        color: "#000000"
        opacity: 0.6
        // add a mouse area so that clicks outside
        // the dialog window will not do anything
        MouseArea {
            anchors.fill: parent
        }
    }

    // This rectangle is the actual popup
    Rectangle {
        id: dialogWindow
        width: 600
        height: 150
        anchors.centerIn: parent

        Column{
            anchors.centerIn: parent
            spacing: 20

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Are you sure you want to quit?"
                font.pixelSize: 26
            }

            Row{
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 50

                Rectangle {
                     id: yesButton
                     //anchors {verticalCenter: parent.verticalCenter; margins: 24 }
                     color: "lightsteelblue"; width: 64; height: 64; smooth: true
                     scale: yesButtonArea.pressed ? 1.2 : 1
                     Text { anchors.centerIn: parent; font.pixelSize: 22; text: "Yes" }
                     MouseArea { id: yesButtonArea; anchors.fill: parent; onClicked: { dialogComponent.destroy(); Qt.quit() } }
                }

                Rectangle {
                     id: noButton
                     //anchors {left: yesButton.right; verticalCenter: parent.verticalCenter; margins: 24 }
                     //anchors.left: yesButton.right
                     color: "lightsteelblue"; width: 64; height: 64; smooth: true
                     scale: noButtonArea.pressed ? 1.2 : 1
                     Text { anchors.centerIn: parent; font.pixelSize: 22; text: "No" }
                     MouseArea { id: noButtonArea; anchors.fill: parent; onClicked: dialogComponent.destroy() }
                }
            }
        }
    }
}
