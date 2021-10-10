#ifndef ILOGICCONTROLLERASPECT_H
#define ILOGICCONTROLLERASPECT_H

#include <QObject>
#include "Models/DeviceLogic.h"
#include "IAspectProperty.h"

class IAspect : public QObject
{
    Q_OBJECT

public:
    explicit IAspect(QObject *parent = nullptr) : QObject (parent){};
    virtual QList<iAspectPropertyPtr> getProperties(QString deviceID) = 0;

public slots:
    virtual void finish(QMap<QString, iAspectPropertyPtr> properties) = 0;


signals:

};

#endif // ILOGICCONTROLLERASPECT_H
