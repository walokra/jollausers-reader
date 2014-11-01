import QtQuick 2.1
import QtQuick.XmlListModel 2.0

XmlListModel {
    query: "/rss/channel/item"
    namespaceDeclarations: "declare namespace content = 'http://purl.org/rss/1.0/modules/content/';" +
            "declare namespace slash = 'http://purl.org/rss/1.0/modules/slash/';" +
            "declare namespace wfw = 'http://wellformedweb.org/CommentAPI/';" +
            "declare namespace dc = 'http://purl.org/dc/elements/1.1/';";

    XmlRole { name: "uid"; query: "guid/string()" }
    XmlRole { name: "title"; query: "title/string()" }
    XmlRole { name: "link"; query: "link/string()" }
    XmlRole { name: "description"; query: "description/string()" }
    //XmlRole { name: "encoded"; query: "content:encoded/string()" }
    XmlRole { name: "dateString"; query: "pubDate/string()" }
    XmlRole { name: "commentsLink"; query: "comments/string()" }
    XmlRole { name: "creator"; query: "dc:creator/string()" }
    XmlRole { name: "commentsCount"; query: "slash:comments/string()" }
    XmlRole { name: "commentsRss"; query: "wfw:commentRss/string()" }
}
