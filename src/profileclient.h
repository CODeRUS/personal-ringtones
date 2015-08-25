#ifndef PROFILECLIENT_H
#define PROFILECLIENT_H

#include <QObject>
#include <QtDBus/QtDBus>

#include "profile_dbus.h"

struct MyStructure {
    QString key, val, type;
};
Q_DECLARE_METATYPE(MyStructure)
typedef QList<MyStructure> MyStructureList;
Q_DECLARE_METATYPE(MyStructureList)

QDBusArgument &operator<<(QDBusArgument &a, const MyStructure &mystruct);
const QDBusArgument &operator>>(const QDBusArgument &a, MyStructure &mystruct);

class ProfileClient : public QObject
{
    Q_OBJECT
public:
    explicit ProfileClient(QObject *parent = 0);

    QString getProfileName() const;
    QVariant getProfileValue(const QString &key, const QVariant &def) const;
    bool setProfileValue(const QString &key, const QVariant &value);

private slots:
    void handleProfileChanged(bool, bool active, const QString &profile, const MyStructureList &);

private:
    QDBusInterface *profiled;
    QString profileName;

};

#endif // PROFILECLIENT_H
