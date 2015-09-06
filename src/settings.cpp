#include <QCoreApplication>

#include "settings.h"

Settings::Settings(QObject *parent) :
    MDConfAgent("/apps/personalRingtones/numbers/", parent),
    extra(new MDConfAgent("/apps/personalRingtones/extra/", parent))
{
    MDConfAgent oldTree("/apps/personalRingtones/");
    QVariantMap oldItems = oldTree.listItems("");
    if (!oldItems.isEmpty()) {
        foreach (const QString &key, oldItems.keys()) {
            setValue(key, oldItems.value(key));
            oldTree.unsetValue(key);
        }
    }
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

void Settings::setMutedList(const QString &muted)
{
    if (muted.isEmpty()) {
        extra->unsetValue("muted");
    }
    else {
        extra->setValue("muted", muted.split(";"));
    }
}

QStringList Settings::getMutedList() const
{
    return extra->value("muted").toStringList();
}

void Settings::setNormalList(const QString &normal)
{
    if (normal.isEmpty()) {
        extra->unsetValue("normal");
    }
    else {
        extra->setValue("normal", normal.split(";"));
    }
}

QStringList Settings::getNormalList() const
{
    return extra->value("normal").toStringList();
}
