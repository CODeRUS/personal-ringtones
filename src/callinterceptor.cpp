#include <TelepathyQt/ContactManager>
#include <TelepathyQt/PendingContacts>
#include <TelepathyQt/ChannelClassSpecList>
#include <TelepathyQt/CallChannel>
#include <TelepathyQt/StreamedMediaChannel>
#include <TelepathyQt/PendingReady>

#include <QTimer>

#include "callinterceptor.h"
#include "settings.h"

#define TELEPHONY_PROTOCOL "tel"

IncomingChannel::IncomingChannel(IncomingCall *call,
                                 const Tp::ChannelPtr &channel) :
    _call(call),
    _interceptor(call->interceptor()),
    _channel(channel),
    _ready(false)
{
    connect(_channel.data(), &Tp::DBusProxy::invalidated,
            this, &IncomingChannel::channelInvalid);
    connect(_channel->becomeReady(), &Tp::PendingReady::finished,
            this, &IncomingChannel::channelReady);
}

void IncomingChannel::channelInvalid(Tp::DBusProxy *,
                                     const QString &errorName,
                                     const QString &errorMessage)
{
    qDebug() << errorName << errorMessage;
    finish();
}

void IncomingChannel::channelReady(Tp::PendingOperation *operation)
{
    _ready = true;
    if (operation->isValid() && _interceptor->profiled.getProfileName() != "silent") {
        QString number = _channel->targetId();
        qDebug() << number;
        QString ringtone = _interceptor->settings.value(number, QString()).toString();
        if (ringtone.isEmpty()) {
            _interceptor->profiled.setProfileValue("ringing.alert.tone", _interceptor->settings.value("default", QString("/usr/share/sounds/jolla-ringtones/stereo/jolla-ringtone.wav")).toString());
        }
        else {
            _interceptor->profiled.setProfileValue("ringing.alert.tone", ringtone);
        }
    }

    QTimer::singleShot(500, this, SLOT(delayedReady())); // to load ngfd tone
}

void IncomingChannel::finish()
{
    deleteLater();
}

void IncomingChannel::delayedReady()
{
    _call->channelReady(_channel);
    finish();
}

IncomingCall::IncomingCall(CallInterceptor *interceptor,
                           const Tp::MethodInvocationContextPtr<> &context,
                           const QList<Tp::ChannelPtr> &channels,
                           const Tp::ChannelDispatchOperationPtr &dispatchOperation) :
    _interceptor(interceptor),
    _context(context),
    _channels(channels),
    _dispatchOperation(dispatchOperation),
    _pending(0),
    _ready(false)
{
    qDebug() << "Incoming operation";
    foreach (const Tp::ChannelPtr& ptr, _channels)
    {
        _pending++;
        new IncomingChannel(this, ptr);
    }
    _ready = true;
    if (!_pending)
    {
        allReady();
    }
}

void IncomingCall::channelReady(const Tp::ChannelPtr &)
{
    _pending--;
    if (!_pending && _ready) {
        allReady();
    }
}

void IncomingCall::allReady()
{
    finish();
}

void IncomingCall::claimOperation()
{
    if (_dispatchOperation.isNull()) {
        finish();
        return;
    }
    qDebug() << "Claiming operation";
    connect(_dispatchOperation->claim(), &Tp::PendingOperation::finished,
            this, &IncomingCall::dispatchClaimed);
}

void IncomingCall::dispatchClaimed(Tp::PendingOperation *operation)
{
    if (!operation->isValid()) {
        qDebug() << "Operation could not be claimed:" << operation->errorMessage();
        finish();
        return;
    }
    else {
        qDebug() << "Operation claimed";
    }

    finish();
}

void IncomingCall::channelDisconnected(Tp::PendingOperation *operation)
{
    if (!operation->isValid())
    {
        qDebug() << "Channel could not be disconnected:" << operation->errorMessage();
    }
    else {
        qDebug() << "Channel disconnected";
    }
    _pending--;
    if (!_pending && _ready)
    {
        allDisconnected();
    }
}

void IncomingCall::allDisconnected()
{
    qDebug() << "Disconnected";
    claimOperation();
}

void IncomingCall::channelClosed(Tp::PendingOperation *operation)
{
    if (!operation->isValid())
    {
        qDebug() << "Channel could not be closed:" << operation->errorMessage();
    }
    else {
        qDebug() << "Channel closed";
    }
    _pending--;
    if (!_pending && _ready)
    {
        allClosed();
    }
}

void IncomingCall::allClosed()
{
    qDebug() << "Channels closed";
    finish();
}

void IncomingCall::finish()
{
    qDebug() << "Operation complete";
    _context->setFinished();
    deleteLater();
}

InterceptClientPtr InterceptClient::create(CallInterceptor *interceptor)
{
    return InterceptClientPtr(new InterceptClient(interceptor));
}

void InterceptClient::observeChannels(const Tp::MethodInvocationContextPtr<> &context,
                                      const Tp::AccountPtr &,
                                      const Tp::ConnectionPtr &connection,
                                      const QList<Tp::ChannelPtr> &channels,
                                      const Tp::ChannelDispatchOperationPtr &dispatchOperation,
                                      const QList<Tp::ChannelRequestPtr> &,
                                      const ObserverInfo &)
{
    foreach (const Tp::ChannelPtr& ptr, channels) {
        qDebug() << ptr->targetId();
    }

    if (!dispatchOperation.isNull() && !dispatchOperation->isValid())
    {
        // outgoing call
        context->setFinished();
        return;
    }
    if (connection->protocolName() != TELEPHONY_PROTOCOL)
    {
        // not a telephony call
        qDebug() << "Protocol not supported:" << connection->protocolName();
        context->setFinished();
        return;
    }
    new IncomingCall(_interceptor, context, channels, dispatchOperation);
}

InterceptClient::InterceptClient(CallInterceptor *interceptor) :
    InterceptClientBase(Tp::ChannelClassSpecList()
                        << Tp::ChannelClassSpec::mediaCall()
                        << Tp::ChannelClassSpec::streamedMediaCall()),
    _interceptor(interceptor)
{
}

CallInterceptor::CallInterceptor(QObject *parent) :
    QObject(parent),
    _failed(false)
{
    init();
}

void CallInterceptor::init()
{
    _registrar = Tp::ClientRegistrar::create();
    _client = InterceptClient::create(this);
    _registrar->registerClient(Tp::AbstractClientPtr::dynamicCast(_client), "PersonalRingtones", true);
    qDebug() << "Telepathy client registered";

    QString def = settings.value("default", QString()).toString();
    if (def.isEmpty()) {
        settings.setValue("default", profiled.getProfileValue("ringing.alert.tone", "/usr/share/sounds/jolla-ringtones/stereo/jolla-ringtone.wav"));
    }

    qDebug() << "DBus service" << (QDBusConnection::sessionBus().registerService("org.coderus.personalringtones") ? "registered" : "error!");
    qDebug() << "DBus object" << (QDBusConnection::sessionBus().registerObject("/", this, QDBusConnection::ExportScriptableContents) ? "registered" : "error!");
}

bool CallInterceptor::isValid()
{
    return !_failed;
}

QVariantMap CallInterceptor::getItems() const
{
    return settings.getItems();
}

QString CallInterceptor::getRingtone(const QString &number) const
{
    return settings.getRingtone(number);
}

void CallInterceptor::setRingtone(const QString &number, const QString &value)
{
    settings.setRingtone(number, value);
}

void CallInterceptor::removeRingtone(const QString &number)
{
    settings.removeRingtone(number);
}

QString CallInterceptor::getVersion() const
{
    return settings.getVersion();
}
