#include "SwitchAspect.h"
#include "DeviceModelAspectProperty.h"
#include "VirtualDeviceAspectProperty.h"

SwitchAspect::SwitchAspect(QObject *parent) : IAspect(parent),
    _switchModel(new DeviceModel(this))
{

}

QList<iAspectPropertyPtr> SwitchAspect::getProperties(QString deviceID)
{
    _switchHandleProp = devicePropertyPtr(new DeviceLogicProperty("switchHook"));
    _switchHandleProp->setDefaultValue(deviceID+"/pow");
    connect(_switchHandleProp.data(), &DeviceLogicProperty::valueRequested, [=](QVariant value)
    {
        qDebug()<<value;
        _switchModel->setResource(value.toString());
        _switchHandleProp->setValue(value);
    });


    QList<iAspectPropertyPtr> props;
    props << iAspectPropertyPtr(new DeviceModelAspectProperty(_switchModel->getProperty("curr")));
    props << iAspectPropertyPtr(new DeviceModelAspectProperty(_switchModel->getProperty("on")));
    props << iAspectPropertyPtr(new VirtualDeviceAspectProperty(_switchHandleProp));
    return props;
}


void SwitchAspect::finish(QMap<QString, iAspectPropertyPtr> properties)
{
    Q_UNUSED(properties)
}
