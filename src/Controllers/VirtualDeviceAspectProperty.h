#ifndef VIRTUALDEVICEASPECTPROPERTY_H
#define VIRTUALDEVICEASPECTPROPERTY_H

#include <QObject>
#include "IAspectProperty.h"
#include "DeviceLogic.h"


class VirtualDeviceAspectProperty : public IAspectProperty
{
    Q_OBJECT

public:
    VirtualDeviceAspectProperty(DeviceLogicProperty* prop, QObject* parent = nullptr);
    VirtualDeviceAspectProperty(devicePropertyPtr prop, QObject* parent = nullptr);
    virtual QVariant    getValue() const  override;
    virtual QString     getName() const override;
    virtual void        setValue(QVariant value) override;
    devicePropertyPtr   getPropertyObject();

private:
    devicePropertyPtr _property;

private slots:
    void valueChangedSlot(QString name, QVariant getValue);

};

#endif // VIRTUALDEVICEASPECTPROPERTY_H
