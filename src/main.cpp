#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QDebug>
#include <QQuickView>
#include <QFile>
#include <QProcessEnvironment>
#include <QSettings>
#include <initializer_list>
#include <signal.h>
#include <unistd.h>
#include <QQmlContext>
#include "PropertyWatcher.h"
#include "DeviceLookup.h"
#include "InitQuickHub.h"
#include "Controllers/SwitchMonitoringController.h"
#include <QCommandLineParser>

void catchUnixSignals(std::initializer_list<int> quitSignals) {
    auto handler = [](int sig) -> void {
        // blocking and not aysnc-signal-safe func are valid
        printf("\nquit the application by signal(%d).\n", sig);
        QCoreApplication::quit();
    };

    sigset_t blocking_mask;
    sigemptyset(&blocking_mask);
    for (auto sig : quitSignals)
        sigaddset(&blocking_mask, sig);

    struct sigaction sa;
    sa.sa_handler = handler;
    sa.sa_mask    = blocking_mask;
    sa.sa_flags   = 0;

    for (auto sig : quitSignals)
        sigaction(sig, &sa, nullptr);
}

int main(int argc, char *argv[])
{

#define HEADLESS
#ifdef HEADLESS
    QCoreApplication app(argc, argv);
    catchUnixSignals({SIGQUIT, SIGINT, SIGTERM, SIGHUP});
    QString appname = QProcessEnvironment::systemEnvironment().value("APPNAME", "MachineControl");
    QString orgname = QProcessEnvironment::systemEnvironment().value("ORGNAME", "QuickHub");
    QString user = QProcessEnvironment::systemEnvironment().value("QH_SERVICE_USER", "admin");
    QString password = QProcessEnvironment::systemEnvironment().value("QH_SERVICE_PASSWORD", "password");
    QString url = QProcessEnvironment::systemEnvironment().value("QH_URL", "ws://localhost:4711");
    QString datadir = QProcessEnvironment::systemEnvironment().value("QUICKLAB_DATA_DIR", "");
    QString entrypoint = QProcessEnvironment::systemEnvironment().value("MAIN_QML", "");

    app.setOrganizationName(orgname);
    app.setApplicationName(appname);

    QCommandLineParser parser;
    parser.addHelpOption();
    QCommandLineOption userOpt({"u","user"}, "Sets the username for the service login", "user", user);
    QCommandLineOption passOpt({"p","password"}, "Sets the password for the service login", "password", password);
    parser.addOption(userOpt);
    parser.addOption(passOpt);
    parser.process(app);

    user = parser.value("user");
    password = parser.value("password");

    if(!datadir.isEmpty())
    {
        QSettings::setPath(QSettings::NativeFormat, QSettings::UserScope, datadir+"/user");
        QSettings::setPath(QSettings::NativeFormat, QSettings::SystemScope, datadir+"/system");
    }

    qmlRegisterType<PropertyWatcher>("AddOns", 1, 0, "PropertyWatcher");
    qmlRegisterType<SwitchMonitoringController>("LogicController", 1, 0, "SwitchMonitoringController");

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("qh_url", url);
    engine.rootContext()->setContextProperty("qh_user", user);
    engine.rootContext()->setContextProperty("qh_password", password);
    engine.rootContext()->setContextProperty("deviceLookup", DeviceLookup::instance());

    InitQuickHub::registerTypes("QuickHub");

    if(!entrypoint.isEmpty())
        engine.load(QUrl(entrypoint));
    else
        engine.load("qrc:/main.qml");



#else
    QGuiApplication app(argc, argv);
    catchUnixSignals({SIGQUIT, SIGINT, SIGTERM, SIGHUP});

    QString appname = QProcessEnvironment::systemEnvironment().value("APPNAME", "MachineControl");
    QString orgname = QProcessEnvironment::systemEnvironment().value("ORGNAME", "QuickHub");
    QString datadir = QProcessEnvironment::systemEnvironment().value("QUICKLAB_DATA_DIR", "");
    QString entrypoint = QProcessEnvironment::systemEnvironment().value("MAIN_QML", "");

    if(!datadir.isEmpty())
    {
        QSettings::setPath(QSettings::NativeFormat, QSettings::UserScope, datadir+"/user");
        QSettings::setPath(QSettings::NativeFormat, QSettings::SystemScope, datadir+"/system");
    }

    app.setOrganizationName(orgname);
    app.setApplicationName(appname);
    QQuickView engine2;
   // QQmlApplicationEngine engine2;
    engine2.setSource(QUrl(QStringLiteral("qrc:/main.qml")));
    engine2.show();
#endif

    return app.exec();
}
