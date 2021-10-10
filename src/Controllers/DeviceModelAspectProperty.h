#ifndef DEVICEMODELASPECTPROPERTY_H
#define DEVICEMODELASPECTPROPERTY_H

#include <QObject>
#include "Models/DevicePropertyModel.h"
#include "IAspectProperty.h"

class DeviceModelAspectProperty : public IAspectProperty
{
    Q_OBJECT


public:
     DeviceModelAspectProperty(DevicePropertyModel* model, QObject *parent = nullptr);
    virtual QVariant    getValue() const override;
    virtual QString     getName() const override;
    virtual void        setValue(QVariant value) override;


private:
    DevicePropertyModel* _model;


signals:

};

#endif // DEVICEMODELASPECTPROPERTY_H
