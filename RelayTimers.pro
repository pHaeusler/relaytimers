TEMPLATE = app

QT += qml quick widgets

SOURCES += src/main.cpp \
           src/controller.cpp \
           src/scheduler.cpp \
           src/relay.cpp \
           src/sysfsGpio/gpio-sysfs.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    src/controller.h \
    src/scheduler.h \
    src/relay.h \
    src/sysfsGpio/gpio-sysfs.h

CONFIG += c++11
