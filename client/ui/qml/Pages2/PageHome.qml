import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import SortFilterProxyModel 0.2

import PageEnum 1.0
import ProtocolEnum 1.0
import ContainerProps 1.0

import "./"
import "../Controls2"
import "../Controls2/TextTypes"
import "../Config"
import "../Components"

Item {
    id: root

    property string defaultColor: "#1C1D21"

    property string borderColor: "#2C2D30"

    property string currentServerName: serversMenuContent.currentItem.delegateData.name
    property string currentServerHostName: serversMenuContent.currentItem.delegateData.hostName
    property string currentContainerName

    ConnectButton {
        anchors.centerIn: parent
    }

    Connections {
        target: ContainersModel

        function onDefaultContainerChanged() {
            root.currentContainerName = ContainersModel.getDefaultContainerName()
        }
    }

    Rectangle {
        id: buttonBackground
        anchors.fill: buttonContent
        anchors.bottomMargin: -radius

        radius: 16
        color: root.defaultColor
        border.color: root.borderColor
        border.width: 1

        Rectangle {
            width: parent.width
            height: 1
            y: parent.height - height - parent.radius

            color: root.borderColor
        }
    }

    ColumnLayout {
        id: buttonContent
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        RowLayout {
            Layout.topMargin: 24
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            Header1TextType {
                text: root.currentServerName
            }

            Image {
                Layout.preferredWidth: 18
                Layout.preferredHeight: 18

                source: "qrc:/images/controls/chevron-down.svg"
            }
        }

        LabelTextType {
            Layout.bottomMargin: 44
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            text: root.currentContainerName + " | " + root.currentServerHostName
        }
    }

    MouseArea {
        anchors.fill: buttonBackground
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true

        onClicked: {
            menu.visible = true
        }
    }

    Drawer {
        id: menu

        edge: Qt.BottomEdge
        width: parent.width
        height: parent.height * 0.90

        clip: true
        modal: true

        background: Rectangle {
            anchors.fill: parent
            anchors.bottomMargin: -radius
            radius: 16

            color: "#1C1D21"
            border.color: root.borderColor
            border.width: 1
        }

        Overlay.modal: Rectangle {
            color: Qt.rgba(14/255, 14/255, 17/255, 0.8)
        }

        ColumnLayout {
            id: serversMenuHeader
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.left: parent.left

            Header1TextType {
                Layout.topMargin: 24
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                text: root.currentServerName
            }

            LabelTextType {
                Layout.bottomMargin: 24
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                text: root.currentServerHostName
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                spacing: 8

                SortFilterProxyModel {
                    id: proxyContainersModel
                    sourceModel: ContainersModel
                    filters: [
                        ValueFilter {
                            roleName: "serviceType"
                            value: ProtocolEnum.Vpn
                        }
                    ]
                }

                DropDownType {
                    id: containersDropDown

                    implicitHeight: 40

                    rootButtonBorderWidth: 0
                    rootButtonImageColor: "#0E0E11"
                    rootButtonMaximumWidth: 150 //todo make it dynamic
                    rootButtonDefaultColor: "#D7D8DB"

                    text: root.currentContainerName
                    textColor: "#0E0E11"
                    headerText: "Протокол подключения"
                    headerBackButtonImage: "qrc:/images/controls/arrow-left.svg"

                    onRootButtonClicked: function() {
                        ServersModel.setCurrentlyProcessedServerIndex(serversMenuContent.currentIndex)
                        ContainersModel.setCurrentlyProcessedServerIndex(serversMenuContent.currentIndex)
                        containersDropDown.menuVisible = true
                    }

                    listView: ContainersPageHomeListView {
                        rootWidth: root.width

                        model: proxyContainersModel
                        currentIndex: ContainersModel.getDefaultContainer()
                    }
                }

                BasicButtonType {
                    id: dnsButton

                    implicitHeight: 40

                    text: "Amnezia DNS"
                }
            }

            Header2Type {
                Layout.fillWidth: true
                Layout.topMargin: 48
                Layout.leftMargin: 16
                Layout.rightMargin: 16

                actionButtonImage: "qrc:/images/controls/plus.svg"

                headerText: "Серверы"

                actionButtonFunction: function() {
                    menu.visible = false
                    connectionTypeSelection.visible = true
                }
            }

            ConnectionTypeSelectionDrawer {
                id: connectionTypeSelection
            }
        }

        FlickableType {
            anchors.top: serversMenuHeader.bottom
            anchors.topMargin: 16
            contentHeight: col.implicitHeight

            Column {
                id: col
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right

                spacing: 16

                ButtonGroup {
                    id: serversRadioButtonGroup
                }

                ListView {
                    id: serversMenuContent
                    width: parent.width
                    height: serversMenuContent.contentItem.height

                    model: ServersModel
                    currentIndex: ServersModel.getDefaultServerIndex()

                    clip: true

                    delegate: Item {
                        id: menuContentDelegate

                        property variant delegateData: model

                        implicitWidth: serversMenuContent.width
                        implicitHeight: serverRadioButton.implicitHeight

                        RadioButton {
                            id: serverRadioButton

                            implicitWidth: parent.width
                            implicitHeight: serverRadioButtonContent.implicitHeight

                            hoverEnabled: true

                            checked: index === serversMenuContent.currentIndex

                            ButtonGroup.group: serversRadioButtonGroup

                            indicator: Rectangle {
                                anchors.fill: parent
                                color: serverRadioButton.hovered ? "#2C2D30" : "#1C1D21"

                                Behavior on color {
                                    PropertyAnimation { duration: 200 }
                                }
                            }

                            RowLayout {
                                id: serverRadioButtonContent
                                anchors.fill: parent

                                anchors.rightMargin: 16
                                anchors.leftMargin: 16

                                z: 1

                                Text {
                                    id: serverRadioButtonText

                                    text: name
                                    color: "#D7D8DB"
                                    font.pixelSize: 16
                                    font.weight: 400
                                    font.family: "PT Root UI VF"

                                    height: 24

                                    Layout.fillWidth: true
                                    Layout.topMargin: 20
                                    Layout.bottomMargin: 20
                                }

                                Image {
                                    source: "qrc:/images/controls/check.svg"
                                    visible: serverRadioButton.checked
                                    width: 24
                                    height: 24

                                    Layout.rightMargin: 8
                                }
                            }

                            onClicked: {
                                serversMenuContent.currentIndex = index

                                ServersModel.setDefaultServerIndex(index)
                                ContainersModel.setCurrentlyProcessedServerIndex(index)
                            }

                            MouseArea {
                                anchors.fill: serverRadioButton
                                cursorShape: Qt.PointingHandCursor
                                enabled: false
                            }
                        }
                    }
                }
            }
        }
    }
}