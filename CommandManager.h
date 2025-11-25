#ifndef COMMANDMANAGER_H
#define COMMANDMANAGER_H

#include <QAbstractListModel>
#include <QList>
#include <QString>
#include <QObject>

struct CommandEntry {
    QString title;
    QString command;
    QString description;
};

class CommandManager : public QAbstractListModel
{
    Q_OBJECT
public:
    enum CommandRoles {
        TitleRole = Qt::UserRole + 1,
        CommandRole,
        DescriptionRole
    };

    explicit CommandManager(QObject *parent = nullptr);

    // QAbstractListModel interface
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void addCommand(const QString &title, const QString &command, const QString &description);
    Q_INVOKABLE void editCommand(int index, const QString &title, const QString &command, const QString &description);
    Q_INVOKABLE void removeCommand(int index);
    Q_INVOKABLE void copyToClipboard(const QString &text);
    Q_INVOKABLE void setFilter(const QString &filterText);
    Q_INVOKABLE bool exportCommands(const QUrl &fileUrl);
    Q_INVOKABLE bool importCommands(const QUrl &fileUrl);

    // Persistence
    void loadCommands();
    void saveCommands();

private:
    void updateFilteredCommands();

    QList<CommandEntry> m_allCommands;
    QList<CommandEntry> m_filteredCommands;
    QString m_filterText;
    QString m_storagePath;
};

#endif // COMMANDMANAGER_H
