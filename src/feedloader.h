#ifndef FEEDLOADER_H
#define FEEDLOADER_H

#include <QList>
#include <QObject>
//#include <QSslError>
#include <QString>
#include <QUrl>

class QNetworkAccessManager;
class QNetworkReply;

class FeedLoader : public QObject {
    Q_OBJECT
    Q_ENUMS(FeedType)
    Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(FeedType type READ type NOTIFY dataChanged)
    Q_PROPERTY(QString data READ data NOTIFY dataChanged)
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)

    public:
        enum FeedType {
            RSS, Unknown
        };
        explicit FeedLoader(QObject* parent = 0);

    signals:
        void sourceChanged();
        void dataChanged();
        void loadingChanged();
        void success();
        void error(const QString& details);

    private:
        QUrl source() const { return feedSource; }
        void setSource(const QUrl& source);

        FeedType type() const;

        QString data() const { return feedData; }

        bool loading() const { return feedIsLoading; }

    private slots:
        void slotGotReply(QNetworkReply* reply);

    private:
        QNetworkAccessManager* myNetworkAccessManager;

        QUrl feedSource;
        QString feedData;
        bool feedIsLoading;
};

#endif // FEEDLOADER_H
