#include <QCoreApplication>

#include "settings.h"

Settings::Settings(QObject *parent) :
    MDConfAgent("/apps/personalRingtones/", parent)
{
}

QString Settings::getRingtone(const QString &number) const
{
    return value(number).toString();
}

void Settings::setRingtone(const QString &number, const QString &value)
{
    setValue(number, value);
}

void Settings::removeRingtone(const QString &number)
{
    unsetValue(number);
}

QVariantMap Settings::getItems() const
{
    return listItems("");
}

QString Settings::getVersion() const
{
    return QCoreApplication::instance()->applicationVersion();
}
