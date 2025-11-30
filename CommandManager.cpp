#include "CommandManager.h"
#include <QGuiApplication>
#include <QClipboard>
#include <QFile>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QStandardPaths>
#include <QDir>
#include <QSet>

CommandManager::CommandManager(QObject *parent)
    : QAbstractListModel(parent)
{
    // Set storage path only, defer loading for faster startup
    QString dataLocation = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dir(dataLocation);
    if (!dir.exists()) {
        dir.mkpath(".");
    }
    m_storagePath = dataLocation + "/commands.json";
    // Don't load commands here - will be loaded on demand or via initialize()
}

int CommandManager::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_filteredCommands.count();
}

QVariant CommandManager::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_filteredCommands.count())
        return QVariant();

    const CommandEntry &entry = m_filteredCommands[index.row()];

    switch (role) {
    case TitleRole:
        return entry.title;
    case CommandRole:
        return entry.command;
    case DescriptionRole:
        return entry.description;
    case GroupRole:
        return entry.group;
    case IsFolderRole:
        return entry.isFolder;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> CommandManager::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[TitleRole] = "title";
    roles[CommandRole] = "commandContent";
    roles[DescriptionRole] = "description";
    roles[GroupRole] = "group";
    roles[IsFolderRole] = "isFolder";
    return roles;
}

void CommandManager::addCommand(const QString &title, const QString &command, const QString &description, const QString &group)
{
    if (!m_initialized) {
        initialize();
    }
    printf("Hello world!\n");
    m_allCommands.append({title, command, description, group, false});
    saveCommands();
    updateFilteredCommands();
    emit groupsChanged();
}

void CommandManager::addFolder(const QString &title, const QString &group)
{
    if (!m_initialized) {
        initialize();
    }
    m_allCommands.append({title, QString(), QString(), group, true});
    saveCommands();
    updateFilteredCommands();
    emit groupsChanged();
}

void CommandManager::editCommand(int index, const QString &title, const QString &command, const QString &description, const QString &group)
{
    if (index < 0 || index >= m_filteredCommands.count())
        return;

    // Find the original command in m_allCommands
    const CommandEntry &currentEntry = m_filteredCommands[index];
    for (int i = 0; i < m_allCommands.count(); ++i) {
        if (m_allCommands[i].title == currentEntry.title && 
            m_allCommands[i].command == currentEntry.command &&
            m_allCommands[i].description == currentEntry.description) {
            m_allCommands[i] = {title, command, description, group, false};
            break;
        }
    }
    
    saveCommands();
    updateFilteredCommands();
    emit groupsChanged();
}

void CommandManager::editFolder(int index, const QString &title, const QString &group)
{
    if (index < 0 || index >= m_filteredCommands.count())
        return;

    const CommandEntry &currentEntry = m_filteredCommands[index];
    for (int i = 0; i < m_allCommands.count(); ++i) {
        if (m_allCommands[i].title == currentEntry.title &&
            m_allCommands[i].command == currentEntry.command &&
            m_allCommands[i].description == currentEntry.description &&
            m_allCommands[i].isFolder == currentEntry.isFolder) {
            m_allCommands[i] = {title, QString(), QString(), group, true};
            break;
        }
    }

    saveCommands();
    updateFilteredCommands();
    emit groupsChanged();
}

void CommandManager::removeCommand(int index)
{
    if (index < 0 || index >= m_filteredCommands.count())
        return;

    // Find and remove from m_allCommands
    const CommandEntry &currentEntry = m_filteredCommands[index];
    for (int i = 0; i < m_allCommands.count(); ++i) {
        if (m_allCommands[i].title == currentEntry.title && 
            m_allCommands[i].command == currentEntry.command &&
            m_allCommands[i].description == currentEntry.description) {
            
            m_allCommands.removeAt(i);
            break;
        }
    }

    saveCommands();
    updateFilteredCommands();
    emit groupsChanged();
}

void CommandManager::copyToClipboard(const QString &text)
{
    QClipboard *clipboard = QGuiApplication::clipboard();
    if (clipboard) {
        clipboard->setText(text);
    }
}

void CommandManager::setFilter(const QString &filterText)
{
    // Ensure data is loaded before filtering
    if (!m_initialized) {
        initialize();
    }
    
    if (m_filterText == filterText)
        return;
    
    m_filterText = filterText;
    updateFilteredCommands();
}

void CommandManager::setGroupFilter(const QString &group)
{
    if (!m_initialized) {
        initialize();
    }
    if (m_groupFilter == group)
        return;
    m_groupFilter = group;
    updateFilteredCommands();
}

void CommandManager::initialize()
{
    if (m_initialized)
        return;
    
    m_initialized = true;
    loadCommands();
}

void CommandManager::updateFilteredCommands()
{
    beginResetModel();
    m_filteredCommands.clear();
    
    for (const auto &entry : m_allCommands) {
        // Group filter
        if (!m_groupFilter.isEmpty() && m_groupFilter != "All" && entry.group != m_groupFilter)
            continue;

        // Text filter
        if (m_filterText.isEmpty() ||
            entry.title.contains(m_filterText, Qt::CaseInsensitive) ||
            entry.command.contains(m_filterText, Qt::CaseInsensitive) ||
            entry.description.contains(m_filterText, Qt::CaseInsensitive)) {
            m_filteredCommands.append(entry);
        }
    }
    endResetModel();
}

void CommandManager::loadCommands()
{
    QFile file(m_storagePath);
    if (!file.open(QIODevice::ReadOnly))
        return;

    QByteArray data = file.readAll();
    QJsonDocument doc = QJsonDocument::fromJson(data);
    QJsonArray array = doc.array();

    m_allCommands.clear();
    for (const QJsonValue &val : array) {
        QJsonObject obj = val.toObject();
        m_allCommands.append({
            obj["title"].toString(),
            obj["command"].toString(),
            obj["description"].toString(),
            obj["group"].toString(),
            obj["isFolder"].toBool(false)
        });
    }
    updateFilteredCommands();
    emit groupsChanged();
}

void CommandManager::saveCommands()
{
    QJsonArray array;
    for (const auto &entry : m_allCommands) {
        QJsonObject obj;
        obj["title"] = entry.title;
        obj["command"] = entry.command;
        obj["description"] = entry.description;
        obj["group"] = entry.group;
        obj["isFolder"] = entry.isFolder;
        array.append(obj);
    }

    QJsonDocument doc(array);
    QFile file(m_storagePath);
    if (file.open(QIODevice::WriteOnly)) {
        file.write(doc.toJson());
    }
}

bool CommandManager::exportCommands(const QUrl &fileUrl)
{
    if (!m_initialized) {
        initialize();
    }
    
    QString filePath = fileUrl.toLocalFile();
    if (filePath.isEmpty())
        return false;

    QJsonArray array;
    for (const auto &entry : m_allCommands) {
        QJsonObject obj;
        obj["title"] = entry.title;
        obj["command"] = entry.command;
        obj["description"] = entry.description;
        obj["group"] = entry.group;
        obj["isFolder"] = entry.isFolder;
        array.append(obj);
    }

    QJsonDocument doc(array);
    QFile file(filePath);
    if (file.open(QIODevice::WriteOnly)) {
        file.write(doc.toJson());
        return true;
    }
    return false;
}

bool CommandManager::importCommands(const QUrl &fileUrl)
{
    QString filePath = fileUrl.toLocalFile();
    if (filePath.isEmpty())
        return false;

    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly))
        return false;

    QByteArray data = file.readAll();
    QJsonDocument doc = QJsonDocument::fromJson(data);
    if (!doc.isArray())
        return false;

    QJsonArray array = doc.array();
    
    // Merge strategy: Append imported commands
    // Alternatively, we could clear m_allCommands first. 
    // Here we append to avoid data loss.
    for (const QJsonValue &val : array) {
        QJsonObject obj = val.toObject();
        m_allCommands.append({
            obj["title"].toString(),
            obj["command"].toString(),
            obj["description"].toString(),
            obj["group"].toString(),
            obj["isFolder"].toBool(false)
        });
    }
    
    saveCommands();
    updateFilteredCommands();
    emit groupsChanged();
    return true;
}

QStringList CommandManager::groups()
{
    if (!m_initialized) initialize();
    QSet<QString> set;
    set.insert("All");
    for (const auto &e : m_allCommands) {
        if (!e.group.isEmpty()) set.insert(e.group);
    }
    QStringList list;
    for (const QString &group : set)
        list.append(group);
    list.sort(Qt::CaseInsensitive);
    list.removeAll("All");
    list.prepend("All");
    return list;
}
