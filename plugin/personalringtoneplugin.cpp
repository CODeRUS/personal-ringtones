/*
 * Personal ringtones voicecall plugin
 *
 * Based on the NGF ringtone plugin of the Voice Call Manager project
 * Copyright (C) 2011-2012  Tom Swindell <t.swindell@rubyx.co.uk>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 */
#include "personalringtoneplugin.h"

#include <abstractvoicecallprovider.h>
#include <voicecallmanagerinterface.h>

#include <NgfClient>

#include <QDateTime>
#include <QDir>
#include <QFileInfo>
#include <QLoggingCategory>
#include <QStringList>
#include <QtPlugin>

#ifdef USE_MDCONFITEM
#include <MDConfItem>
typedef MDConfItem ConfItem;
#else
#include <MGConfItem>
typedef MGConfItem ConfItem;
#endif

Q_LOGGING_CATEGORY(lcPersonalRingtones, "personalringtones", QtInfoMsg)

#define PR_DEBUG(...) qCDebug(lcPersonalRingtones, __VA_ARGS__)
#define PR_INFO(...) qCInfo(lcPersonalRingtones, __VA_ARGS__)

namespace {

const QString ConfPrefix = QStringLiteral("/apps/personal-ringtones/%1");
const QString DefaultRandomPath = QStringLiteral("/usr/share/sounds/jolla-ringtones/stereo");

const QString EventRingtone = QStringLiteral("ringtone");
const QString EventPersonal = QStringLiteral("personal_ringtone");
const QString EventImportant = QStringLiteral("important_ringtone");
const QString Muted = QStringLiteral("muted");

QVariant confValue(const QString &key, const QVariant &defaultValue = QVariant())
{
    ConfItem item(ConfPrefix.arg(key));
    const QVariant value = item.value();
    return value.isNull() ? defaultValue : value;
}

QStringList confList(const QString &key)
{
    return confValue(key).toString().split(QLatin1Char(';'), QString::SkipEmptyParts);
}

// Same normalisation the settings UI applies before storing numbers.
QString normalizeNumber(const QString &number)
{
    QString result;
    result.reserve(number.size());
    for (const QChar &c : number) {
        if (c.isDigit() || c == QLatin1Char('+'))
            result.append(c);
    }
    return result;
}

bool numbersMatch(const QString &incoming, const QString &stored, int digits)
{
    const QString a = normalizeNumber(incoming);
    const QString b = normalizeNumber(stored);
    if (a.isEmpty() || b.isEmpty())
        return false;
    if (digits <= 0)
        return a == b;
    if (a.size() < digits || b.size() < digits)
        return a == b;
    return a.right(digits) == b.right(digits);
}

QString findMatch(const QString &incoming, const QStringList &numbers, int digits)
{
    for (const QString &number : numbers) {
        if (numbersMatch(incoming, number, digits))
            return number;
    }
    return QString();
}

QString randomRingtone()
{
    QDir dir(confValue(QStringLiteral("randomPath"), DefaultRandomPath).toString());
    if (!dir.exists())
        return QString();

    const QStringList files = dir.entryList(QStringList()
                                            << QStringLiteral("*.mp3") << QStringLiteral("*.ogg")
                                            << QStringLiteral("*.oga") << QStringLiteral("*.opus")
                                            << QStringLiteral("*.wav") << QStringLiteral("*.flac")
                                            << QStringLiteral("*.m4a") << QStringLiteral("*.aac"),
                                            QDir::Files | QDir::Readable);
    if (files.isEmpty())
        return QString();

    return dir.absoluteFilePath(files.at(qrand() % files.size()));
}

} // namespace

class NgfRingtonePluginPrivate
{
public:
    VoiceCallManagerInterface *manager = nullptr;
    AbstractVoiceCallHandler *currentCall = nullptr;
    int activeCallCount = 0;

    Ngf::Client *ngf = nullptr;
    quint32 ringtoneEventId = 0;
};

NgfRingtonePlugin::NgfRingtonePlugin(QObject *parent)
    : AbstractVoiceCallManagerPlugin(parent)
    , d_ptr(new NgfRingtonePluginPrivate)
{
    PR_DEBUG("Personal ringtones plugin created");
}

NgfRingtonePlugin::~NgfRingtonePlugin()
{
    PR_DEBUG("Personal ringtones plugin deleted");
    delete d_ptr;
}

QString NgfRingtonePlugin::pluginId() const
{
    return QStringLiteral("ngf-plugin");
}

bool NgfRingtonePlugin::initialize()
{
    Q_D(NgfRingtonePlugin);
    PR_INFO("Personal ringtones plugin initialize");
    qsrand(uint(QDateTime::currentMSecsSinceEpoch()));
    d->ngf = new Ngf::Client(this);
    return true;
}

bool NgfRingtonePlugin::configure(VoiceCallManagerInterface *manager)
{
    Q_D(NgfRingtonePlugin);
    d->manager = manager;

    connect(d->ngf, SIGNAL(connectionStatus(bool)), SLOT(onConnectionStatus(bool)));
    connect(d->ngf, SIGNAL(eventFailed(quint32)), SLOT(onEventFailed(quint32)));
    connect(d->ngf, SIGNAL(eventCompleted(quint32)), SLOT(onEventCompleted(quint32)));
    connect(d->ngf, SIGNAL(eventPlaying(quint32)), SLOT(onEventPlaying(quint32)));
    connect(d->ngf, SIGNAL(eventPaused(quint32)), SLOT(onEventPaused(quint32)));
    return true;
}

bool NgfRingtonePlugin::start()
{
    Q_D(NgfRingtonePlugin);

    connect(d->manager, SIGNAL(voiceCallAdded(AbstractVoiceCallHandler*)),
            SLOT(onVoiceCallAdded(AbstractVoiceCallHandler*)));
    // Since SFOS 4.5 the call UI asks explicitly for the ringtone
    // (it may pass a contact/SIM specific file, empty otherwise).
    connect(d->manager, SIGNAL(playRingtoneRequested(QString)),
            SLOT(onPlayRingtoneRequested(QString)));
    connect(d->manager, SIGNAL(silenceRingtoneRequested()),
            SLOT(onSilenceRingtoneRequested()));

    d->ngf->connect();
    return true;
}

bool NgfRingtonePlugin::suspend()
{
    return true;
}

bool NgfRingtonePlugin::resume()
{
    return true;
}

void NgfRingtonePlugin::finalize()
{
}

void NgfRingtonePlugin::stopRingtone()
{
    Q_D(NgfRingtonePlugin);
    if (d->ringtoneEventId) {
        PR_DEBUG("Stopping ringtone, event id: %u", d->ringtoneEventId);
        d->ngf->stop(d->ringtoneEventId);
        d->ringtoneEventId = 0;
    }
}

void NgfRingtonePlugin::onVoiceCallAdded(AbstractVoiceCallHandler *handler)
{
    Q_D(NgfRingtonePlugin);

    ++d->activeCallCount;
    PR_DEBUG("Active call count: %d", d->activeCallCount);

    connect(handler, SIGNAL(statusChanged(VoiceCallStatus)), SLOT(onVoiceCallStatusChanged()));
    connect(handler, SIGNAL(destroyed()), SLOT(onVoiceCallDestroyed()));
    if (handler->status() != AbstractVoiceCallHandler::STATUS_NULL)
        onVoiceCallStatusChanged(handler);
}

void NgfRingtonePlugin::onVoiceCallStatusChanged(AbstractVoiceCallHandler *handler)
{
    Q_D(NgfRingtonePlugin);

    if (!handler) {
        handler = qobject_cast<AbstractVoiceCallHandler *>(sender());
        if (!handler)
            return;
    }

    PR_DEBUG("Voice call status changed to: %s", qPrintable(handler->statusText()));

    if (handler->status() != AbstractVoiceCallHandler::STATUS_INCOMING) {
        if (d->currentCall == handler) {
            d->currentCall = nullptr;
            stopRingtone();
        }
    } else if (!d->currentCall) {
        d->currentCall = handler;
    }
}

void NgfRingtonePlugin::onVoiceCallDestroyed()
{
    Q_D(NgfRingtonePlugin);

    if (d->currentCall == sender()) {
        d->currentCall = nullptr;
        stopRingtone();
    }

    --d->activeCallCount;
    PR_DEBUG("Active call count: %d", d->activeCallCount);
}

void NgfRingtonePlugin::onPlayRingtoneRequested(const QString &ringtonePath)
{
    Q_D(NgfRingtonePlugin);

    if (d->ringtoneEventId != 0 || !d->currentCall)
        return;

    QMap<QString, QVariant> props;
    if (d->activeCallCount > 1)
        props.insert(QStringLiteral("play.mode"), QStringLiteral("short"));

    AbstractVoiceCallProvider *provider = d->currentCall->provider();
    if (provider && provider->providerType() != QLatin1String("tel"))
        props.insert(QStringLiteral("type"), QStringLiteral("voip"));

    QString event = EventRingtone;
    QString tone = ringtonePath;

    const QString lineId = d->currentCall->lineId();
    PR_INFO("Incoming from: %s", qPrintable(lineId));

    if (!normalizeNumber(lineId).isEmpty()) {
        const int digits = confValue(QStringLiteral("match"), 0).toInt();

        // Personal ringtone for this number?
        const QString personal = findMatch(lineId, confList(QStringLiteral("numbers")), digits);
        if (!personal.isEmpty()) {
            PR_INFO("Matching number: %s", qPrintable(personal));
            const QString personalTone = confValue(personal).toString();
            PR_INFO("Ringtone for: %s %s", qPrintable(personal), qPrintable(personalTone));
            if (personalTone == Muted) {
                event = Muted;
            } else if (!personalTone.isEmpty() && QFileInfo::exists(personalTone)) {
                event = EventPersonal;
                tone = personalTone;
            }
        }

        // Important contacts always ring, even in silent profile.
        const QString important = findMatch(lineId, confList(QStringLiteral("important")), digits);
        if (!important.isEmpty()) {
            PR_INFO("Matching important number: %s", qPrintable(important));
            event = EventImportant;
        }
    }

    if (event == Muted) {
        PR_INFO("Ignoring ringtone");
        return;
    }

    // Random ringtone for everybody without a personal or app-provided tone.
    if (event == EventRingtone && tone.isEmpty()
            && confValue(QStringLiteral("random"), false).toBool()) {
        const QString random = randomRingtone();
        if (!random.isEmpty()) {
            PR_INFO("Random ringtone: %s", qPrintable(random));
            event = EventPersonal;
            tone = random;
        }
    }

    if (!tone.isEmpty())
        props.insert(QStringLiteral("sound.filename"), tone);

    d->ringtoneEventId = d->ngf->play(event, props);
    PR_INFO("Playing ringtone, event (%s) id: %u", qPrintable(event), d->ringtoneEventId);
}

void NgfRingtonePlugin::onSilenceRingtoneRequested()
{
    Q_D(NgfRingtonePlugin);
    if (d->ringtoneEventId) {
        PR_DEBUG("Pausing ringtone due to silence");
        d->ngf->pause(d->ringtoneEventId);
    }
}

void NgfRingtonePlugin::onConnectionStatus(bool connected)
{
    PR_DEBUG("Connection to NGF daemon changed to: %s", connected ? "connected" : "disconnected");
}

void NgfRingtonePlugin::onEventFailed(quint32 eventId)
{
    Q_D(NgfRingtonePlugin);
    PR_INFO("Ringtone event failed: %u", eventId);
    if (eventId == d->ringtoneEventId)
        d->ringtoneEventId = 0;
}

void NgfRingtonePlugin::onEventCompleted(quint32 eventId)
{
    Q_D(NgfRingtonePlugin);
    if (eventId == d->ringtoneEventId)
        d->ringtoneEventId = 0;
}

void NgfRingtonePlugin::onEventPlaying(quint32 eventId)
{
    Q_UNUSED(eventId)
}

void NgfRingtonePlugin::onEventPaused(quint32 eventId)
{
    Q_UNUSED(eventId)
}
