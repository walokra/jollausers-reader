import QtQuick 2.1
import Sailfish.Silica 1.0
import QtQuick.XmlListModel 2.0

Page {
    id: mp

    property alias contentItem: flickable;
    property bool hasQuickScroll: listView.hasOwnProperty("quickScroll") || listView.quickScroll;

    Connections {
        target: coverAdaptor;

        onRefresh: {
            feedModel.refresh();
        }

        onAbort: {
            feedModel.abort();
        }
    }

    SilicaFlickable {
        id: flickable
        z: -2

        anchors.fill: parent;

        PageHeader { id: header; title: selectedSectionName + " - " + constants.appName }

        PullDownMenu {
            id: pullDownMenu;

            MenuItem {
                id: aboutMenu;
                text: qsTr("About");
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("AboutPage.qml"));
                }
            }

            MenuItem {
                text: qsTr("Refresh");
                onClicked: {
                    feedModel.refresh();
                }
            }
        }

        SilicaListView {
            id: listView;

            anchors { top: header.bottom; left: parent.left; right: parent.right; bottom: parent.bottom; }
            anchors.margins: constants.paddingSmall;

            cacheBuffer: 4000;
            pressDelay: 0;
            clip: true;

            ViewPlaceholder {
                enabled: sourcesModel.count > 0 && !feedModel.busy && feedModel.allFeeds.length === 0;
                text: qsTr("Pull down to refresh");
            }

            model: newsModel;

            delegate: Column {
                id: feedItem;

                opacity: feedModel.busy ? 0.2 : 1;
                enabled: !feedModel.busy;

                width: listView.width;
                anchors { left: parent.left; right: parent.right; }

                spacing: constants.paddingMedium;
                height: childrenRect.height + constants.paddingLarge;
                anchors.bottomMargin: constants.paddingMedium;

                Label {
                    id: titleLbl;
                    width: parent.width;
                    font.pixelSize: constants.fontSizeSmall;
                    color: (read) ? constants.colorSecondary : constants.colorPrimary;
                    textFormat: Text.PlainText;
                    wrapMode: Text.Wrap;
                    text: title;

                    MouseArea {
                        enabled: link !== "";
                        anchors.fill: parent;
                        onClicked: {
                            markAsRead(link);

                            var props = {
                                "url": link
                            }
                            pageStack.push(Qt.resolvedUrl("WebPage.qml"), props);
                        }
                    }
                }

                Column {
                    spacing: constants.paddingSmall;
                    anchors { left: parent.left; right: parent.right; }
                    anchors.leftMargin: constants.paddingSmall;

                    Label {
                        id: descLbl;
                        //visible: settings.showDescription == true && description != "";
                        width: parent.width
                        font.pixelSize: constants.fontSizeXXSmall
                        color: constants.colorHighlight;
                        textFormat: Text.RichText;
                        wrapMode: Text.Wrap;
                        text: description;
                    }

                    Label {
                        id: published
                        width: parent.width
                        font.pixelSize: constants.fontSizeXXSmall
                        color: constants.colorHilightSecondary
                        textFormat: Text.PlainText;
                        text: dateString;
                    }
                }
            }

            // Timer for top/bottom buttons
            Timer {
                id: idle;
                property bool moving: listView.moving || listView.dragging || listView.flicking;
                property bool menuOpen: pullDownMenu.active;
                onMovingChanged: if (!moving && !menuOpen) restart();
                interval: listView.atYBeginning || listView.atYEnd ? 300 : 2000;
            }

            // to top button
            Rectangle {
                visible: !hasQuickScroll && opacity > 0;
                width: 64;
                height: 64;
                anchors { top: listView.top; right: listView.right; margins: Theme.paddingLarge; }
                radius: 75;
                color: Theme.highlightBackgroundColor;
                opacity: (idle.moving || idle.running) && !idle.menuOpen ? 1 : 0;
                Behavior on opacity { FadeAnimation { duration: 300; } }

                IconButton {
                    anchors.centerIn: parent;
                    icon.source: "image://theme/icon-l-up";
                    onClicked: {
                        listView.cancelFlick();
                        listView.scrollToTop();
                    }
                }
            }

            // to bottom button
            Rectangle {
                visible: !hasQuickScroll && opacity > 0;
                width: 64;
                height: 64;
                anchors { bottom: listView.bottom; right: listView.right; margins: constants.paddingLarge; }
                radius: 75;
                color: Theme.highlightBackgroundColor;
                opacity: (idle.moving || idle.running) && !idle.menuOpen ? 1 : 0;
                Behavior on opacity { FadeAnimation { duration: 300; } }

                IconButton {
                    anchors.centerIn: parent;
                    icon.source: "image://theme/icon-l-down";
                    onClicked: {
                        listView.cancelFlick();
                        listView.scrollToBottom();
                    }
                }
            }

            VerticalScrollDecorator { flickable: flickable }
        }
    }

    function markAsRead(link) {
        // @FIXME: better way to mark as read?
        for (var i=0; i < newsModel.count; i++) {
            var entry = newsModel.get(i);
            if (entry.link === link) {
                entry.read = true;
                break;
            }
        };
        //
    }

    BusyIndicator {
        anchors.centerIn: parent;
        running: feedModel.busy;
        size: BusyIndicatorSize.Large;
    }

    Label {
        visible: feedModel.busy;
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.bottom: parent.bottom;
        anchors.margins: constants.paddingMedium;
        horizontalAlignment: Text.AlignHCenter;
        font.pixelSize: constants.fontSizeMedium;
        color: constants.colorHighlight;
        truncationMode: TruncationMode.Fade;
        text: feedModel.currentlyLoading;
    }

}


