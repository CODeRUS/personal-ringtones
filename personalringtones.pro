TARGET = personalringtones
target.path = /usr/bin

QT += dbus
CONFIG += link_pkgconfig qt-boostable
PKGCONFIG += TelepathyQt5 dconf Qt5SystemInfo qofono-qt5

INCLUDEPATH += /usr/include/telepathy-qt5

DEFINES += APP_VERSION=\\\"$$VERSION\\\"

dbus.files = dbus/org.coderus.personalringtones.service
dbus.path = /usr/share/dbus-1/services

systemd.files = systemd/personalringtones.service
systemd.path = /usr/lib/systemd/user

pages.files = settings/personalringtones.json
pages.path = /usr/share/jolla-settings/entries

qml.files = qml
qml.path = /usr/share/personalringtones

icons.files = icons
icons.path = /usr/share/personalringtones

INSTALLS += target dbus systemd pages qml icons

SOURCES += \
    src/main.cpp \
    src/callinterceptor.cpp \
    src/profileclient.cpp \
    src/mdconf.cpp \
    src/mdconfagent.cpp \
    src/settings.cpp

HEADERS += \
    src/callinterceptor.h \
    src/profileclient.h \
    src/profile_dbus.h \
    src/mdconf_p.h \
    src/mdconfagent.h \
    src/settings.h

OTHER_FILES += \
    rpm/personalringtones.spec
