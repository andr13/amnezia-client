import QtQuick
import QtQuick.Layouts

import "TextTypes"

Item {
    id: root

    property string backButtonImage
    property string actionButtonImage

    property var backButtonFunction
    property var actionButtonFunction

    property string headerText
    property string descriptionText

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    ColumnLayout {
        id: content
        anchors.fill: parent

        ImageButtonType {
            id: backButton

            Layout.leftMargin: -6

            image: root.backButtonImage
            imageColor: "#D7D8DB"

            visible: image ? true : false

            onClicked: {
                if (backButtonFunction && typeof backButtonFunction === "function") {
                    backButtonFunction()
                } else {
                    PageController.closePage()
                }
            }
        }

        RowLayout {
            Header2TextType {
                id: header

                Layout.fillWidth: true

                text: root.headerText
            }

            ImageButtonType {
                id: headerActionButton

                image: root.actionButtonImage
                imageColor: "#D7D8DB"

                visible: image ? true : false

                onClicked: {
                    if (actionButtonFunction && typeof actionButtonFunction === "function") {
                        actionButtonFunction()
                    }
                }
            }
        }

        ParagraphTextType {
            id: description

            Layout.topMargin: 16
            Layout.fillWidth: true

            text: root.descriptionText

            color: "#878B91"

            visible: root.descriptionText !== ""
        }
    }
}