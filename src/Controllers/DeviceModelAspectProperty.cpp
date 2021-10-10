#include "DeviceModelAspectProperty.h"

DeviceModelAspectProperty::DeviceModelAspectProperty(DevicePropertyModel* model, QObject *parent) : IAspectProperty(parent),
    _model(model)
{
    connect(model, &DevicePropertyModel::valueChanged, this, &DeviceModelAspectProperty::valueChanged);
}

QVariant DeviceModelAspectProperty::getValue() const
{
    return _model->getValue();
}

QString DeviceModelAspectProperty::getName() const
{
    return _model->getName();
}

void DeviceModelAspectProperty::setValue(QVariant value)
{
    _model->sendValue(value);
}
