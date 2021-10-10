#include "MachineControllingAspect.h"

MachineControllingAspect::MachineControllingAspect(QObject* parent) : IAspect(parent)
{

    _pricePerUnitProp = devicePropertyPtr(new DeviceLogicProperty("pricePerUnit"));
    _pricePerUnitProp->setDefaultValue(0);

    _unitDurationProp = devicePropertyPtr(new DeviceLogicProperty("unitDuration"));
    _unitDurationProp->setDefaultValue(60000);
}

QList<iAspectPropertyPtr> MachineControllingAspect::getProperties(QString deviceID)
{

}

void MachineControllingAspect::finish(QMap<QString, iAspectPropertyPtr> properties)
{

}
