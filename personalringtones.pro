TARGET = personalringtones

CONFIG += sailfishapp

SOURCES += \
    src/personalringtones.cpp

DISTFILES += \
    rpm/personalringtones.spec \
    translations/*.ts \
    personalringtones.desktop \
    qml/personalringtones.qml \
    qml/cover/CoverPage.qml \
    qml/pages/MainPage.qml \
    qml/pages/AboutPage.qml \
    qml/pages/RandomRingtone.qml \
    qml/pages/ImportantContacts.qml \
    qml/pages/PersonalRingtones.qml

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/personalringtones-ru.ts

privileges.files = personalringtones.privileges
privileges.path = /usr/share/mapplauncherd/privileges.d/
INSTALLS += privileges

libs.files = lib/*.so
libs.path = /usr/lib/voicecall/plugins
INSTALLS += libs

ngfd.files = \
    ngfd/personal_ringtone.ini \
    ngfd/important_ringtone.ini
ngfd.path = /usr/share/ngfd/events.d
INSTALLS += ngfd
