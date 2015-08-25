#include <QDebug>

#include "profileclient.h"

Q_DECLARE_METATYPE(QList<MyStructure>)

QDBusArgument &operator<<(QDBusArgument &argument, const MyStructure &mystruct)
{
    argument.beginStructure();
    argument << mystruct.key << mystruct.val << mystruct.type;
    argument.endStructure();
    return argument;
}

// Retrieve the MyStructure data from the D-Bus argument
const QDBusArgument &operator>>(const QDBusArgument &argument, MyStructure &mystruct)
{
    argument.beginStructure();
    argument >> mystruct.key;
    argument >> mystruct.val;
    argument >> mystruct.type;
    argument.endStructure();
    return argument;
}

ProfileClient::ProfileClient(QObject *parent) :
    QObject(parent)
{
    qDBusRegisterMetaType<QVariantMapList>();

    QDBusConnection::sessionBus().connect(PROFILED_SERVICE, PROFILED_PATH, PROFILED_INTERFACE,
                    "profile_changed", QString("bbsa(sss)"), this,
                    SIGNAL(handleProfileChanged(bool, bool, QString, QList<MyStructure>)));

    profiled = new QDBusInterface(PROFILED_SERVICE, PROFILED_PATH, PROFILED_INTERFACE, QDBusConnection::sessionBus());
}

void ProfileClient::handleProfileChanged(bool changed, bool active, QString profile, QList<MyStructure> keyValType)
{
    qDebug() << "handleProfileChanged" << changed << active << profile;
    foreach (MyStructure item, keyValType) {
        qDebug() << item.type << item.key << item.val;
    }
}

QVariant ProfileClient::getProfileValue(const QString &key, const QVariant &def) const
{
    QDBusMessage reply = profiled->call(PROFILED_GET_VALUE,
                                        QVariant("general"),
                                        QVariant(key));

    if (reply.type() == QDBusMessage::ErrorMessage) {
        qDebug() << "error reply:" << reply.errorName();
    } else if (reply.arguments().count() > 0) {
        return reply.arguments().at(0);
    }
    return def;
}

bool ProfileClient::setProfileValue(const QString &key, const QVariant &value)
{
    QDBusMessage reply = profiled->call(PROFILED_SET_VALUE,
                                        QVariant("general"),
                                        QVariant(key),
                                        value);

    if (reply.type() == QDBusMessage::ErrorMessage) {
        qDebug() << "error reply:" << reply.errorName();
    } else if (reply.arguments().count() > 0) {
        return reply.arguments().at(0).toBool();
    }
    return false;
}
