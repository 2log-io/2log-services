#ifndef ACCESSCONTROLCONTROLLER_H
#define ACCESSCONTROLCONTROLLER_H

#include <QObject>

class AccessControlController : public QObject
{
    Q_OBJECT
public:
    explicit AccessControlController(QObject *parent = nullptr);

signals:

};

#endif // ACCESSCONTROLCONTROLLER_H
