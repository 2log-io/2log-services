#include "VirtualDeviceAspectProperty.h"

VirtualDeviceAspectProperty::VirtualDeviceAspectProperty(DeviceLogicProperty *prop, QObject *parent): IAspectProperty(parent),
_property(devicePropertyPtr(prop))
{
    connect(_property.data(), &DeviceLogicProperty::valueChanged, this, &VirtualDeviceAspectProperty::valueChanged);
}

VirtualDeviceAspectProperty::VirtualDeviceAspectProperty(devicePropertyPtr prop, QObject* parent) : IAspectProperty(parent),
    _property(prop)
{
    connect(_property.data(), &DeviceLogicProperty::valueChanged, this, &VirtualDeviceAspectProperty::valueChanged);
}

QVariant VirtualDeviceAspectProperty::getValue() const
{
    return _property->getValue();
}

QString VirtualDeviceAspectProperty::getName() const
{
    return _property->getName();
}

void VirtualDeviceAspectProperty::setValue(QVariant value)
{
    _property->setValue(value);
}

devicePropertyPtr VirtualDeviceAspectProperty::getPropertyObject()
{
    return _property;
}

void VirtualDeviceAspectProperty::valueChangedSlot(QString name, QVariant getValue)
{
}
