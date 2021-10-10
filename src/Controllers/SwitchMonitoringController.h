#ifndef SWITCHMONITORINGCONTROLLER_H
#define SWITCHMONITORINGCONTROLLER_H

#include <QObject>
#include "Models/DeviceLogic.h"
#include "Models/DeviceLogicProperty.h"
#include "Models/DeviceModel.h"
#include "Models/DevicePropertyModel.h"

#include "AspectLogicController.h"

class SwitchMonitoringController : public AspectLogicController
{
    Q_OBJECT

public:
    explicit SwitchMonitoringController(QObject *parent = nullptr);




};

#endif // SWITCHMONITORINGCONTROLLER_H
