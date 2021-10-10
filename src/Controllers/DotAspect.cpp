#include "DotAspect.h"
#include "DeviceModelAspectProperty.h"
#include "VirtualDeviceAspectProperty.h"
#include "MessageAspectProperty.h"

DotAspect::DotAspect(QObject *parent) : IAspect(parent),
    _dotModel(new DeviceModel(this))
{

}


QList<iAspectPropertyPtr> DotAspect::getProperties(QString deviceID)
{
    _dotHandleProp = devicePropertyPtr(new DeviceLogicProperty("dotHook"));
    _dotHandleProp->setDefaultValue(deviceID+"/dot");
    connect(_dotHandleProp.data(), &DeviceLogicProperty::valueRequested, this, [=](QVariant value)
    {
        qDebug()<<value;
        _dotModel->setResource(value.toString());
        _dotHandleProp->setValue(value);
    });

    _cardReadMessage.reset(new MessageAspectProperty("cardRead"));
    connect(_dotModel, &DeviceModel::dataReceived, [=](QString subject, QVariantMap data)
    {
        Q_UNUSED(subject)
        _cardReadMessage->setValue(subject);
    });

    QList<iAspectPropertyPtr> props;
    props << iAspectPropertyPtr(new DeviceModelAspectProperty(_dotModel->getProperty("state")));
    props << iAspectPropertyPtr(new VirtualDeviceAspectProperty(_dotHandleProp));
    props << _cardReadMessage;
    return props;
}

void DotAspect::finish(QMap<QString, iAspectPropertyPtr> properties)
{

}
