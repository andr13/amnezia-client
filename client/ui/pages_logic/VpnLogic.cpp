﻿//#include <QApplication>
//#include <QClipboard>
//#include <QDebug>
//#include <QDesktopServices>
//#include <QFileDialog>
//#include <QHBoxLayout>
//#include <QHostInfo>
//#include <QItemSelectionModel>
//#include <QJsonDocument>
//#include <QJsonObject>
//#include <QKeyEvent>
//#include <QMenu>
//#include <QMessageBox>
//#include <QMetaEnum>
//#include <QSysInfo>
//#include <QThread>
//#include <QTimer>
//#include <QRegularExpression>
//#include <QSaveFile>

//#include "configurators/cloak_configurator.h"
//#include "configurators/vpn_configurator.h"
//#include "configurators/openvpn_configurator.h"
//#include "configurators/shadowsocks_configurator.h"
//#include "configurators/ssh_configurator.h"

//#include "core/servercontroller.h"
//#include "core/server_defs.h"
//#include "core/errorstrings.h"

//#include "protocols/protocols_defs.h"
//#include "protocols/shadowsocksvpnprotocol.h"


#include "VpnLogic.h"

#include "core/errorstrings.h"
#include "vpnconnection.h"
#include <functional>
#include "../uilogic.h"


VpnLogic::VpnLogic(UiLogic *logic, QObject *parent):
    PageLogicBase(logic, parent),
    m_pushButtonConnectChecked{false},

    m_radioButtonVpnModeAllSitesChecked{true},
    m_radioButtonVpnModeForwardSitesChecked{false},
    m_radioButtonVpnModeExceptSitesChecked{false},
    m_pushButtonVpnAddSiteEnabled{true},

    m_labelSpeedReceivedText{tr("0 Mbps")},
    m_labelSpeedSentText{tr("0 Mbps")},
    m_labelStateText{},
    m_pushButtonConnectEnabled{false},
    m_widgetVpnModeEnabled{false}
{
    connect(uiLogic()->m_vpnConnection, &VpnConnection::bytesChanged, this, &VpnLogic::onBytesChanged);
    connect(uiLogic()->m_vpnConnection, &VpnConnection::connectionStateChanged, this, &VpnLogic::onConnectionStateChanged);
    connect(uiLogic()->m_vpnConnection, &VpnConnection::vpnProtocolError, this, &VpnLogic::onVpnProtocolError);

    if (m_settings.isAutoConnect() && m_settings.defaultServerIndex() >= 0) {
        QTimer::singleShot(1000, this, [this](){
            set_pushButtonConnectEnabled(false);
            onConnect();
        });
    }
}


void VpnLogic::updateVpnPage()
{
    Settings::RouteMode mode = m_settings.routeMode();
    set_radioButtonVpnModeAllSitesChecked(mode == Settings::VpnAllSites);
    set_radioButtonVpnModeForwardSitesChecked(mode == Settings::VpnOnlyForwardSites);
    set_radioButtonVpnModeExceptSitesChecked(mode == Settings::VpnAllExceptSites);
    set_pushButtonVpnAddSiteEnabled(mode != Settings::VpnAllSites);
}


void VpnLogic::onRadioButtonVpnModeAllSitesToggled(bool checked)
{
    if (checked) {
        m_settings.setRouteMode(Settings::VpnAllSites);
    }
}

void VpnLogic::onRadioButtonVpnModeForwardSitesToggled(bool checked)
{
    if (checked) {
        m_settings.setRouteMode(Settings::VpnOnlyForwardSites);
    }
}

void VpnLogic::onRadioButtonVpnModeExceptSitesToggled(bool checked)
{
    if (checked) {
        m_settings.setRouteMode(Settings::VpnAllExceptSites);
    }
}

void VpnLogic::onBytesChanged(quint64 receivedData, quint64 sentData)
{
    set_labelSpeedReceivedText(VpnConnection::bytesPerSecToText(receivedData));
    set_labelSpeedSentText(VpnConnection::bytesPerSecToText(sentData));
}

void VpnLogic::onConnectionStateChanged(VpnProtocol::ConnectionState state)
{
    qDebug() << "UiLogic::onConnectionStateChanged" << VpnProtocol::textConnectionState(state);

    bool pushButtonConnectEnabled = false;
    bool radioButtonsModeEnabled = false;
    set_labelStateText(VpnProtocol::textConnectionState(state));

    uiLogic()->setTrayState(state);

    switch (state) {
    case VpnProtocol::Disconnected:
        onBytesChanged(0,0);
        set_pushButtonConnectChecked(false);
        pushButtonConnectEnabled = true;
        radioButtonsModeEnabled = true;
        break;
    case VpnProtocol::Preparing:
        pushButtonConnectEnabled = false;
        radioButtonsModeEnabled = false;
        break;
    case VpnProtocol::Connecting:
        pushButtonConnectEnabled = false;
        radioButtonsModeEnabled = false;
        break;
    case VpnProtocol::Connected:
        pushButtonConnectEnabled = true;
        radioButtonsModeEnabled = false;
        break;
    case VpnProtocol::Disconnecting:
        pushButtonConnectEnabled = false;
        radioButtonsModeEnabled = false;
        break;
    case VpnProtocol::Reconnecting:
        pushButtonConnectEnabled = true;
        radioButtonsModeEnabled = false;
        break;
    case VpnProtocol::Error:
        set_pushButtonConnectEnabled(false);
        pushButtonConnectEnabled = true;
        radioButtonsModeEnabled = true;
        break;
    case VpnProtocol::Unknown:
        pushButtonConnectEnabled = true;
        radioButtonsModeEnabled = true;
    }

    set_pushButtonConnectEnabled(pushButtonConnectEnabled);
    set_widgetVpnModeEnabled(radioButtonsModeEnabled);
}

void VpnLogic::onVpnProtocolError(ErrorCode errorCode)
{
    set_labelErrorText(errorString(errorCode));
}

void VpnLogic::onPushButtonConnectClicked(bool checked)
{
    if (checked) {
        onConnect();
    } else {
        onDisconnect();
    }
}

void VpnLogic::onConnect()
{
    int serverIndex = m_settings.defaultServerIndex();
    ServerCredentials credentials = m_settings.serverCredentials(serverIndex);
    DockerContainer container = m_settings.defaultContainer(serverIndex);

    if (m_settings.containers(serverIndex).isEmpty()) {
        set_labelErrorText(tr("VPN Protocols is not installed.\n Please install VPN container at first"));
        set_pushButtonConnectChecked(false);
        return;
    }

    if (container == DockerContainer::None) {
        set_labelErrorText(tr("VPN Protocol not choosen"));
        set_pushButtonConnectChecked(false);
        return;
    }


    const QJsonObject &containerConfig = m_settings.containerConfig(serverIndex, container);
    onConnectWorker(serverIndex, credentials, container, containerConfig);
}

void VpnLogic::onConnectWorker(int serverIndex, const ServerCredentials &credentials, DockerContainer container, const QJsonObject &containerConfig)
{
    set_labelErrorText("");
    set_pushButtonConnectChecked(true);
    qApp->processEvents();

    ErrorCode errorCode = uiLogic()->m_vpnConnection->connectToVpn(
                serverIndex, credentials, container, containerConfig
                );

    if (errorCode) {
        //ui->pushButton_connect->setChecked(false);
        uiLogic()->setDialogConnectErrorText(errorString(errorCode));
        emit uiLogic()->showConnectErrorDialog();
        return;
    }

    set_pushButtonConnectEnabled(false);
}

void VpnLogic::onDisconnect()
{
    set_pushButtonConnectChecked(false);
    uiLogic()->m_vpnConnection->disconnectFromVpn();
}