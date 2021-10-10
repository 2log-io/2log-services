#ifndef CURRENTTHRESHOLDANALYZERASPECT_H
#define CURRENTTHRESHOLDANALYZERASPECT_H

#include <QObject>
#include "IAspect.h"


#include "Models/DeviceLogic.h"
#include "Models/DeviceLogicProperty.h"
#include "Models/DeviceModel.h"
#include "Models/DevicePropertyModel.h"

class ThresholdAnalyzerAspect : public IAspect
{
    Q_OBJECT

public:
    explicit ThresholdAnalyzerAspect(QObject *parent = nullptr);
    QList<iAspectPropertyPtr>  getProperties(QString deviceID) override;


public slots:
    virtual void finish(QMap<QString, iAspectPropertyPtr> properties) override;
    void sourceValChanged();

private:
    devicePropertyPtr _thresholdProp;
    devicePropertyPtr _timeoutProp;
    devicePropertyPtr _delayProp;
    devicePropertyPtr _runningProp;

    iAspectPropertyPtr _sourceProp;

    float _threshold;
    int _machineInitDelay;
    int _activityTimeout;
    bool _running = false;

    QTimer _activityTimoutTimer;
    QTimer _initTimer;


};

#endif // CURRENTTHRESHOLDANALYZERASPECT_H
