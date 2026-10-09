TEMPLATE = lib
TARGET = voicecall-angf-plugin

QT = core
CONFIG += plugin link_pkgconfig c++11

PKGCONFIG += ngf-qt5 mlite5

# mlite >= 0.5.0 renamed MGConfItem to MDConfItem (old name is deprecated)
system(pkg-config --atleast-version=0.5.0 mlite5) {
    DEFINES += USE_MDCONFITEM
}

INCLUDEPATH += /usr/include/voicecall
LIBS += -lvoicecall

HEADERS += personalringtoneplugin.h
SOURCES += personalringtoneplugin.cpp

target.path = $$[QT_INSTALL_LIBS]/voicecall/plugins
INSTALLS += target
