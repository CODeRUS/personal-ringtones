TARGET = harbour-personal-ringtones

QT += dbus
CONFIG += link_pkgconfig sailfishapp
PKGCONFIG += TelepathyQt5 dconf
INCLUDEPATH += /usr/include/telepathy-qt5

DEFINES += APP_VERSION=\\\"$$VERSION\\\"

SOURCES += \
    src/main.cpp \
    src/callinterceptor.cpp \
    src/profileclient.cpp \
    src/settings.cpp \
    src/mdconf.cpp \
    src/mdconfagent.cpp

HEADERS += \
    src/callinterceptor.h \
    src/profileclient.h \
    src/profile_dbus.h \
    src/settings.h \
    src/mdconf_p.h \
    src/mdconfagent.h

OTHER_FILES += \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    qml/pages/SecondPage.qml \
    qml/pages/SelectPhonebook.qml \
    qml/components/FastScroll.qml \
    qml/components/FastScroll.js \
    qml/components/global.js \
    qml/components/Popup.qml \
    rpm/harbour-personal-ringtones.spec \
    harbour-personal-ringtones.desktop \
    qml/main.qml
