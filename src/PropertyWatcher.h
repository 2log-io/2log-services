#ifndef PROPERTYWATCHER_H
#define PROPERTYWATCHER_H

#include <QObject>
#include <QPointer>
#include <QMap>
class PropertyWatcher : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isLoggedIn READ isLoggedIn NOTIFY isLoggedInChanged)
    Q_PROPERTY(QStringList monitoredDeviceIDs READ getMonitoredDeviceIDs NOTIFY monitoredDeviceIDsChanged)

public:
    explicit PropertyWatcher(QObject *parent = nullptr);
    Q_INVOKABLE bool addObject(QString device);
    Q_INVOKABLE bool remove(QString device);
    bool isLoggedIn();
    QStringList getMonitoredDeviceIDs();

signals:
    void isLoggedInChanged();
    void monitoredDeviceIDsChanged();

private:
    QStringList _awaitedDevices;
    QMap<QString, QPointer<QObject>> _watchedDevices;
    bool _isLoggedIn;

public slots:
    void deviceStateChanged();
    void deviceAddedToLookup(QString device);
    void deviceRemovedFromLookup(QString device);

};

#endif // PROPERTYWATCHER_H
