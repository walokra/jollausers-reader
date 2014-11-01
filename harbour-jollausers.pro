TARGET = harbour-jollausers

# Application version
DEFINES += APP_VERSION=\\\"$$VERSION\\\"
DEFINES += APP_RELEASE=\\\"$$RELEASE\\\"

CONFIG += sailfishapp
QT += xml

SOURCES += \
    main.cpp \
    src/feedloader.cpp

HEADERS += \
    src/feedloader.h

OTHER_FILES = \
    rpm/harbour-jollausers.spec \
    rpm/harbour-jollausers.yaml \
    rpm/harbour-jollausers.changes \
    translations/*.ts \
    qml/MainPage.qml \
    qml/Constants.qml \
    qml/Settings.qml \
    qml/main.qml \
    qml/FeedModel.qml \
    qml/SourcesModel.qml \
    qml/AboutPage.qml \
    qml/WebPage.qml \
    qml/CoverPage.qml \
    qml/Panel.qml \
    qml/PanelView.qml \
    qml/FeedPanel.qml \
    qml/RSSModel.qml

INCLUDEPATH += $$PWD
