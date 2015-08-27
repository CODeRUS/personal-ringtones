#ifndef SETTINGS_H
#define SETTINGS_H

#include <QObject>

#include "mdconfagent.h"

class Settings : public MDConfAgent
{
    Q_OBJECT
public:
    explicit Settings(QObject *parent = 0);

    Q_INVOKABLE QString getRingtone(const QString &number) const;
    Q_INVOKABLE void setRingtone(const QString &number, const QString &value);
    Q_INVOKABLE void removeRingtone(const QString &number);
    Q_INVOKABLE QVariantMap getItems() const;
    Q_INVOKABLE QString getVersion() const;

signals:

public slots:

};

#endif // SETTINGS_H
