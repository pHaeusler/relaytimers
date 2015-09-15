import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import Qt.labs.settings 1.0
import lib 1.0

ApplicationWindow {
    id: applicationWindow
    visible: true
    title: "Relay Timers"
    //visibility: "FullScreen"

    Settings {
        id: settings
        category: "window"
        property alias x: applicationWindow.x
        property alias y: applicationWindow.y
        property alias width: applicationWindow.width
        property alias height: applicationWindow.height
    }

    property int intervalMultiplier: 1

    function displayStatus(){
        if ( controller.scheduled && !controller.running ){
            runDateTimeLabel.text = "Next Scheduled Run: " +
            Qt.formatDateTime(controller.runDateTime, "hh:mm on dd/MM/yyyy")
        } else if ( controller.running && !controller.paused){
            runDateTimeLabel.text = "Running"
        } else if ( controller.paused ){
            runDateTimeLabel.text = "Paused"
        } else {
            runDateTimeLabel.text = "No Scheduled Run"
        }
    }

    Controller {
        id: controller

        onCurrentRelayChanged: relayGrid.currentIndex = controller.currentRelay
        onScheduledChanged: applicationWindow.displayStatus()
        onRunningChanged: applicationWindow.displayStatus()
        onRunDateTimeChanged: applicationWindow.displayStatus()
        onPausedChanged: applicationWindow.displayStatus()
    }

    function openSubMenu(index){
        if ( index == menuList.currentIndex && sub_menu_view.isOpen ){
            sub_menu_view.isOpen = false
        }
        else if ( menuList.currentIndex == 0 ){
            Qt.createComponent("AboutDialog.qml").createObject(applicationWindow, {})
        }
        else if ( menuList.currentIndex == 1 ){
            sub_menu_view.isOpen = true
            unitsMenuList.isOpen = true
            startTimeMenuList.isOpen = false
            scheduleMenuList.isOpen = false
        }
        else if ( menuList.currentIndex == 2){
            sub_menu_view.isOpen = true
            unitsMenuList.isOpen = false
            startTimeMenuList.isOpen = false
            scheduleMenuList.isOpen = true
        }
        else if ( menuList.currentIndex == 3 ){
            sub_menu_view.isOpen = true
            unitsMenuList.isOpen = false
            scheduleMenuList.isOpen = false
            startTimeMenuList.isOpen = true
        }
        else if ( menuList.currentIndex == 4 ){
            Qt.createComponent("ExitDialog.qml").createObject(applicationWindow, {})
        }
    }

    function closeSubMenu(){
        sub_menu_view.isOpen = false;
        menuList.isOpen = true;
        menuList.forceActiveFocus()
    }

    Rectangle {
        id: gv

        width: parent.width
        height: parent.height
        color: "black"

        property bool menu_shown: false
        property bool sub_menu_shown: false
        
        Rectangle {
            id: menu_view
            anchors.top: parent.top
            anchors.left: parent.left

            property bool isOpen: false
            onIsOpenChanged: {
                if(isOpen) { menuList.isOpen = true; }
                else{
                    sub_menu_view.isOpen = false
                    menuList.isOpen = false
                }
                game_translate.x = isOpen ? width : 0
            }

            width: 250
            height: parent.height

            color: "#303030";
            opacity: isOpen ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 300 } }

            MouseArea{
                id: menu_view_ma
                anchors.fill: parent
                onEntered: menuList.forceActiveFocus()
            }

            ListModel {
                id: menuModel
                ListElement { label: "About" }
                ListElement { label: "Units" }
                ListElement { label: "Schedule" }
                ListElement { label: "Start Time" }
                ListElement { label: "Exit" }
            }

            ListView {
                id: menuList
                anchors { fill: parent; margins: 20 }
                currentIndex: -1
                spacing: 20
                property bool isOpen: false
                focus: isOpen
                visible: isOpen
                
                Keys.onLeftPressed: menu_view.isOpen = false
                Keys.onRightPressed: openSubMenu(menuList.currentIndex)
                Keys.onEnterPressed: openSubMenu(menuList.currentIndex)

                model: menuModel
                delegate: Item {
                        width: parent.width
                        height: menuText.height
                        Text {
                            id: menuText
                            color: "white"
                            font.pixelSize: 26
                            text: label
                        }
                        MouseArea{
                            id: menuMouseArea
                            anchors.fill: parent
                            onEntered: {
                                menuList.forceActiveFocus()
                                menuList.currentIndex = index
                                openSubMenu(index)
                            }
                        }
                    }

                highlight: Rectangle { color: 'lightsteelblue' }
            }
        }

        Rectangle {
            id: sub_menu_view
            anchors.top: parent.top
            anchors.left: menu_view.right

            Settings {
                id: subMenuSettings
                category: "SubMenu"
                property alias scheduleIndex: scheduleMenuList.currentIndex
                property alias unitsIndex: unitsMenuList.currentIndex
                property alias startTimeIndex: startTimeMenuList.currentIndex
            }

            Component.onCompleted: {
                controller.updateSchedule(startTimeMenuList.currentIndex,
                                          scheduleMenuList.currentIndex+1)
                if(unitsMenuList.currentIndex == 0) { intervalMultiplier = 1; }
                else { intervalMultiplier = 60; }
            }

            property bool isOpen: false
            onIsOpenChanged: {
                game_translate.x = isOpen ? menu_view.width + width : menu_view.width
                if ( !isOpen ){
                    scheduleMenuList.isOpen = false
                    startTimeMenuList.isOpen = false
                }
            }

            width: 250
            height: parent.height

            color: "#303030";
            opacity: isOpen ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 500 } }

            MouseArea{
                id: sub_menu_view_ma
                anchors.fill: parent
                onEntered: {
                    if (scheduleMenuList.isOpen) { scheduleMenuList.forceActiveFocus() }
                    else if(startTimeMenuList.isOpen) { startTimeMenuList.forceActiveFocus() }
                }
            }
            
            ListModel {
                id: scheduleMenuModel
                ListElement { label: "Daily" }
                ListElement { label: "2 Day" }
                ListElement { label: "3 Day" }
            }

            ListView {
                id: scheduleMenuList
                anchors { fill: parent; margins: 20 }
                currentIndex: 0
                spacing: 20
                property bool isOpen: false
                focus: isOpen
                visible: isOpen

                Keys.onLeftPressed: closeSubMenu()

                model: scheduleMenuModel
                delegate: Item {
                        width: parent.width
                        height: scheduleMenuText.height
                        Text {
                            id: scheduleMenuText
                            color: "white"
                            font.pixelSize: 26
                            text: label
                        }
                        MouseArea{
                            id: scheduleMenuMouseArea
                            anchors.fill: parent
                            onClicked: {
                                scheduleMenuList.currentIndex = index
                                controller.updateSchedule(startTimeMenuList.currentIndex,
                                                          scheduleMenuList.currentIndex+1)
                            }
                        }
                    }

                highlight: Rectangle { color: 'lightsteelblue' }
            }

            ListModel {
                id: unitsMenuModel
                ListElement { label: "Seconds" }
                ListElement { label: "Minutes" }
            }

            ListView {
                id: unitsMenuList
                anchors { fill: parent; margins: 20 }
                currentIndex: 0
                spacing: 20
                property bool isOpen: false
                focus: isOpen
                visible: isOpen

                Keys.onLeftPressed: closeSubMenu()

                model: unitsMenuModel
                delegate: Item {
                        width: parent.width
                        height: unitsMenuText.height
                        Text {
                            id: unitsMenuText
                            color: "white"
                            font.pixelSize: 26
                            text: label
                        }
                        MouseArea{
                            id: unitsMenuMouseArea
                            anchors.fill: parent
                            onClicked: {
                                unitsMenuList.currentIndex = index
                                if(unitsMenuList.currentIndex == 0) { intervalMultiplier = 1; }
                                else { intervalMultiplier = 60; }
                            }
                        }
                    }

                highlight: Rectangle { color: 'lightsteelblue' }
            }

            ListView {
                id: startTimeMenuList
                anchors { fill: parent; margins: 20 }
                currentIndex: 8
                spacing: 20
                property bool isOpen: false
                focus: isOpen
                visible: isOpen

                Keys.onLeftPressed: closeSubMenu()

                model: 24
                delegate: Item {
                        width: parent.width
                        height: startTimeMenuText.height
                        Text {
                            id: startTimeMenuText
                            color: "white"
                            font.pixelSize: 26
                            text: {
                                if (index < 12 ) { index + " am" }
                                else if ( index == 12 ) { "12 noon" }
                                else { (index-12) + " pm" }
                            }
                        }
                        MouseArea{
                            id: startTimeMenuMouseArea
                            anchors.fill: parent
                            onClicked: {
                                startTimeMenuList.currentIndex = index
                                controller.updateSchedule(startTimeMenuList.currentIndex,
                                                          scheduleMenuList.currentIndex+1)
                            }
                        }
                    }

                highlight: Rectangle { color: 'lightsteelblue' }
            }
        }

        /* this rectangle contains the "normal" view in your app */
        Rectangle {
            id: normal_view
            anchors.fill: parent
            color: "linen"

            transform: Translate {
                id: game_translate
                x: 0
                Behavior on x { NumberAnimation { duration: 400; easing.type: Easing.OutQuad } }
            }

            Rectangle {
                id: menuBar
                anchors.top: parent.top
                width: parent.width; height: 100; color: "darkBlue"
               Rectangle {
                    id: menuButton
                    anchors {left: parent.left; verticalCenter: parent.verticalCenter; margins: 24 }
                    color: "white"; width: 64; height: 64; smooth: true
                    scale: menuButtonArea.pressed ? 1.2 : 1
                    Text { anchors.centerIn: parent; font.pixelSize: 48; text: "!" }
                    MouseArea {
                        id: menuButtonArea;
                        anchors.fill: parent;
                        onClicked: menu_view.isOpen = !menu_view.isOpen;
                    }
                }

               Text {
                   id: runDateTimeLabel
                   text: "Not Running"
                   font.pixelSize: 26;
                   color: "white"
                   anchors.verticalCenter: parent.verticalCenter
                   anchors.horizontalCenter: parent.horizontalCenter
               }
            }

            GridView {
                id: relayGrid
                anchors { top: menuBar.bottom; bottom: bottomBar.top; left: parent.left; right: parent.right; margins: 10 }

                clip: true; model: controller.relayCount;

                cellWidth: 130
                // cellHeight is controlled by the RelayControls dynamically

                delegate: RelayControls{ relayIndex: index; intervalMultiplier: applicationWindow.intervalMultiplier }
                highlight: Rectangle { color: "lightsteelblue" }
                currentIndex: -1
                highlightFollowsCurrentItem: true
            }

            Rectangle {
                id: bottomBar
                anchors.bottom: parent.bottom
                width: parent.width; height: 100; color: "darkBlue"

               Rectangle {
                    id: runButton
                    anchors {left: parent.left; verticalCenter: parent.verticalCenter; margins: 24 }
                    color: controller.scheduled ? "dimgray" : "lightsteelblue"
                    width: 100; height: 64; smooth: true
                    scale: runButtonArea.pressed ? 1.2 : 1
                    Text { anchors.centerIn: parent; color: "black"; font.pixelSize: 22; text: "Run" }
                    MouseArea {
                        id: runButtonArea;
                        anchors.fill: parent;
                        onClicked: controller.enableSchedule(!controller.scheduled)
                    }
               }


               Rectangle {
                    id: testButton
                    anchors {left: runButton.right; verticalCenter: parent.verticalCenter; margins: 24 }
                    color: controller.running ? "dimgray" : "lightsteelblue"
                    width: 100; height: 64; smooth: true
                    scale: testButtonArea.pressed ? 1.2 : 1
                    Text { anchors.centerIn: parent; color: "black"; font.pixelSize: 22; text: "Test" }
                    MouseArea {
                        id: testButtonArea;
                        anchors.fill: parent;
                        onClicked: controller.running ? controller.stopProcess() : controller.startProcess()
                    }
               }


               Rectangle {
                    id: pauseButton
                    anchors {left: testButton.right; verticalCenter: parent.verticalCenter; margins: 24 }
                    color: controller.paused ? "dimgray" : "lightsteelblue"
                    width: 100; height: 64; smooth: true
                    scale: pauseButtonArea.pressed ? 1.2 : 1
                    Text { anchors.centerIn: parent; color: "black"; font.pixelSize: 22; text: "Pause" }
                    MouseArea {
                        id: pauseButtonArea;
                        anchors.fill: parent;
                        onClicked: controller.paused ? controller.resumeProcess() : controller.pauseProcess()
                    }
               }

               Rectangle {
                    id: skipButton
                    anchors {left: pauseButton.right; verticalCenter: parent.verticalCenter; margins: 24 }
                    color: "lightsteelblue";
                    width: 100; height: 64; smooth: true
                    scale: skipButtonArea.pressed ? 1.2 : 1
                    Text { anchors.centerIn: parent; color: "black"; font.pixelSize: 22; text: "Skip" }
                    MouseArea {
                        id: skipButtonArea;
                        anchors.fill: parent;
                        onClicked: controller.skipRelay()
                    }
               }

               ColumnLayout {
                   anchors {left: skipButton.right; right: parent.right; verticalCenter: parent.verticalCenter; margins: 24 }

                   Rectangle {
                       id: progressBarBorder
                       anchors { left: parent.left; right: parent.right }
                       color: "transparent";
                       height: 26; smooth: true
                       border { width: 2; color: "dimgray" }

                       Rectangle {
                           id: progressBar
                           anchors { left: parent.left; verticalCenter: parent.verticalCenter; margins: 5 }
                           height: 16
                           width: controller.progress * ( parent.width - 10 )
                           color: "lightsteelblue"
                       }

                       Text {
                           id: timeRemaining
                           anchors { left: parent.left; verticalCenter: parent.verticalCenter; margins: 10 }
                           height: 16
                           text: {
                               if ( relayGrid.currentItem != undefined || relayGrid.currentItem != null ){
                                   if ( intervalMultiplier == 1){
                                       ((1 - controller.progress)*relayGrid.currentItem.interval).toFixed(0) + " seconds remaining"
                                   } else if ( intervalMultiplier == 60 ){
                                       ((1 - controller.progress)*relayGrid.currentItem.interval).toFixed(0) + " minutes remaining"
                                   }
                               } else { "" }
                           }
                       }
                   }

                   Rectangle {
                       id: totalProgressBarBorder
                       anchors { left: parent.left; right: parent.right }
                       color: "transparent";
                       height: 26; smooth: true
                       border { width: 2; color: "dimgray" }

                       Rectangle {
                           id: totalProgressBar
                           anchors { left: parent.left; verticalCenter: parent.verticalCenter; margins: 5 }
                           height: 16
                           width: controller.totalProgress * ( parent.width - 10 )
                           color: "lightsteelblue"
                       }

                       Text {
                           id: totalTimeRemaining
                           anchors { left: parent.left; verticalCenter: parent.verticalCenter; margins: 10 }
                           height: 16
                           text: {
                               if ( controller.running ){
                                   ((1 - controller.totalProgress)*controller.totalInterval/60).toFixed(0) + " minutes remaining"
                               } else { "" }
                           }
                       }
                   }
               }
            }

            /* put this last to "steal" touch on the normal window when menu is shown */
            MouseArea {
                anchors.fill: parent
                enabled: menu_view.isOpen
                onClicked: {
                    menu_view.isOpen = false;
                }
            }
        }
    }
}
