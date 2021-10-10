#include "MessageAspectProperty.h"

MessageAspectProperty::MessageAspectProperty(QString name, QObject *parent) : IAspectProperty(parent),
_name(name)
{

}

QVariant MessageAspectProperty::getValue() const
{
    return _value;
}

QString MessageAspectProperty::getName() const
{
    return _name;
}

void MessageAspectProperty::setValue(QVariant value)
{
    _value = value;
    Q_EMIT valueChanged();
}
