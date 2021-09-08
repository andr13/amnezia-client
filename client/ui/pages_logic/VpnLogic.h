#ifndef VPN_LOGIC_H
#define VPN_LOGIC_H

#include "PageLogicBase.h"
#include "protocols/vpnprotocol.h"

class UiLogic;

class VpnLogic : public PageLogicBase
{
    Q_OBJECT

    AUTO_PROPERTY(bool, pushButtonConnectChecked)
    AUTO_PROPERTY(QString, labelSpeedReceivedText)
    AUTO_PROPERTY(QString, labelSpeedSentText)
    AUTO_PROPERTY(QString, labelStateText)
    AUTO_PROPERTY(bool, pushButtonConnectEnabled)
    AUTO_PROPERTY(bool, widgetVpnModeEnabled)
    AUTO_PROPERTY(QString, labelErrorText)
    AUTO_PROPERTY(bool, pushButtonVpnAddSiteEnabled)

    AUTO_PROPERTY(bool, radioButtonVpnModeAllSitesChecked)
    AUTO_PROPERTY(bool, radioButtonVpnModeForwardSitesChecked)
    AUTO_PROPERTY(bool, radioButtonVpnModeExceptSitesChecked)

public:
    Q_INVOKABLE void updateVpnPage();

    Q_INVOKABLE void onRadioButtonVpnModeAllSitesToggled(bool checked);
    Q_INVOKABLE void onRadioButtonVpnModeForwardSitesToggled(bool checked);
    Q_INVOKABLE void onRadioButtonVpnModeExceptSitesToggled(bool checked);

    Q_INVOKABLE void onPushButtonConnectClicked(bool checked);

public:
    explicit VpnLogic(UiLogic *uiLogic, QObject *parent = nullptr);
    ~VpnLogic() = default;

    bool getPushButtonConnectChecked() const;
    void setPushButtonConnectChecked(bool pushButtonConnectChecked);

public slots:
    void onConnect();
    void onConnectWorker(int serverIndex, const ServerCredentials &credentials, DockerContainer container, const QJsonObject &containerConfig);
    void onDisconnect();

    void onBytesChanged(quint64 receivedBytes, quint64 sentBytes);
    void onConnectionStateChanged(VpnProtocol::ConnectionState state);
    void onVpnProtocolError(amnezia::ErrorCode errorCode);

};
#endif // VPN_LOGIC_H