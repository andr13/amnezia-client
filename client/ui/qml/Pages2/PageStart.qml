import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes

import PageEnum 1.0

import "./"
import "../Controls2"
import "../Controls2/TextTypes"
import "../Config"
import "../Components"

PageType {
    id: root

    Connections {
        target: PageController

        function onGoToPageHome() {
            tabBar.setCurrentIndex(0)
            tabBarStackView.goToTabBarPage(PageEnum.PageHome)

            PageController.updateDrawerRootPage(PageEnum.PageHome)
        }

        function onGoToPageSettings() {
            tabBar.setCurrentIndex(2)
            tabBarStackView.goToTabBarPage(PageEnum.PageSettings)

            PageController.updateDrawerRootPage(PageEnum.PageSettings)
        }

        function onGoToPageViewConfig() {
            var pagePath = PageController.getPagePath(PageEnum.PageSetupWizardViewConfig)
            tabBarStackView.push(pagePath, { "objectName" : pagePath }, StackView.PushTransition)

            PageController.updateDrawerRootPage(PageEnum.PageSetupWizardViewConfig)
        }

        function onShowBusyIndicator(visible) {
            busyIndicator.visible = visible
            tabBarStackView.enabled = !visible
            tabBar.enabled = !visible
        }

//        function onShowTopCloseButton(visible) {
//            topCloseButton.visible = visible
//        }

        function onEnableTabBar(enabled) {
            tabBar.enabled = enabled
        }

        function onClosePage() {
            if (tabBarStackView.depth <= 1) {
                return
            }
            tabBarStackView.pop()
        }

        function onGoToPage(page, slide) {
            var pagePath = PageController.getPagePath(page)
            if (slide) {
                tabBarStackView.push(pagePath, { "objectName" : pagePath }, StackView.PushTransition)
            } else {
                tabBarStackView.push(pagePath, { "objectName" : pagePath }, StackView.Immediate)
            }

            PageController.updateDrawerRootPage(page)
        }

        function onGoToStartPage() {
            connectionTypeSelection.close()
            while (tabBarStackView.depth > 1) {
                tabBarStackView.pop()
            }
        }

        function onEscapePressed() {
            var pageName = tabBarStackView.currentItem.objectName
            if ((pageName === PageController.getPagePath(PageEnum.PageShare)) ||
                    (pageName === PageController.getPagePath(PageEnum.PageSettings))) {
                PageController.goToPageHome()
                tabBar.previousIndex = 0
            } else {
                PageController.closePage()
            }
        }
    }

    Connections {
        target: InstallController

        function onInstallationErrorOccurred(errorMessage) {
            PageController.showBusyIndicator(false)
            PageController.showErrorMessage(errorMessage)

            var needCloseCurrentPage = false
            var currentPageName = tabBarStackView.currentItem.objectName

            if (currentPageName === PageController.getPagePath(PageEnum.PageSetupWizardInstalling)) {
                needCloseCurrentPage = true
            } else if (currentPageName === PageController.getPagePath(PageEnum.PageDeinstalling)) {
                needCloseCurrentPage = true
            }
            if (needCloseCurrentPage) {
                PageController.closePage()
            }
        }

        function onUpdateContainerFinished(message) {
            PageController.showNotificationMessage(message)
            PageController.closePage()
        }
    }

    Connections {
        target: ConnectionController

        function onReconnectWithUpdatedContainer(message) {
            PageController.showNotificationMessage(message)
            PageController.closePage()
        }
    }

    StackViewType {
        id: tabBarStackView

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: tabBar.top

        width: parent.width
        height: root.height - tabBar.implicitHeight

        function goToTabBarPage(page) {
            connectionTypeSelection.close()

            var pagePath = PageController.getPagePath(page)
            tabBarStackView.clear(StackView.Immediate)
            tabBarStackView.replace(pagePath, { "objectName" : pagePath }, StackView.Immediate)

            PageController.updateDrawerRootPage(page)
        }

        Component.onCompleted: {
            var pagePath = PageController.getPagePath(PageEnum.PageHome)
            ServersModel.currentlyProcessedIndex = ServersModel.defaultIndex
            tabBarStackView.push(pagePath, { "objectName" : pagePath })
        }

//        onWidthChanged: {
//            topCloseButton.x = tabBarStackView.x + tabBarStackView.width -
//                    topCloseButton.buttonWidth - topCloseButton.rightPadding
//        }
    }

    TabBar {
        id: tabBar

        property int previousIndex: 0

        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        topPadding: 8
        bottomPadding: 8
        leftPadding: 96
        rightPadding: 96

        background: Shape {
            width: parent.width
            height: parent.height

            ShapePath {
                startX: 0
                startY: 0

                PathLine { x: width; y: 0 }
                PathLine { x: width; y: height - 1 }
                PathLine { x: 0; y: height - 1 }
                PathLine { x: 0; y: 0 }

                strokeWidth: 1
                strokeColor: "#2C2D30"
                fillColor: "#1C1D21"
            }
        }

        TabImageButtonType {
            isSelected: tabBar.currentIndex === 0
            image: "qrc:/images/controls/home.svg"
            onClicked: {
                tabBarStackView.goToTabBarPage(PageEnum.PageHome)
                ServersModel.currentlyProcessedIndex = ServersModel.defaultIndex
                tabBar.previousIndex = 0
            }
        }

        TabImageButtonType {
            id: shareTabButton

            Connections {
                target: ServersModel

                function onModelReset() {
                    var hasServerWithWriteAccess = ServersModel.hasServerWithWriteAccess()
                    shareTabButton.visible = hasServerWithWriteAccess
                    shareTabButton.width = hasServerWithWriteAccess ? undefined : 0
                }
            }

            visible: ServersModel.hasServerWithWriteAccess()
            width: ServersModel.hasServerWithWriteAccess() ? undefined : 0

            isSelected: tabBar.currentIndex === 1
            image: "qrc:/images/controls/share-2.svg"
            onClicked: {
                tabBarStackView.goToTabBarPage(PageEnum.PageShare)
                tabBar.previousIndex = 1
            }
        }

        TabImageButtonType {
            isSelected: tabBar.currentIndex === 2
            image: "qrc:/images/controls/settings-2.svg"
            onClicked: {
                tabBarStackView.goToTabBarPage(PageEnum.PageSettings)
                tabBar.previousIndex = 2
            }
        }

        TabImageButtonType {
            isSelected: tabBar.currentIndex === 3
            image: "qrc:/images/controls/plus.svg"
            onClicked: {
                connectionTypeSelection.open()
            }
        }
    }

    BusyIndicatorType {
        id: busyIndicator
        anchors.centerIn: parent
        z: 1
    }

//    TopCloseButtonType {
//        id: topCloseButton

//        x: tabBarStackView.width - topCloseButton.buttonWidth - topCloseButton.rightPadding
//        z: 1
//    }

    ConnectionTypeSelectionDrawer {
        id: connectionTypeSelection

        onAboutToHide: {
            tabBar.setCurrentIndex(tabBar.previousIndex)
        }
    }
}
