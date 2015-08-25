#include <sailfishapp.h>
#include <QGuiApplication>
#include <QQuickView>
#include <QScopedPointer>
#include <QtQml>

#include <TelepathyQt/Debug>
#include <TelepathyQt/Types>

#include "callinterceptor.h"
#include "settings.h"

static QObject *settings_singleton(QQmlEngine *, QJSEngine *)
{
    return Settings::GetInstance(0);
}

int main(int argc, char *argv[])
{
    Tp::registerTypes();
    //Tp::enableDebug(true);
    Tp::enableWarnings(true);

    CallInterceptor interceptor;
    if (!interceptor.isValid()) {
        return 1;
    }

    qmlRegisterSingletonType<Settings>("harbour.personal.ringtones", 1, 0, "RingtoneSettings", settings_singleton);


    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    app->setApplicationDisplayName("Personal Ringtones");
    app->setApplicationName("PersonalRingtones");
    app->setApplicationVersion(QString(APP_VERSION));

    QScopedPointer<QQuickView> view(SailfishApp::createView());
    view->setTitle("Personal Ringtones");

    view->setSource(SailfishApp::pathTo("qml/main.qml"));
    view->show();

    return app->exec();
}

