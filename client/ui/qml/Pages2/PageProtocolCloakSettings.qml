import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import SortFilterProxyModel 0.2

import "./"
import "../Controls2"
import "../Controls2/TextTypes"
import "../Config"
import "../Components"

PageType {
    id: root

    Connections {
        target: InstallController

        function onUpdateContainerFinished() {
            PageController.showNotificationMessage(qsTr("Settings updated successfully"))
        }
    }

    ColumnLayout {
        id: backButton

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        anchors.topMargin: 20

        BackButtonType {
        }
    }

    FlickableType {
        id: fl
        anchors.top: backButton.bottom
        anchors.bottom: parent.bottom
        contentHeight: content.implicitHeight

        Column {
            id: content

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            enabled: ServersModel.isCurrentlyProcessedServerHasWriteAccess()

            ListView {
                id: listview

                width: parent.width
                height: listview.contentItem.height

                clip: true
                interactive: false

                model: CloakConfigModel

                delegate: Item {
                    implicitWidth: listview.width
                    implicitHeight: col.implicitHeight

                    ColumnLayout {
                        id: col

                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right

                        anchors.leftMargin: 16
                        anchors.rightMargin: 16

                        spacing: 0

                        HeaderType {
                            Layout.fillWidth: true

                            headerText: qsTr("Cloak settings")
                        }

                        TextFieldWithHeaderType {
                            Layout.fillWidth: true
                            Layout.topMargin: 32

                            headerText: qsTr("Disguised as traffic from")
                            textFieldText: site

                            textField.onEditingFinished: {
                                if (textFieldText !== site) {
                                    site = textFieldText
                                }
                            }
                        }

                        TextFieldWithHeaderType {
                            Layout.fillWidth: true
                            Layout.topMargin: 16

                            headerText: qsTr("Port")
                            textFieldText: port
                            textField.maximumLength: 5

                            textField.onEditingFinished: {
                                if (textFieldText !== port) {
                                    port = textFieldText
                                }
                            }
                        }

                        DropDownType {
                            id: cipherDropDown
                            Layout.fillWidth: true
                            Layout.topMargin: 16

                            descriptionText: qsTr("Cipher")
                            headerText: qsTr("Cipher")

                            listView: ListViewWithRadioButtonType {
                                id: cipherListView

                                rootWidth: root.width

                                model: ListModel {
                                    ListElement { name : "chacha20-ietf-poly1305" }
                                    ListElement { name : "xchacha20-ietf-poly1305" }
                                    ListElement { name : "aes-256-gcm" }
                                    ListElement { name : "aes-192-gcm" }
                                    ListElement { name : "aes-128-gcm" }
                                }

                                clickedFunction: function() {
                                    cipherDropDown.text = selectedText
                                    cipher = cipherDropDown.text
                                    cipherDropDown.menuVisible = false
                                }

                                Component.onCompleted: {
                                    cipherDropDown.text = cipher

                                    for (var i = 0; i < cipherListView.model.count; i++) {
                                        if (cipherListView.model.get(i).name === cipherDropDown.text) {
                                            currentIndex = i
                                        }
                                    }
                                }
                            }
                        }

                        BasicButtonType {
                            Layout.fillWidth: true
                            Layout.topMargin: 24
                            Layout.bottomMargin: 24

                            text: qsTr("Save and Restart Amnezia")

                            onClicked: {
                                forceActiveFocus()
                                PageController.showBusyIndicator(true)
                                InstallController.updateContainer(CloakConfigModel.getConfig())
                                PageController.showBusyIndicator(false)
                            }
                        }
                    }
                }
            }
        }
    }
}