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
        width: 400
        height: 200
        anchors.centerIn: parent

        Column{
            anchors.centerIn: parent
            spacing: 8

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Relay Timers"
		color: "black"
                font.pixelSize: 20
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Author: Phillip Haeusler"
		color: "black"
                font.pixelSize: 20
            }
            
	    Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Contact: philliphaeusler@yahoo.com"
		color: "black"
                font.pixelSize: 20
            }
            
	    Rectangle {
		  id: closeButton
		  anchors.horizontalCenter: parent.horizontalCenter
		  color: "lightsteelblue"; width: 84; height: 64; smooth: true
		  scale: closeButtonArea.pressed ? 1.2 : 1
		  Text { anchors.centerIn: parent; font.pixelSize: 20; text: "Close" }
		  MouseArea { id: closeButtonArea; anchors.fill: parent; onClicked: dialogComponent.destroy() }
	    }
        }
    }
}
