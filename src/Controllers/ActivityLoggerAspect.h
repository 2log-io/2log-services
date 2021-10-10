#ifndef ACTIVITYLOGGERASPECT_H
#define ACTIVITYLOGGERASPECT_H

#include <QObject>
#include "IAspect.h"
#include "Models/ServiceModel.h"

class ActivityLoggerAspect : public IAspect
{
    Q_OBJECT

public:
    explicit ActivityLoggerAspect(QObject *parent = nullptr);
    QList<iAspectPropertyPtr>  getProperties(QString deviceID) override;

public slots:
    virtual void finish(QMap<QString, iAspectPropertyPtr> properties) override;


private:
    iAspectPropertyPtr _trigger;
    QString _deviceID;
    QDateTime   _start;
    QDateTime   _end;
    ServiceModel _service;

private slots:
    void triggerChanged();


signals:

};

#endif // ACTIVITYLOGGERASPECT_H
