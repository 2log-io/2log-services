#ifndef DEVICELOOKUP_H
#define DEVICELOOKUP_H

#include <QObject>
#include <QMap>
#include <QPointer>

class DeviceLookup : public QObject
{
    Q_OBJECT


public:
    explicit DeviceLookup(QObject *parent = nullptr);
    Q_INVOKABLE void addObject(QObject* object, QString deviceID);
    Q_INVOKABLE QObject* getObject(QString deviceID);
    static DeviceLookup* instance();

private slots:
    void objectDestroyed();

private:
    QMap<QString, QPointer<QObject>> _map;

signals:
    void deviceAdded(QString deviceID);
    void deviceRemoved(QString deviceID);

public slots:
};

#endif // DEVICELOOKUP_H
