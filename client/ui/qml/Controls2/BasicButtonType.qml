import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import "TextTypes"

Button {
    id: root

    property string hoveredColor: "#C1C2C5"
    property string defaultColor: "#D7D8DB"
    property string disabledColor: "#494B50"
    property string pressedColor: "#979799"

    property string textColor: "#0E0E11"

    property string borderColor: "#D7D8DB"
    property string borderFocusedColor: "#45A6FF"
    property int borderWidth: 0
    property int borderFocusedWidth: 1

    property string imageSource

    property bool squareLeftSide: false

    property var clickedFunc

    implicitHeight: 56

    hoverEnabled: true

    background: Rectangle {
        id: background
        anchors.fill: parent
        radius: 16
        color: {
            if (root.enabled) {
                if (root.pressed) {
                    return pressedColor
                }
                return root.hovered ? hoveredColor : defaultColor
            } else {
                return disabledColor
            }
        }
        border.color: root.activeFocus ? root.borderFocusedColor : borderColor
        border.width: root.activeFocus ? root.borderFocusedWidth : borderWidth

        Behavior on color {
            PropertyAnimation { duration: 200 }
        }

        Rectangle {
            visible: root.squareLeftSide

            z: 1

            width: parent.radius
            height: parent.radius
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            color: {
                if (root.enabled) {
                    if (root.pressed) {
                        return pressedColor
                    }
                    return root.hovered ? hoveredColor : defaultColor
                } else {
                    return disabledColor
                }
            }

            Behavior on color {
                PropertyAnimation { duration: 200 }
            }
        }
    }

    MouseArea {
        anchors.fill: background
        enabled: false
        cursorShape: Qt.PointingHandCursor
    }

    contentItem: Item {
        anchors.fill: background

        implicitWidth: content.implicitWidth
        implicitHeight: content.implicitHeight

        RowLayout {
            id: content
            anchors.centerIn: parent

            Image {
                Layout.preferredHeight: 20
                Layout.preferredWidth: 20

                source: root.imageSource
                visible: root.imageSource === "" ? false : true

                layer {
                    enabled: true
                    effect: ColorOverlay {
                        color: textColor
                    }
                }
            }

            ButtonTextType {
                color: textColor
                text: root.text
                visible: root.text === "" ? false : true

                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    Keys.onEnterPressed: {
        if (root.clickedFunc && typeof root.clickedFunc === "function") {
            root.clickedFunc()
        }
    }

    Keys.onReturnPressed: {
        if (root.clickedFunc && typeof root.clickedFunc === "function") {
            root.clickedFunc()
        }
    }

    onClicked: {
        if (root.clickedFunc && typeof root.clickedFunc === "function") {
            root.clickedFunc()
        }
    }
}
