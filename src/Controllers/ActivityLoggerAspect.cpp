#include "ActivityLoggerAspect.h"

ActivityLoggerAspect::ActivityLoggerAspect(QObject *parent) : IAspect(parent),
    _service(new ServiceModel(this))
{
    _service.setService("lab");
}

QList<iAspectPropertyPtr> ActivityLoggerAspect::getProperties(QString deviceID)
{
    _deviceID = deviceID;
    return QList<iAspectPropertyPtr>();
}

void ActivityLoggerAspect::finish(QMap<QString, iAspectPropertyPtr> properties)
{
    _trigger = properties.value("running");
    if(_trigger.isNull())
        return;

    connect(_trigger.data(), &IAspectProperty::valueChanged, this, &ActivityLoggerAspect::triggerChanged);
}

void ActivityLoggerAspect::triggerChanged()
{
    if(_trigger->getValue().toBool())
    {
        qDebug()<<"START";
        _start = QDateTime::currentDateTime();
    }
    else
    {
        qDebug()<<"END";
        QVariantMap msg;
        msg["resourceID"] = _deviceID;
        msg["start"] = _start;
        msg["end"] = QDateTime::currentDateTime();
        _service.call("sendJob",msg);
    }
}
