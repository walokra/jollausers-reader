import QtQuick 2.1
import QtQuick.XmlListModel 2.0
import Sailfish.Silica 1.0
import harbour.jollausers 1.0

Item {
    id: wrapper;

    signal error(string details);

    property variant sources: [];

    // the time of the last refresh
    property variant lastRefresh;
    // section which was refreshed last
    property string lastSection;
    // seconds between refresh
    property int refreshTimeout: 30;

    // flag indicating that this model is busy
    property bool busy: false;

    // name of the feed currently loading
    property string currentlyLoading;

    // private list of items as JS dicts
    property var _items: [];

    property var allFeeds : [];

    property variant _models: [ _rssModel ];

    property var _sourcesQueue: [];

    property FeedLoader _feedLoader: FeedLoader {
        property string feedName;
        property string id;

        onSuccess: {
            switch (type) {
                case FeedLoader.RSS:
                    _rssModel.xml = "";
                    _rssModel.xml = data;
                    break;
                default:
                    _handleError("Unsupported feed format.");
                    break;
            }
        }

        onError: {
            console.debug("_feedLoader.onError");
            _handleError(details);
        }
    }

    property Timer _itemLoader: Timer {
        property variant model;
        property int index;

        function load(loadModel) {
            model = loadModel;
            index = 0;
            start();
        }

        interval: 75;
        repeat: true;

        onTriggered: {
            for (var end = index + 2; index < end && index < model.count; index++) {
                wrapper._loadItem(model, index);
                index++;
            }

            if (index >= model.count) {
                stop();

                var feed = { };
                feed["name"] = _feedLoader.name;
                feed["id"] = _feedLoader.id;
                feed["entries"] = _items;
                allFeeds.push(feed);
                //console.log("allFeeds=" + allFeeds.length);
                _items = [];

                _loadNext();
            }
        }
    }

    property RSSModel _rssModel: RSSModel {
        onStatusChanged: {
            if (status === XmlListModel.Error) {
                _handleError(errorString());
            } else if (status === XmlListModel.Ready) {
                _itemLoader.load(_rssModel);
            }
        }
    }

    /*
     * Clears and reloads the model from the current sources.
     */
    function refresh() {
        var refreshAllowed = true;
        if (lastRefresh) {
            var diff = new Date().getTime() - lastRefresh.getTime() // milliseconds
            diff = diff / 1000;
            if (diff < refreshTimeout && selectedSection === lastSection) {
                console.log("Timeout between refreshing same section is 30s. Last refresh was " + diff + " ago.");
                refreshAllowed = false;
            }
        }

        if (refreshAllowed) {
            busy = true;
            allFeeds = [];
            newsModel.clear();

            if (selectedSection === "") {
                selectedSection = "blog"
            }

            _sourcesQueue = [];
            sources.forEach(function(entry) {
                if (entry.id.toString() === selectedSection.toString()) {
                    _sourcesQueue.push(entry);
                }
            });

            _loadNext()
            lastRefresh = new Date()
            lastSection = selectedSection
        }
    }

    /* Aborts loading.
     */
    function abort() {
        _sourcesQueue = [];
        _itemLoader.stop();
        busy = false;
    }

    /*
     * Takes the next source from the sources queue and loads it.
     */
    function _loadNext() {
        var queue = _sourcesQueue;
        if (queue.length > 0) {
            var source = queue.pop();
            var name = source.name;
            var url = source.url;
            var id = source.id;

            console.log("Now loading : " + name);
            currentlyLoading = name;
            _feedLoader.feedName = name;
            _feedLoader.source = url;
            _feedLoader.id = id;

            _sourcesQueue = queue;
        } else {
            //console.debug("allFeeds[0].entries.length=" + allFeeds[0].entries.length);
            newsModel.append(allFeeds[0].entries);

            busy = false;
            currentlyLoading = "";
            //console.log("newsModel.count=" + newsModel.count);
        }
    }

    /*
     * Adds the item from the given model.
     */
    function _loadItem(model, i) {
        //console.debug("model=" + JSON.stringify(model.get(i)));
        var item = _createItem(model.get(i));

        _items.push(item);
    }

    function _createItem(obj) {
        var item = { };
        for (var key in obj) {
            //console.debug("obj["+key+"]=" + obj[key]);
            item[key] = obj[key];
        }
        item["read"] = false;

        return item;
    }

    function _handleError(error) {
        console.log(error);

        var feedName = currentlyLoading + "";
        if (error.substring(0, 5) === "Host ") {
            // Host ... not found
            newsModel.error(qsTr("Error with %1:\n%2").arg(feedName).arg(error));
        } else if (error.indexOf(" - server replied: ") !== -1) {
            var idx = error.indexOf(" - server replied: ");
            var reply = error.substring(idx + 19);
            newsModel.error(qsTr("Error with %1:\n%2").arg(feedName).arg(reply));
        } else {
            newsModel.error(qsTr("Error with %1:\n%2").arg(feedName).arg(error));
        }
        busy = false;
    }

}
