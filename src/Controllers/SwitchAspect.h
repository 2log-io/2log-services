#ifndef SWITCHASPECT_H
#define SWITCHASPECT_H

#include <QObject>
#include "IAspect.h"
#include "Models/DeviceLogic.h"
#include "Models/DeviceLogicProperty.h"
#include "Models/DeviceModel.h"
#include "Models/DevicePropertyModel.h"


class SwitchAspect : public IAspect
{
    Q_OBJECT

public:
    explicit                    SwitchAspect(QObject* parent = nullptr);
     QList<iAspectPropertyPtr>  getProperties(QString deviceID) override;

private:
     DeviceModel*               _switchModel = nullptr;
     devicePropertyPtr          _switchHandleProp;

public slots:
    virtual void finish(QMap<QString, iAspectPropertyPtr> properties) override;
};

#endif // SWITCHASPECT_H
