#ifndef PROFILECLIENT_H
#define PROFILECLIENT_H

#include <QObject>
#include <QtDBus/QtDBus>

#include "profile_dbus.h"

typedef QList<QVariantMap> QVariantMapList;
Q_DECLARE_METATYPE(QVariantMapList)

struct MyStructure {
    QString key, val, type;
};
QDBusArgument &operator<<(QDBusArgument &a, const MyStructure &mystruct);
const QDBusArgument &operator>>(const QDBusArgument &a, MyStructure &mystruct);

Q_DECLARE_METATYPE(MyStructure)

class ProfileClient : public QObject
{
    Q_OBJECT
public:
    explicit ProfileClient(QObject *parent = 0);

    QVariant getProfileValue(const QString &key, const QVariant &def) const;
    bool setProfileValue(const QString &key, const QVariant &value);

private slots:
    void handleProfileChanged(bool changed, bool active, QString profile, QList<MyStructure> keyValType);

private:
    QDBusInterface *profiled;

};

#endif // PROFILECLIENT_H
