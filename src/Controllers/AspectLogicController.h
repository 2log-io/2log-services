#ifndef ILOGICCONTROLLER_H
#define ILOGICCONTROLLER_H

#include <QObject>
#include "IAspectProperty.h"
#include "Models/DeviceLogic.h"
#include "IAspect.h"
#include <QQmlParserStatus>

class AspectLogicController : public QObject, public QQmlParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)
    Q_PROPERTY(QString deviceID READ getDeviceID WRITE setDeviceID NOTIFY deviceIDChanged)
    Q_PROPERTY(QString deviceType READ getDeviceType WRITE setDeviceType NOTIFY deviceTypeChanged)
    Q_PROPERTY(QString displayName READ getDisplayName WRITE setDisplayName NOTIFY displayNameChanged)

public:
    explicit AspectLogicController(QObject* parent = nullptr);
    virtual ~AspectLogicController(){};
    virtual void addProperty(iAspectPropertyPtr prop);
    virtual void addAspect(IAspect* aspect);

    iAspectPropertyPtr getProperty(QString name);

    void setDeviceID(const QString &value);
    QString getDeviceID() const;

    virtual void componentComplete() override;
    virtual void classBegin() override {}

    QString getDeviceType() const;
    void setDeviceType(const QString &deviceType);

    QString getDisplayName() const;
    void setDisplayName(const QString &displayName);

private:
    QMultiMap<QString, iAspectPropertyPtr>   _properties;
    devicePropertyPtr                   _displayNameProp;
    devicePropertyPtr                   _deviceIDProp;
    QList<IAspect*>                     _aspects;
    DeviceLogic*                        _logic = nullptr;
    QString                             _deviceID;
    QString                             _deviceType;
    QString                             _displayName;



signals:
    void deviceIDChanged();
    void deviceTypeChanged();
    void displayNameChanged();
    void finished();

};

#endif // ILOGICCONTROLLER_H
