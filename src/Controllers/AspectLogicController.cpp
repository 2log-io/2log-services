#include "AspectLogicController.h"
#include "VirtualDeviceAspectProperty.h"

AspectLogicController::AspectLogicController(QObject *parent) : QObject(parent),
    _logic(new DeviceLogic(this))
{

    _displayNameProp = devicePropertyPtr(new DeviceLogicProperty("displayName"));
    connect(_displayNameProp.data(), &DeviceLogicProperty::valueRequested, [=](QVariant value)
    {
        _displayNameProp->setValue(value);
    });

    _deviceIDProp = devicePropertyPtr(new DeviceLogicProperty("deviceID",DeviceLogicProperty::READ_ONLY));
    addProperty(iAspectPropertyPtr(new VirtualDeviceAspectProperty(_deviceIDProp)));
    addProperty(iAspectPropertyPtr(new VirtualDeviceAspectProperty(_displayNameProp)));
}


void AspectLogicController::addProperty(iAspectPropertyPtr prop)
{
    QSharedPointer<VirtualDeviceAspectProperty> ptr = qSharedPointerDynamicCast<VirtualDeviceAspectProperty>(prop);
    if(!ptr.isNull())
        _logic->registerProperty(ptr->getPropertyObject());

    _properties.insert(prop->getName(), prop);
}

void AspectLogicController::addAspect(IAspect *aspect)
{
    _aspects << aspect;
}

iAspectPropertyPtr AspectLogicController::getProperty(QString name)
{
  return _properties.value(name);
}

void AspectLogicController::setDeviceID(const QString &value)
{
    _deviceID = value;
    _deviceIDProp->setValue(value);
    Q_EMIT deviceIDChanged();
}


QString AspectLogicController::getDeviceID() const
{
    return _deviceID;
}


void AspectLogicController::componentComplete()
{
    _logic->setType(_deviceType);
    _logic->setUuid(_deviceID);
    QListIterator<IAspect*> aspectIt(_aspects);
    while(aspectIt.hasNext())
    {
        IAspect* aspect = aspectIt.next();
        auto tempProperties = aspect->getProperties(_deviceID);
        QListIterator<iAspectPropertyPtr> aspectPropIt(tempProperties);
        while (aspectPropIt.hasNext())
        {
            addProperty(aspectPropIt.next());
        }
    }

    aspectIt.toFront();

    while(aspectIt.hasNext())
    {
        IAspect* aspect = aspectIt.next();
        aspect->finish(_properties);
    }


    _logic->start();
}

QString AspectLogicController::getDeviceType() const
{
    return _deviceType;
}

void AspectLogicController::setDeviceType(const QString &deviceType)
{
    _deviceType = deviceType;
}

QString AspectLogicController::getDisplayName() const
{
    return _displayName;
}

void AspectLogicController::setDisplayName(const QString &displayName)
{
    _displayName = displayName;
    _displayNameProp->setValue(displayName);
    Q_EMIT displayNameChanged();
}
