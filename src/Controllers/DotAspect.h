#ifndef DOTASPECT_H
#define DOTASPECT_H

#include <QObject>
#include "IAspect.h"
#include "DeviceModel.h"

class DotAspect : public IAspect
{
    Q_OBJECT

public:
    explicit DotAspect(QObject *parent = nullptr);
    QList<iAspectPropertyPtr>  getProperties(QString deviceID) override;

private:
    DeviceModel*                _dotModel = nullptr;
    devicePropertyPtr          _dotHandleProp;
    iAspectPropertyPtr          _cardReadMessage;

public slots:
    virtual void finish(QMap<QString, iAspectPropertyPtr> properties) override;

signals:

};

#endif // DOTASPECT_H
