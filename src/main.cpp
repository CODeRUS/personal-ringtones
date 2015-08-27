#include <QCoreApplication>
#include <QScopedPointer>

#include <TelepathyQt/Debug>
#include <TelepathyQt/Types>

#include <QtDBus>

#include "callinterceptor.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    Tp::registerTypes();
    //Tp::enableDebug(true);
    Tp::enableWarnings(true);

    QScopedPointer<CallInterceptor> interceptor(new CallInterceptor(0));
    if (!interceptor->isValid()) {
        return 1;
    }

    QScopedPointer<QCoreApplication> app(new QCoreApplication(argc, argv));
    app->setApplicationName("PersonalRingtones");
    app->setApplicationVersion(QString(APP_VERSION));

    return app->exec();
}

