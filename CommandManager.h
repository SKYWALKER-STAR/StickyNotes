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
    QString group; // new: group name for grouping
    bool isFolder = false;
};

class CommandManager : public QAbstractListModel
{
    Q_OBJECT
public:
    enum CommandRoles {
        TitleRole = Qt::UserRole + 1,
        CommandRole,
        DescriptionRole,
        GroupRole,
        IsFolderRole
    };

    explicit CommandManager(QObject *parent = nullptr);

    // QAbstractListModel interface
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void addCommand(const QString &title, const QString &command, const QString &description, const QString &group = QString());
    Q_INVOKABLE void addFolder(const QString &title, const QString &group = QString());
    Q_INVOKABLE void editCommand(int index, const QString &title, const QString &command, const QString &description, const QString &group = QString());
    Q_INVOKABLE void editFolder(int index, const QString &title, const QString &group = QString());
    Q_INVOKABLE void removeCommand(int index);
    Q_INVOKABLE void copyToClipboard(const QString &text);
    Q_INVOKABLE void setFilter(const QString &filterText);
    Q_INVOKABLE void setGroupFilter(const QString &group);
    Q_INVOKABLE bool exportCommands(const QUrl &fileUrl);
    Q_INVOKABLE bool importCommands(const QUrl &fileUrl);
    Q_INVOKABLE QVariantList commandsInFolder(const QString &folderName) const;
    Q_INVOKABLE void initialize(); // Delayed initialization
    Q_INVOKABLE QStringList groups();
    Q_INVOKABLE void debug();

    Q_PROPERTY(QStringList groups READ groups NOTIFY groupsChanged)

    // Persistence
    void loadCommands();
    void saveCommands();

private:
    void updateFilteredCommands();

    QList<CommandEntry> m_allCommands;
    QList<CommandEntry> m_filteredCommands;
    QString m_filterText;
    QString m_groupFilter;
    QString m_storagePath;
    bool m_initialized = false;
signals:
    void groupsChanged();
    void commandsChanged();
};

#endif // COMMANDMANAGER_H
