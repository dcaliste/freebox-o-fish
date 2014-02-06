TEMPLATE = app
TARGET = harbour-freebox-o-fish
DEPENDPATH += .
INCLUDEPATH += .
CONFIG += link_pkgconfig
PKGCONFIG += sailfishapp

isEmpty(PREFIX)
{
  PREFIX = /usr
}

DEPLOYMENT_PATH = $$PREFIX/share/$$TARGET

# Input
SOURCES += main.cpp

# Installation
target.path = $$PREFIX/bin

desktop.path = $$PREFIX/share/applications
desktop.files = ../harbour-freebox-o-fish.desktop

icon.path = $$PREFIX/share/icons/hicolor/86x86/apps
icon.files = ../harbour-freebox-o-fish.png

qml.path = $$DEPLOYMENT_PATH/qml
qml.files = ../qml/harbour-freebox-o-fish.qml ../qml/About.qml ../qml/CallPage.qml ../qml/loader.js

resources.path = $$DEPLOYMENT_PATH
resources.files = ../about-freebox-o-fish.png

INSTALLS += target desktop icon qml resources
