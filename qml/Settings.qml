import QtQuick 2.1

QtObject {
    id: settings;

    signal settingsLoaded;

    onSettingsLoaded: {
        selectedSection = feeds_selected;
        selectedSectionName = feeds_selectedName;

        feedModel.refresh();
    }

    // Settings page
    property string feeds_selected : "blog";
    property string feeds_selectedName : qsTr("Blog");

    // feeds
    property var feeds : [
        { id: "blog", name: qsTr("Blog"), url: "http://www.jollausers.com/feed/", selected: true },
        { id: "forum", name: qsTr("Forum"), url: "http://forum.jollausers.com/.xml/?type=rss", selected: true },
    ];

    function loadFeedSettings() {
        sourcesModel.clear();
        feedSourceModel.clear();

        feedSourceModel.append(feeds)

        // Adding all feeds to sources
        for (var i=0; i < feedSourceModel.count; i++) {
            var entry = feedSourceModel.get(i);
            sourcesModel.addSource(entry.id, entry.name, entry.url);
        };

        //console.log(JSON.stringify(feeds));

        settingsLoaded();
    }

}
