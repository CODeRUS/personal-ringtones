#include <QDebug>

#include "profileclient.h"

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
    qDBusRegisterMetaType<MyStructure>();
    qDBusRegisterMetaType<MyStructureList>();

    profiled = new QDBusInterface(PROFILED_SERVICE, PROFILED_PATH, PROFILED_INTERFACE, QDBusConnection::sessionBus());

    QDBusMessage reply = profiled->call(PROFILED_GET_PROFILE);

    if (reply.type() == QDBusMessage::ErrorMessage) {
        qDebug() << "error reply:" << reply.errorName();
        profileName = "general";
    } else if (reply.arguments().count() > 0) {
        profileName = reply.arguments().at(0).toString();
    }

    QDBusConnection::sessionBus().connect(PROFILED_SERVICE, PROFILED_PATH, PROFILED_INTERFACE,
                                          PROFILED_CHANGED, this,
                                          SIGNAL(handleProfileChanged(bool, bool, QString, MyStructureList)));
}

QString ProfileClient::getProfileName() const
{
    return profileName;
}

void ProfileClient::handleProfileChanged(bool, bool active, const QString &profile, const MyStructureList &)
{
    if (active) {
        profileName = profile;
    }
}

QVariant ProfileClient::getProfileValue(const QString &key, const QVariant &def) const
{
    QDBusMessage reply = profiled->call(PROFILED_GET_VALUE,
                                        profileName,
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
                                        profileName,
                                        QVariant(key),
                                        value);

    if (reply.type() == QDBusMessage::ErrorMessage) {
        qDebug() << "error reply:" << reply.errorName();
    } else if (reply.arguments().count() > 0) {
        return reply.arguments().at(0).toBool();
    }
    return false;
}
