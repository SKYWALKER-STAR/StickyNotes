#include "include/CommandManager.h"
#include <QDebug>
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

    // Default empty group to "All" to ensure consistent grouping
    QString finalGroup = group.trimmed().isEmpty() ? QStringLiteral("All") : group.trimmed();
    m_allCommands.append({title, command, description, finalGroup, false});
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
    QString finalGroup = group.trimmed().isEmpty() ? QStringLiteral("All") : group.trimmed();
    for (int i = 0; i < m_allCommands.count(); ++i) {
        if (m_allCommands[i].title == currentEntry.title && 
            m_allCommands[i].command == currentEntry.command &&
            m_allCommands[i].description == currentEntry.description) {
            m_allCommands[i] = {title, command, description, finalGroup, false};
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
QVariantList CommandManager::commandsInFolder(const QString &folderName) const {
    QVariantList out;
    for (const auto &c : m_filteredCommands) {
        if (!c.isFolder && c.group == folderName) {
            QVariantMap m;
            m["title"] = c.title;
            m["commandContent"] = c.command;
            m["description"] = c.description;
            m["group"] = c.group;
            m["isFolder"] = false;
            int filteredIdx = -1;
            for (int fi = 0; fi < m_filteredCommands.size(); ++fi) {
                const auto &f = m_filteredCommands[fi];
                if (f.title == c.title && f.command == c.command && f.description == c.description && f.group == c.group && f.isFolder == c.isFolder) {
                    filteredIdx = fi;
                    break;
                }
            }
            m["sourceIndex"] = filteredIdx;
            out << m;
        }
    }
    return out;
}

QVariantList CommandManager::foldersInFolder(const QString &parentGroup) const {
    QVariantList out;
    for (const auto &c : m_filteredCommands) {
        if (c.isFolder && c.group == parentGroup) {
            QVariantMap m;
            m["title"] = c.title;
            m["group"] = c.group;
            m["isFolder"] = true;
            out << m;
        }
    }
    return out;
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

void CommandManager::renameFolder(const QString &oldTitle, const QString &newTitle)
{
    if (!m_initialized) {
        initialize();
    }

    const QString oldName = oldTitle.trimmed();
    const QString newName = newTitle.trimmed();

    if (oldName.isEmpty() || newName.isEmpty() || oldName == QStringLiteral("All") || oldName == newName)
        return;

    bool changed = false;
    for (auto &entry : m_allCommands) {
        if (entry.isFolder && entry.title == oldName) {
            entry.title = newName;
            changed = true;
        }
        if (!entry.isFolder && entry.group == oldName) {
            entry.group = newName;
            changed = true;
        }
        if (entry.isFolder && entry.group == oldName) {
            entry.group = newName;
            changed = true;
        }
    }

    if (!changed)
        return;

    saveCommands();
    updateFilteredCommands();
    emit groupsChanged();
}

void CommandManager::removeFolder(const QString &folderTitle, bool deleteCommands)
{
    if (!m_initialized) {
        initialize();
    }

    const QString folderName = folderTitle.trimmed();
    if (folderName.isEmpty() || folderName == QStringLiteral("All"))
        return;

    // Collect all descendant folder names recursively
    QStringList toRemove;
    toRemove << folderName;
    bool found = true;
    while (found) {
        found = false;
        for (const auto &entry : m_allCommands) {
            if (entry.isFolder && toRemove.contains(entry.group) && !toRemove.contains(entry.title)) {
                toRemove << entry.title;
                found = true;
            }
        }
    }

    bool changed = false;
    for (int i = m_allCommands.count() - 1; i >= 0; --i) {
        const auto &entry = m_allCommands[i];

        // Remove folder entries in the subtree
        if (entry.isFolder && toRemove.contains(entry.title)) {
            m_allCommands.removeAt(i);
            changed = true;
            continue;
        }

        // Handle commands belonging to any folder in the subtree
        if (!entry.isFolder && toRemove.contains(entry.group)) {
            if (deleteCommands) {
                m_allCommands.removeAt(i);
            } else {
                m_allCommands[i].group = QStringLiteral("All");
            }
            changed = true;
        }
    }

    if (!changed)
        return;

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
    
    if (m_filterText == filterText) {
        qDebug() << "Setting filter From inner:" << filterText;
        return;
    }
        
    qDebug() << "Setting filter:" << filterText;
    
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
    qDebug() << "CommandManager initialized.";
}

void CommandManager::updateFilteredCommands()
{
    beginResetModel();
    m_filteredCommands.clear();
    
    for (const auto &entry : m_allCommands) {
        // Group filter
        //if (!m_groupFilter.isEmpty() && m_groupFilter != "All" && entry.group != m_groupFilter)
           //continue;
        // Text filter
        if (m_filterText.isEmpty() ||
            entry.title.contains(m_filterText, Qt::CaseInsensitive) ||
            entry.command.contains(m_filterText, Qt::CaseInsensitive) ||
            entry.description.contains(m_filterText, Qt::CaseInsensitive) ||
            entry.isFolder) {
            qDebug() << "Match found:" << entry.title;
            m_filteredCommands.append(entry);
        }
    }
    endResetModel();
    qDebug() << "updateFilteredCommands finished. Count:" << m_filteredCommands.count();
    qDebug() << "Filtered Commands List:";
    for (const auto &entry : m_filteredCommands) {
        qDebug() << "  Title:" << entry.title 
                << " Command:" << entry.command 
                << " Group:" << entry.group
                << " IsFolder:" << entry.isFolder;
}
    emit commandsChanged();
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

    //Debug
    //for (const CommandEntry &e : m_allCommands) {
    //    qDebug() << "CommandEntry:" << e.title << e.group << e.isFolder;
    //}
    QSet<QString> set;
    set.insert("All");
    for (const auto &e : m_allCommands) {
        if (e.isFolder) {
            set.insert(e.title);
        }
        else if (!e.group.isEmpty()) {
            set.insert(e.group);
        }
    }
    QStringList list;
    for (const QString &group : set)
        list.append(group);
    list.sort(Qt::CaseInsensitive);
    list.removeAll("All");
    list.prepend("All");
    // Debug
    //qDebug() << "groups:" << list;                          // 方式1
    return list;
}

void CommandManager::debug()
{
    qDebug() << "Debug information:";
}
