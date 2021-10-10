#include "SwitchMonitoringController.h"
#include <QVariant>
#include "SwitchAspect.h"
#include "ThresholdAnalyzerAspect.h"
#include "ActivityLoggerAspect.h"

SwitchMonitoringController::SwitchMonitoringController(QObject *parent) : AspectLogicController(parent)
{
    addAspect(new SwitchAspect(this));
    addAspect(new ThresholdAnalyzerAspect(this));
    addAspect(new ActivityLoggerAspect(this));
}

