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

contains(QMAKE_HOST.arch, aarch64) {
    libs.files = lib64/*.so
} else {
    libs.files = lib/*.so
}
libs.path = /usr/lib/voicecall/plugins
INSTALLS += libs

ngfd.files = \
    ngfd/personal_ringtone.ini \
    ngfd/important_ringtone.ini
ngfd.path = /usr/share/ngfd/events.d
INSTALLS += ngfd

THEMENAME=sailfish-default
CONFIG += sailfish-svg2png

appicon.sizes = \
    86 \
    108 \
    128 \
    256

for(iconsize, appicon.sizes) {
    profile = $${iconsize}x$${iconsize}
    system(mkdir -p $${OUT_PWD}/$${profile})

    appicon.commands += /usr/bin/sailfish_svg2png \
        -s 1 1 1 1 1 1 $${iconsize} \
        $${_PRO_FILE_PWD_}/appicon \
        $${profile}/apps/ &&

    appicon.files += $${profile}
}
appicon.commands += true
appicon.path = /usr/share/icons/hicolor/

INSTALLS += appicon
