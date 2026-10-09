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
#ifndef PERSONALRINGTONEPLUGIN_H
#define PERSONALRINGTONEPLUGIN_H

#include <abstractvoicecallmanagerplugin.h>
#include <abstractvoicecallhandler.h>

class NgfRingtonePluginPrivate;

/*
 * Replacement for the stock libvoicecall-ngf-plugin.
 *
 * It registers with the same plugin id ("ngf-plugin"). voicecall-manager loads
 * plugins in alphabetical order and refuses a second plugin with an id that is
 * already installed, so libvoicecall-angf-plugin.so wins over the stock one.
 */
class NgfRingtonePlugin : public AbstractVoiceCallManagerPlugin
{
    Q_OBJECT

    Q_PLUGIN_METADATA(IID "org.nemomobile.voicecall.ngf")
    Q_INTERFACES(AbstractVoiceCallManagerPlugin)

public:
    explicit NgfRingtonePlugin(QObject *parent = nullptr);
    ~NgfRingtonePlugin();

    QString pluginId() const override;

public Q_SLOTS:
    bool initialize() override;
    bool configure(VoiceCallManagerInterface *manager) override;
    bool start() override;
    bool suspend() override;
    bool resume() override;
    void finalize() override;

protected Q_SLOTS:
    void onVoiceCallAdded(AbstractVoiceCallHandler *handler);
    void onVoiceCallStatusChanged(AbstractVoiceCallHandler *handler = nullptr);
    void onVoiceCallDestroyed();
    void onPlayRingtoneRequested(const QString &ringtonePath);
    void onSilenceRingtoneRequested();

    void onConnectionStatus(bool connected);
    void onEventFailed(quint32 eventId);
    void onEventCompleted(quint32 eventId);
    void onEventPlaying(quint32 eventId);
    void onEventPaused(quint32 eventId);

private:
    void stopRingtone();

    NgfRingtonePluginPrivate *d_ptr;
    Q_DECLARE_PRIVATE(NgfRingtonePlugin)
};

#endif // PERSONALRINGTONEPLUGIN_H
