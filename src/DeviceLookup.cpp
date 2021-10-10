#include "DeviceLookup.h"
#include <QDebug>

Q_GLOBAL_STATIC(DeviceLookup, deviceLookup);
DeviceLookup::DeviceLookup(QObject *parent) : QObject(parent)
{

}

void DeviceLookup::addObject(QObject * object, QString deviceID)
{
    _map.insert(deviceID, object);
    connect(object, &QObject::destroyed, this, &DeviceLookup::objectDestroyed);
    Q_EMIT deviceAdded(deviceID);
}

QObject *DeviceLookup::getObject(QString deviceID)
{
    QPointer<QObject> ptr = _map.value(deviceID);
    if(!ptr.isNull())
        return ptr;

    return nullptr;
}


DeviceLookup* DeviceLookup::instance()
{
    return deviceLookup;
}

void DeviceLookup::objectDestroyed()
{
    QObject* ptr = sender();
    QString deviceID = _map.key(ptr);
    Q_EMIT deviceRemoved(deviceID);
    _map.remove(deviceID);
}
