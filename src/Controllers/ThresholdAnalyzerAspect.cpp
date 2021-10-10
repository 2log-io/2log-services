#include "ThresholdAnalyzerAspect.h"
#include "VirtualDeviceAspectProperty.h"

ThresholdAnalyzerAspect::ThresholdAnalyzerAspect(QObject *parent) : IAspect(parent)
{
    _runningProp = devicePropertyPtr(new DeviceLogicProperty("running", DeviceLogicProperty::READ_ONLY));
    _runningProp->setValue(false);

    _thresholdProp = devicePropertyPtr(new DeviceLogicProperty("activityThreshold"));
    _thresholdProp->setDefaultValue(0.5);


    _activityTimoutTimer.setSingleShot(true);
    _initTimer.setSingleShot(true);

    connect(_thresholdProp.data(), &DeviceLogicProperty::valueRequested, [=](QVariant value)
    {
        _threshold = value.toFloat();
        _thresholdProp->setValue(value);
    });

    _timeoutProp = devicePropertyPtr(new DeviceLogicProperty("activityTimeout"));
    _timeoutProp->setDefaultValue(2000);
    connect(_timeoutProp.data(), &DeviceLogicProperty::valueRequested, [=](QVariant value)
    {
        _activityTimeout = value.toInt();
        _activityTimoutTimer.setInterval(_activityTimeout);
        _timeoutProp->setValue(value);
    });

    _delayProp = devicePropertyPtr(new DeviceLogicProperty("machineInitTime"));
    _delayProp->setDefaultValue(1000);
    connect(_delayProp.data(), &DeviceLogicProperty::valueRequested, [=](QVariant value)
    {
        _machineInitDelay = value.toInt();
        _initTimer.setInterval(_machineInitDelay);
        _delayProp->setValue(value);
    });

    connect(&_activityTimoutTimer, &QTimer::timeout, [=](){_runningProp->setValue(false);_running = false;});
}


QList<iAspectPropertyPtr> ThresholdAnalyzerAspect::getProperties(QString deviceID)
{
  Q_UNUSED(deviceID);
  QList<iAspectPropertyPtr> props;
  props << iAspectPropertyPtr(new VirtualDeviceAspectProperty(_runningProp));
  props << iAspectPropertyPtr(new VirtualDeviceAspectProperty(_timeoutProp));
  props << iAspectPropertyPtr(new VirtualDeviceAspectProperty(_thresholdProp));
  props << iAspectPropertyPtr(new VirtualDeviceAspectProperty(_delayProp));
  return props;
}


void ThresholdAnalyzerAspect::finish(QMap<QString, iAspectPropertyPtr> properties)
{
    iAspectPropertyPtr source = properties.value("curr");
    if(!source.isNull())
        connect(source.data(), &IAspectProperty::valueChanged, this, &ThresholdAnalyzerAspect::sourceValChanged );
    _sourceProp = source;
}

void ThresholdAnalyzerAspect::sourceValChanged()
{
   float val = _sourceProp->getValue().toFloat();
   if(val >= _threshold )
   {
       _activityTimoutTimer.stop();
       if(!_running)
       {
           _runningProp->setValue(true);
           _running = true;
       }
   }
   else
   {
       if(!_activityTimoutTimer.isActive() && _running)
       {
           _activityTimoutTimer.start();
       }
   }
}
