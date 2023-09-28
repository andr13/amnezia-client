import QtQuick
import QtQuick.Controls

Rectangle {
    id: root

    property string placeholderText
    property string text
    property alias textArea: textArea
    property alias textAreaText: textArea.text

    height: 148
    color: "#1C1D21"
    border.width: 1
    border.color: "#2C2D30"
    radius: 16

    FlickableType {
        id: fl
        interactive: false

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        contentHeight: textArea.implicitHeight
        TextArea {
            id: textArea

            width: parent.width

            topPadding: 16
            leftPadding: 16
            anchors.topMargin: 16
            anchors.bottomMargin: 16

            color: "#D7D8DB"
            selectionColor:  "#633303"
            selectedTextColor: "#D7D8DB"
            placeholderTextColor: "#878B91"

            font.pixelSize: 16
            font.weight: Font.Medium
            font.family: "PT Root UI VF"

            placeholderText: root.placeholderText
            text: root.text

            onCursorVisibleChanged:  {
                if (textArea.cursorVisible) {
                    fl.interactive = true
                } else {
                    fl.interactive = false
                }
            }

            wrapMode: Text.Wrap

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                onClicked: {
                    fl.interactive = true
                    contextMenu.open()
                }
            }

            ContextMenuType {
                id: contextMenu
                textObj: textArea
            }
        }
    }

    //todo make whole background clickable, with code below we lose ability to select text by mouse
//    MouseArea {
//        anchors.fill: parent
//        cursorShape: Qt.IBeamCursor
//        onClicked: textArea.forceActiveFocus()
//    }
}