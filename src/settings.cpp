#include "settings.h"

Settings::Settings(QObject *parent) :
    MDConfAgent("/apps/personalRingtones/", parent)
{
}

Settings *Settings::GetInstance(QObject *parent)
{
    static Settings* lsSingleton = NULL;
    if (!lsSingleton) {
        lsSingleton = new Settings(parent);
    }
    return lsSingleton;
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
