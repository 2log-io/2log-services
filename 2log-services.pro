QT += quick websockets
CONFIG += c++11

# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
#DEFINES += QT_DEPRECATED_WARNINGS

INCLUDEPATH += src
DESTDIR = ../bin/services
TARGET = 2log.services
INSTALLS += target


include(src/quickhub-qmlclientmodule/QHClientModule.pri)

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        src/Controllers/AccessControlController.cpp \
        src/Controllers/ActivityLoggerAspect.cpp \
        src/Controllers/AspectLogicController.cpp \
        src/Controllers/DeviceModelAspectProperty.cpp \
        src/Controllers/DotAspect.cpp \
        src/Controllers/MachineControllingAspect.cpp \
        src/Controllers/MessageAspectProperty.cpp \
        src/Controllers/SwitchAspect.cpp \
        src/Controllers/SwitchMonitoringController.cpp \
        src/Controllers/ThresholdAnalyzerAspect.cpp \
        src/Controllers/VirtualDeviceAspectProperty.cpp \
        src/DeviceLookup.cpp \
        src/PropertyWatcher.cpp \
        src/main.cpp

RESOURCES += src/qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    src/Controllers/AccessControlController.h \
    src/Controllers/ActivityLoggerAspect.h \
    src/Controllers/AspectLogicController.h \
    src/Controllers/DeviceModelAspectProperty.h \
    src/Controllers/DotAspect.h \
    src/Controllers/IAspect.h \
    src/Controllers/IAspectProperty.h \
    src/Controllers/MachineControllingAspect.h \
    src/Controllers/MessageAspectProperty.h \
    src/Controllers/SwitchAspect.h \
    src/Controllers/SwitchMonitoringController.h \
    src/Controllers/ThresholdAnalyzerAspect.h \
    src/Controllers/VirtualDeviceAspectProperty.h \
    src/DeviceLookup.h \
    src/PropertyWatcher.h
