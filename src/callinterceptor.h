#ifndef CALLINTERCEPTOR_H
#define CALLINTERCEPTOR_H

#include <TelepathyQt/ChannelDispatchOperation>
#include <TelepathyQt/AbstractClientApprover>
#include <TelepathyQt/AbstractClientObserver>
#include <TelepathyQt/ClientRegistrar>

#include "profileclient.h"
#include "settings.h"

class IncomingChannel;
class IncomingCall;
class InterceptClient;
class CallInterceptor;

typedef Tp::SharedPtr<InterceptClient> InterceptClientPtr;

class IncomingChannel : public QObject
{
    Q_OBJECT
public:
    IncomingChannel(IncomingCall *call,
                    const Tp::ChannelPtr &channel);

protected slots:
    void channelInvalid(Tp::DBusProxy *proxy,
                        const QString &errorName,
                        const QString &errorMessage);
    void channelReady(Tp::PendingOperation *operation);

protected:
    IncomingCall *_call;
    CallInterceptor *_interceptor;
    Tp::ChannelPtr _channel;
    bool _ready;

    void finish();

private slots:
    void delayedReady();
};

class IncomingCall : public QObject
{
    Q_OBJECT
public:
    IncomingCall(CallInterceptor *interceptor,
                 const Tp::MethodInvocationContextPtr<> &context,
                 const QList<Tp::ChannelPtr> &channels,
                 const Tp::ChannelDispatchOperationPtr &dispatchOperation);

    void channelReady(const Tp::ChannelPtr &channel);
    CallInterceptor* interceptor() { return _interceptor; }

protected slots:
    void dispatchClaimed(Tp::PendingOperation *operation);
    void channelDisconnected(Tp::PendingOperation *operation);
    void channelClosed(Tp::PendingOperation *operation);

protected:
    void allReady();
    void claimOperation();
    void disconnectChannels();
    void allDisconnected();
    void closeChannels();
    void allClosed();
    void finish();

    CallInterceptor *_interceptor;
    Tp::MethodInvocationContextPtr<> _context;
    QList<Tp::ChannelPtr> _channels;
    Tp::ChannelDispatchOperationPtr _dispatchOperation;
    unsigned _pending;
    bool _ready, _reject;
};

#define InterceptClientBase Tp::AbstractClientObserver

class InterceptClient : public InterceptClientBase
{
public:
    static InterceptClientPtr create(CallInterceptor *interceptor);

    void observeChannels(const Tp::MethodInvocationContextPtr<> &context,
                         const Tp::AccountPtr &account,
                         const Tp::ConnectionPtr &connection,
                         const QList<Tp::ChannelPtr> &channels,
                         const Tp::ChannelDispatchOperationPtr &dispatchOperation,
                         const QList<Tp::ChannelRequestPtr> &requestsSatisfied,
                         const ObserverInfo &observerInfo);

protected:
    InterceptClient(CallInterceptor *interceptor);
    CallInterceptor *_interceptor;
};

class CallInterceptor : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.coderus.personalringtones")

public:
    explicit CallInterceptor(QObject *parent = 0);
    bool isValid();

    ProfileClient profiled;
    Settings settings;

    Q_SCRIPTABLE QVariantMap getItems() const;
    Q_SCRIPTABLE QString getRingtone(const QString &number) const;
    Q_SCRIPTABLE void setRingtone(const QString &number, const QString &value);
    Q_SCRIPTABLE void removeRingtone(const QString &number);
    Q_SCRIPTABLE QString getVersion() const;

private:
    bool _failed;
    Tp::ClientRegistrarPtr _registrar;
    InterceptClientPtr _client;

    void init();
};

#endif // CALLINTERCEPTOR_H
