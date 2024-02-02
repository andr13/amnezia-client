import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "TextTypes"

Item {
    id: root

    readonly property string drawerExpanded: "expanded"
    readonly property string drawerCollapsed: "collapsed"

    readonly property bool isOpened: drawerContent.state === root.drawerExpanded || (drawerContent.state === root.drawerCollapsed && dragArea.drag.active === true)
    readonly property bool isClosed: drawerContent.state === root.drawerCollapsed && dragArea.drag.active === false

    readonly property bool isExpanded: drawerContent.state === root.drawerExpanded
    readonly property bool isCollapsed: drawerContent.state === root.drawerCollapsed

    property Component collapsedContent
    property Component expandedContent

    property string defaultColor: "#1C1D21"
    property string borderColor: "#2C2D30"

    property var expandedHeight

    signal entered
    signal exited
    signal pressed(bool pressed, bool entered)

    signal aboutToHide
    signal close
    signal open

    Connections {
        target: root

        function onClose() {
            if (isCollapsed) {
                return
            }

            aboutToHide()

            drawerContent.state = root.drawerCollapsed
        }

        function onOpen() {
            if (isExpanded) {
                return
            }

            drawerContent.state = root.drawerExpanded
        }
    }

    /** Set once based on first implicit height change once all children are layed out */
    Component.onCompleted: {
        if (root.isCollapsed && drawerContent.collapsedHeight == 0) {
            drawerContent.collapsedHeight = drawerContent.implicitHeight
        }
    }

    MouseArea {
        id: emptyArea
        anchors.fill: parent
        enabled: root.isExpanded
        onClicked: {
            root.close()
        }
    }

    MouseArea {
        id: dragArea

        anchors.fill: drawerBackground
        cursorShape: root.isCollapsed ? Qt.PointingHandCursor : Qt.ArrowCursor
        hoverEnabled: true

        drag.target: drawerContent
        drag.axis: Drag.YAxis
        drag.maximumY: root.height - drawerContent.collapsedHeight
        drag.minimumY: root.height - root.height * root.expandedHeight

        /** If drag area is released at any point other than min or max y, transition to the other state */
        onReleased: {
            if (root.isCollapsed && drawerContent.y < dragArea.drag.maximumY) {
                root.open()
                return
            }
            if (root.isExpanded && drawerContent.y > dragArea.drag.minimumY) {
                root.close()
                return
            }
        }

        onEntered: {
            root.entered()
        }
        onExited: {
            root.exited()
        }
        onPressedChanged: {
            root.pressed(pressed, entered)
        }

        onClicked: {
            if (root.isCollapsed) {
                root.open()
            }
        }
    }

    Rectangle {
        id: drawerBackground

        anchors { left: drawerContent.left; right: drawerContent.right; top: drawerContent.top }
        height: root.height
        radius: 16
        color: root.defaultColor
        border.color: root.borderColor
        border.width: 1

        Rectangle {
            width: parent.radius
            height: parent.radius
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.left: parent.left
            color: parent.color
        }
    }

    Loader {
        id: drawerContent

        sourceComponent: root.isCollapsed ? root.collapsedContent : root.expandedContent

        /** Initial height of button content */
        property int collapsedHeight: 0

        Drag.active: dragArea.drag.active
        anchors.right: root.right
        anchors.left: root.left
        y: root.height - drawerContent.height
        state: root.drawerCollapsed

        onStateChanged: {
            if (root.isCollapsed) {
                var initialPageNavigationBarColor = PageController.getInitialPageNavigationBarColor()
                if (initialPageNavigationBarColor !== 0xFF1C1D21) {
                    PageController.updateNavigationBarColor(initialPageNavigationBarColor)
                }
                return
            }
            if (root.isExpanded) {
                if (PageController.getInitialPageNavigationBarColor() !== 0xFF1C1D21) {
                    PageController.updateNavigationBarColor(0xFF1C1D21)
                }
                return
            }
        }

        states: [
            State {
                name: root.drawerCollapsed
                PropertyChanges {
                    target: drawerContent
                    y: root.height - collapsedHeight
                }
            },
            State {
                name: root.drawerExpanded
                PropertyChanges {
                    target: drawerContent
                    y: dragArea.drag.minimumY

                }
            }
        ]

        transitions: [
            Transition {
                from: root.drawerCollapsed
                to: root.drawerExpanded
                PropertyAnimation {
                    target: drawerContent
                    properties: "y"
                    duration: 200
                }
            },
            Transition {
                from: root.drawerExpanded
                to: root.drawerCollapsed
                PropertyAnimation {
                    target: drawerContent
                    properties: "y"
                    duration: 200
                }
            }
        ]
    }
}
