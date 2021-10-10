#include "PropertyWatcher.h"
#include <QVariant>
#include <QDebug>
#include "DeviceLookup.h"

PropertyWatcher::PropertyWatcher(QObject *parent) : QObject(parent)
{
   connect(DeviceLookup::instance(), SIGNAL(deviceAdded(QString)), this, SLOT(deviceAddedToLookup(QString)));
   connect(DeviceLookup::instance(), SIGNAL(deviceRemoved(QString)), this, SLOT(deviceRemovedFromLookup(QString)));
}

bool PropertyWatcher::addObject(QString device)
{
    if(_watchedDevices.contains(device) || _awaitedDevices.contains(device))
    {
        qDebug()<<"contains already";
        return false;
    }

    QPointer<QObject> ptr = DeviceLookup::instance()->getObject(device);
    if(!ptr.isNull())
    {
        qDebug()<<"Inserted";
        _watchedDevices.insert(device, ptr);
        Q_EMIT monitoredDeviceIDsChanged();
        connect(ptr.data(), SIGNAL(stateChanged()), this, SLOT(deviceStateChanged()));
    }
    else
    {
        qDebug()<<"Not found";
        _awaitedDevices << device;
    }

    return true;
}

bool PropertyWatcher::remove(QString device)
{
    auto ptr = _watchedDevices.value(device);
    disconnect(ptr, SIGNAL(stateChanged()), this, SLOT(deviceStateChanged()));
    _watchedDevices.remove(device);
    Q_EMIT monitoredDeviceIDsChanged();
    return true;
}

bool PropertyWatcher::isLoggedIn()
{
    return _isLoggedIn;
}

QStringList PropertyWatcher::getMonitoredDeviceIDs()
{
    return _watchedDevices.keys();
}

void PropertyWatcher::deviceStateChanged()
{
    QMapIterator<QString, QPointer<QObject>> it(_watchedDevices);
    while(it.hasNext())
    {
        QPointer<QObject> ptr = it.next().value();
        if(ptr.isNull())
        {
            _watchedDevices.remove(_watchedDevices.key(ptr));
            Q_EMIT monitoredDeviceIDsChanged();
            continue;
        }

        /*!
            -3 -> Maintenance           nobody is logged in!
            -2 -> Error while running   somebody is logged in!
            -1 -> Intercpted            somebody is logged in!
            0 -> Idle                   nobody is logged in!
            1 -> Logged in              somebody is logged in!
            2 -> running                somebody is logged in!
        */

        if(ptr->property("state").toInt() != 0 && ptr->property("state").toInt() > -3)
        {
            _isLoggedIn = true;
            Q_EMIT isLoggedInChanged();
            return;
        }
    }

    _isLoggedIn = false;
    Q_EMIT isLoggedInChanged();
    return;
}

void PropertyWatcher::deviceAddedToLookup(QString device)
{
    if(_awaitedDevices.contains(device))
    {
        auto ptr = DeviceLookup::instance()->getObject(device);
        if(ptr)
        {
            _watchedDevices.insert(device, ptr);
            _awaitedDevices.removeOne(device);
            Q_EMIT monitoredDeviceIDsChanged();
            connect(ptr, SIGNAL(stateChanged()), this, SLOT(deviceStateChanged()));
        }
    }
}

void PropertyWatcher::deviceRemovedFromLookup(QString device)
{
    if(_watchedDevices.contains(device))
    {
        _watchedDevices.remove(device);
        Q_EMIT monitoredDeviceIDsChanged();
    }
}

