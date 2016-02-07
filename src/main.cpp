#include <QCoreApplication>
#include <QScopedPointer>
#include <QTimer>

#include "callinterceptor.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QCoreApplication> app(new QCoreApplication(argc, argv));
    app->setApplicationName("PersonalRngtones");
    app->setApplicationVersion(QString(APP_VERSION));

    QScopedPointer<CallInterceptor> interceptor(new CallInterceptor(0));
    QTimer::singleShot(1, interceptor.data(), SLOT(init()));

    return app->exec();
}

