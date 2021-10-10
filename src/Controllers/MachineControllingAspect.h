#ifndef MACHINECONTROLLINGASPECT_H
#define MACHINECONTROLLINGASPECT_H

#include <QObject>
#include "IAspect.h"

class MachineControllingAspect : public IAspect
{
    Q_OBJECT

public:
    MachineControllingAspect(QObject *parent);
    QList<iAspectPropertyPtr>  getProperties(QString deviceID) override;

public slots:
    virtual void finish(QMap<QString, iAspectPropertyPtr> properties) override;

private:
    devicePropertyPtr _pricePerUnitProp;
    devicePropertyPtr _unitDurationProp;
    devicePropertyPtr _minimumBalance;
    devicePropertyPtr _employeesForFree;
    devicePropertyPtr _payMode;
    devicePropertyPtr _enabled;


};

#endif // MACHINECONTROLLINGASPECT_H
