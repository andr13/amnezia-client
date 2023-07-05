#ifndef EXPORTCONTROLLER_H
#define EXPORTCONTROLLER_H

#include <QObject>

#include "configurators/vpn_configurator.h"
#include "ui/models/containers_model.h"
#include "ui/models/servers_model.h"

class ExportController : public QObject
{
    Q_OBJECT
public:
    explicit ExportController(const QSharedPointer<ServersModel> &serversModel,
                              const QSharedPointer<ContainersModel> &containersModel,
                              const std::shared_ptr<Settings> &settings,
                              const std::shared_ptr<VpnConfigurator> &configurator, QObject *parent = nullptr);

    Q_PROPERTY(QList<QString> qrCodes READ getQrCodes NOTIFY exportConfigChanged)
    Q_PROPERTY(int qrCodesCount READ getQrCodesCount NOTIFY exportConfigChanged)
    Q_PROPERTY(QString formattedConfig READ getFormattedConfig NOTIFY exportConfigChanged)

public slots:
    void generateFullAccessConfig();
    void generateConnectionConfig();
    void generateOpenVpnConfig();
    void generateWireGuardConfig();

    QString getFormattedConfig();
    QList<QString> getQrCodes();

    void saveFile();

signals:
    void generateConfig(int type);
    void exportErrorOccurred(QString errorMessage);

    void exportConfigChanged();

private:
    QList<QString> generateQrCodeImageSeries(const QByteArray &data);
    QString svgToBase64(const QString &image);

    int getQrCodesCount();

    void clearPreviousConfig();

    QSharedPointer<ServersModel> m_serversModel;
    QSharedPointer<ContainersModel> m_containersModel;
    std::shared_ptr<Settings> m_settings;
    std::shared_ptr<VpnConfigurator> m_configurator;

    QString m_rawConfig;
    QString m_formattedConfig;
    QList<QString> m_qrCodes;
};

#endif // EXPORTCONTROLLER_H