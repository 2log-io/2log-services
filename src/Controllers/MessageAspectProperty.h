#ifndef MESSAGEASPECTPROPERTY_H
#define MESSAGEASPECTPROPERTY_H

#include "IAspectProperty.h"
#include <QObject>

class MessageAspectProperty : public IAspectProperty
{
    Q_OBJECT

public:
    MessageAspectProperty(QString name, QObject* parent = nullptr);
    virtual QVariant    getValue() const override;
    virtual QString     getName() const override;

public slots:
    virtual void        setValue(QVariant value) override;

private:
    QVariant _value;
    QString _name;

signals:
    void valueChanged();
};

#endif // MESSAGEASPECTPROPERTY_H
