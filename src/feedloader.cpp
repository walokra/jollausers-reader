#include "feedloader.h"

#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QDomDocument>
#include <QDomElement>

#include <QDebug>

FeedLoader::FeedLoader(QObject* parent) : QObject(parent), myNetworkAccessManager(0), feedIsLoading(false) {
    myNetworkAccessManager = new QNetworkAccessManager(this);

    connect(myNetworkAccessManager, SIGNAL(finished(QNetworkReply*)), this, SLOT(slotGotReply(QNetworkReply*)));
}

void FeedLoader::setSource(const QUrl& source) {
    feedSource = source;
    emit sourceChanged();

    feedIsLoading = true;
    emit loadingChanged();

    feedData.clear();
    emit dataChanged();

    QNetworkRequest req(source);
    req.setRawHeader("User-Agent", QString("JollaUsers reader/%1 (Sailfish OS)").arg(APP_VERSION).toUtf8());

    qDebug() << "Requesting " << source << " as " << QString("JollaUsers reader/%1 (Sailfish OS)").arg(APP_VERSION).toUtf8();

    myNetworkAccessManager->get(req);
}

FeedLoader::FeedType FeedLoader::type() const {
    if (feedData.isEmpty()) {
        qDebug() << "feedData empty";
        return Unknown;
    } else {
        return RSS;
    }
}

void FeedLoader::slotGotReply(QNetworkReply* reply) {
    qDebug() << "Receiving"
             << reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt()
             << reply->request().url();
    qDebug() << reply->rawHeaderPairs();

    // handle redirections
    QVariant redirectUrl = reply->attribute(QNetworkRequest::RedirectionTargetAttribute);
    if (redirectUrl.isValid()) {
        QUrl currentLocation = reply->request().url();
        QUrl newLocation = redirectUrl.toUrl();
        if (newLocation.isRelative()) {
            newLocation = currentLocation.resolved(newLocation);
        }
        if (currentLocation != newLocation) {
            qDebug() << "Redirected to " << newLocation;
            QNetworkRequest req(newLocation);
            req.setRawHeader("User-Agent", QString("JollaUsers reader/%1 (Sailfish OS)")
                             .arg(APP_VERSION).toUtf8());
            myNetworkAccessManager->get(req);
        } else {
            qDebug() << "Redirection loop detected.";
            emit error("Redirection loop detected.");
            feedIsLoading = false;
            emit loadingChanged();
        }

        reply->deleteLater();
        return;
    }

    switch (reply->error()) {
        case QNetworkReply::NoError: {
            //qDebug() << "parsing now";

            qDebug() << "parsing now";
            // XmlListModel expects UTF-8 encoded data in its 'xml' property,
            // but still applies the XML document encoding, which is wrong,
            // so convert from encoding to UTF-8 here, and remove the 'encoding'
            // information

            // convert from encoding to UTF-8
            QDomDocument doc;
            doc.setContent(reply->readAll(), false);
            QString data = doc.toString();

            // remove <?xml ... ?> instructions
            if (data.startsWith("<?")) {
                int idx = data.indexOf("?>");
                if (idx != -1) {
                    data = data.mid(idx + 3);
                }
            }

            // force UTF-8 for encoding
            feedData = "<?xml version='1.0' encoding='UTF-8'?>" + data;
            qDebug() << feedData.size() << "bytes";
            //qDebug() << feedData.left(2048);
            emit dataChanged();
            emit success();
            break;
        }

        default:
            qDebug() << "Network Error" << reply->error() << reply->errorString();
            emit error(reply->errorString());
            break;
    }

    reply->deleteLater();
    feedIsLoading = false;
    emit loadingChanged();
}
