#ifndef ASPECTPROPERTY_H
#define ASPECTPROPERTY_H

#include <QObject>
#include <QVariant>

class IAspectProperty : public QObject
{
    Q_OBJECT

public:
    explicit IAspectProperty(QObject *parent = nullptr):QObject(parent){};

    virtual QVariant    getValue() const  = 0;
    virtual QString     getName() const = 0;
    virtual void        setValue(QVariant value) = 0;

signals:
    void valueChanged();


};

typedef QSharedPointer<IAspectProperty> iAspectPropertyPtr;

#endif // ASPECTPROPERTY_H
