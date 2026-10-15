#-------------------------------------------------
#
# Project created by QtCreator 2016-08-12T21:55:19
#
#-------------------------------------------------
INCLUDEPATH += $$PWD
# Version
DT_VERSION = 6.06
DEFINES += DT_VERSION=$$DT_VERSION

!android: {
    # Serial port available
    DEFINES += HAS_SERIALPORT
}

CONFIG += c++11
QMAKE_CXXFLAGS += -Wno-deprecated-copy

# Options
#Build mobile GUI
#CONFIG += build_mobile


# Bluetooth available
DEFINES += HAS_BLUETOOTH

QT       += core gui
QT       += widgets
QT       += printsupport
QT       += network
QT       += bluetooth
QT       += quick
QT       += quickcontrols2

contains(DEFINES, HAS_SERIALPORT) {
    QT       += serialport
}

android: QT += androidextras

android: TARGET = ENNOID-BMS-Tool
!android: TARGET = ENNOID-BMS-ToolV$$DT_VERSION

macx {
    TARGET = ENNOID-BMS-Tool
    ICON = osx/app_icon.icns
    QMAKE_INFO_PLIST = osx/Info.plist
    DISTFILES += osx/Info.plist osx/app_icon.icns osx/entitlements.plist
}

TEMPLATE = app

release_win {
    DESTDIR = build/win
    OBJECTS_DIR = build/win/obj
    MOC_DIR = build/win/obj
    RCC_DIR = build/win/obj
    UI_DIR = build/win/obj
}

release_lin {
    # http://micro.nicholaswilson.me.uk/post/31855915892/rules-of-static-linking-libstdc-libc-libgcc
    # http://insanecoding.blogspot.se/2012/07/creating-portable-linux-binaries.html
    QMAKE_LFLAGS += -static-libstdc++ -static-libgcc
    DESTDIR = build/lin
    OBJECTS_DIR = build/lin/obj
    MOC_DIR = build/lin/obj
    RCC_DIR = build/lin/obj
    UI_DIR = build/lin/obj
}

release_mac {
    DESTDIR = build/mac
    OBJECTS_DIR = build/mac/obj
    MOC_DIR = build/mac/obj
    RCC_DIR = build/mac/obj
    UI_DIR = build/mac/obj
}

release_android {
    DESTDIR = build/android
    OBJECTS_DIR = build/android/obj
    MOC_DIR = build/android/obj
    RCC_DIR = build/android/obj
    UI_DIR = build/android/obj
}

build_mobile {
    DEFINES += USE_MOBILE
}

SOURCES += main.cpp\
        mainwindow.cpp \
    packet.cpp \
    vbytearray.cpp \
    commands.cpp \
    configparams.cpp \
    configparam.cpp \
    parametereditor.cpp \
    digitalfiltering.cpp \
    bleuart.cpp \
    utility.cpp \
    bmsinterface.cpp

HEADERS  += mainwindow.h \
    packet.h \
    vbytearray.h \
    commands.h \
    datatypes.h \
    configparams.h \
    configparam.h \
    parametereditor.h \
    digitalfiltering.h \
    bleuart.h \
    utility.h \
    bmsinterface.h

FORMS    += mainwindow.ui \
    parametereditor.ui

include(pages/pages.pri)
include(widgets/widgets.pri)
include(mobile/mobile.pri)

RESOURCES += res.qrc



DISTFILES += \
    android/AndroidManifest.xml \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradlew \
    android/res/values/libs.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.properties

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

ANDROID_ABIS = x86

