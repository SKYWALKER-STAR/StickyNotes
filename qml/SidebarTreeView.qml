import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts
import CommandManager 1.0

Rectangle {
    id: sidebar

    // 继承主题变量
    property color bgColor: "#fafafa"
    property color cardColor: "#ffffff"
    property color subtleBorder: "#e5e5e5"
    property color primary: "#171717"
    property color primaryDark: "#000000"
    property color accent: "#525252"
    property color textPrimary: "#0a0a0a"
    property color textSecondary: "#737373"
    property color hoverColor: "#f0f0f0"
    property color selectedColor: "#e8e8e8"

    // 当前选中的分组
    property string selectedGroup: "All"

    // 数据模型
    property var commandManager: null

    // 外部依赖（可选）
    property var commandDialog: null
    property var previewWin: null

    // 信号
    signal groupSelected(string groupName)
    signal itemClicked(int index, bool isFolder, string cmd)

    CreateOptionView {
        id: createOptionView
        onAddFolderRequested: function(groupName) {
            if (commandGroupView && typeof commandGroupView.openForAddFolderInGroup === 'function') {
                commandGroupView.openForAddFolderInGroup(groupName)
            } else if (commandGroupView && typeof commandGroupView.openForAddFolder === 'function') {
                commandGroupView.openForAddFolder()
            }
        }
        onAddCommandRequested: function(groupName) {
            if (sidebar.commandDialog && typeof sidebar.commandDialog.openForAddInGroup === 'function') {
                sidebar.commandDialog.openForAddInGroup(groupName)
            } else if (sidebar.commandDialog && typeof sidebar.commandDialog.openForAdd === 'function') {
                sidebar.commandDialog.openForAdd()
            }
        }
    }

    ContextMenuView {
        id: contextMenuView
        defaultGroupName: sidebar.selectedGroup

        onAddCommandRequested: function(groupName) {
            if (sidebar.commandDialog && typeof sidebar.commandDialog.openForAddInGroup === 'function') {
                sidebar.commandDialog.openForAddInGroup(groupName)
            } else if (sidebar.commandDialog && typeof sidebar.commandDialog.openForAdd === 'function') {
                sidebar.commandDialog.openForAdd()
            }
        }
        onAddFolderRequested: function(groupName) {
            if (commandGroupView && typeof commandGroupView.openForAddFolderInGroup === 'function') {
                commandGroupView.openForAddFolderInGroup(groupName)
            } else if (commandGroupView && typeof commandGroupView.openForAddFolder === 'function') {
                commandGroupView.openForAddFolder()
            }
        }
        onViewRequested: function(item) {
            if (!item) return
            if (item.isFolder) {
                sidebar.selectedGroup = item.name
                sidebar.groupSelected(item.name)
                return
            }
            if (item.parentGroup) {
                sidebar.selectedGroup = item.parentGroup
                sidebar.groupSelected(item.parentGroup)
            }
            if (sidebar.previewWin && typeof sidebar.previewWin.openWith === 'function') {
                sidebar.previewWin.openWith(item.name, item.command)
            } else if (sidebar.commandManager && item.command) {
                sidebar.commandManager.copyToClipboard(item.command)
                sidebar.itemClicked(item.index, false, item.command)
            }
        }
        onEditRequested: function(item) {
            if (!item) return
            if (item.isFolder) {
                folderRenameDialog.oldName = item.name
                folderRenameField.text = item.name
                folderRenameDialog.open()
                return
            }
            if (sidebar.commandDialog && typeof sidebar.commandDialog.openForEdit === 'function') {
                sidebar.commandDialog.openForEdit(item.index, item.name, item.command, item.description || "", item.parentGroup || "", false)
            }
        }
        onDeleteRequested: function(item) {
            if (!item) return
            if (item.isFolder) {
                folderDeleteDialog.folderName = item.name
                folderDeleteDialog.open()
                return
            }
            if (sidebar.commandManager && typeof sidebar.commandManager.removeCommand === 'function') {
                sidebar.commandManager.removeCommand(item.index)
            }
        }
    }

    Dialog {
        id: folderRenameDialog
        title: "重命名分组"
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel

        property string oldName: ""

        contentItem: ColumnLayout {
            spacing: 10
            Label {
                text: "新名称"
                font.pixelSize: 12
                color: sidebar.textSecondary
            }

            TextField {
                id: folderRenameField
                Layout.fillWidth: true
                placeholderText: "请输入分组名称"
            }
        }

        onAccepted: {
            if (!sidebar.commandManager || typeof sidebar.commandManager.renameFolder !== 'function') return
            sidebar.commandManager.renameFolder(oldName, folderRenameField.text)
        }
    }

    Popup {
        id: folderDeleteDialog
        modal: true
        focus: true
        padding: 0
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        parent: Overlay.overlay
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
        width: 380
        height: 220

        property string folderName: ""

        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 120; easing.type: Easing.OutCubic }
            NumberAnimation { property: "scale"; from: 0.96; to: 1.0; duration: 140; easing.type: Easing.OutCubic }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 100; easing.type: Easing.InCubic }
            NumberAnimation { property: "scale"; from: 1.0; to: 0.96; duration: 100; easing.type: Easing.InCubic }
        }

        background: Rectangle {
            radius: 12
            color: "#ffffff"
            border.color: "#E5E7EB"
            border.width: 1
        }

        contentItem: ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            // 警告图标 + 标题
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                Rectangle {
                    width: 36; height: 36; radius: 18
                    color: "#FEF2F2"
                    Label {
                        anchors.centerIn: parent
                        text: "⚠"
                        font.pixelSize: 18
                    }
                }
                Label {
                    text: "删除分组"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#111827"
                    Layout.fillWidth: true
                }
            }

            // 描述
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                Label {
                    text: "确定删除分组  \"" + folderDeleteDialog.folderName + "\"  ？"
                    font.pixelSize: 14
                    color: "#111827"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
                Label {
                    text: "该分组下的所有命令将被移动到 All 分组。"
                    font.pixelSize: 12
                    color: "#6B7280"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }

            Item { Layout.fillHeight: true }

            // 操作按钮
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                Item { Layout.fillWidth: true }
                Button {
                    id: cancelDeleteBtn
                    text: "取消"
                    flat: true
                    implicitHeight: 36
                    implicitWidth: 88
                    font.pixelSize: 13
                    font.bold: true
                    background: Rectangle {
                        radius: 8
                        color: cancelDeleteBtn.pressed ? "#E5E7EB" : (cancelDeleteBtn.hovered ? "#F3F4F6" : "#F8FAFC")
                        border.color: "#E2E8F0"
                    }
                    contentItem: Label {
                        text: cancelDeleteBtn.text
                        color: "#111827"
                        font: cancelDeleteBtn.font
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: folderDeleteDialog.close()
                }
                Button {
                    id: confirmDeleteBtn
                    text: "删除"
                    flat: true
                    implicitHeight: 36
                    implicitWidth: 88
                    font.pixelSize: 13
                    font.bold: true
                    background: Rectangle {
                        radius: 8
                        color: confirmDeleteBtn.pressed ? "#991B1B" : (confirmDeleteBtn.hovered ? "#B91C1C" : "#DC2626")
                        border.color: "#DC2626"
                    }
                    contentItem: Label {
                        text: confirmDeleteBtn.text
                        color: "#FFFFFF"
                        font: confirmDeleteBtn.font
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        if (sidebar.commandManager && typeof sidebar.commandManager.removeFolder === 'function') {
                            sidebar.commandManager.removeFolder(folderDeleteDialog.folderName, false)
                        }
                        folderDeleteDialog.close()
                    }
                }
            }
        }
    }
    
    // 当 commandManager 变化时刷新
    onCommandManagerChanged: {
        if (commandManager) {
            treeList.model = treeList.buildTreeModel()
        }
    }
    
    color: bgColor
    
    // 左边框线
    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 1
        color: subtleBorder
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0
        
        // 顶部操作区：新建按钮 + 搜索栏（对齐为一个整体）
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            color: "transparent"
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 6
                ToolButton {
                    id: addRootBtn
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    contentItem: Label {
                        text: "+"
                        font.pixelSize: 18
                        color: textSecondary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        radius: 6
                        color: addRootBtn.pressed ? selectedColor : (addRootBtn.hovered ? hoverColor : "transparent")
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: "新建目录/命令"
                    ToolTip.delay: 400
                    onClicked: {
                        createOptionView.openFor("All")
                    }
                }
                TextField {
                    id: searchField
                    placeholderText: "搜索目录或命令"
                    font.pixelSize: 13
                    Layout.fillWidth: true
                    leftPadding: 8
                    rightPadding: 8
                    height: 32
                    background: Rectangle {
                        radius: 6
                        color: "#f4f4f4"
                        border.color: sidebar.subtleBorder
                    }
                    onTextChanged: {
                        treeList.model = treeList.buildTreeModel(searchField.text)
                    }
                }
            }
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: subtleBorder
            }
        }
        
        // 树形列表
        ListView {
            id: treeList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 2
            
            model: []  // 初始为空，等待 commandManager 加载

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                propagateComposedEvents: true
                onPressed: function(mouse) {
                    if (mouse.button !== Qt.RightButton) return
                    var idx = treeList.indexAt(mouse.x, mouse.y)
                    if (idx !== -1) {
                        mouse.accepted = false
                        return
                    }

                    // Menu.popup(x,y) expects coordinates in its parent's coordinate space.
                    var p = treeList.mapToItem(contextMenuView.parent, mouse.x, mouse.y)
                    contextMenuView.openFor(null, p.x, p.y)
                    mouse.accepted = true
                }
            }
            
            Component.onCompleted: {
                console.log("SidebarTreeView ListView completed")
                // 延迟一下，等待 commandManager 初始化
                refreshTimer.start()
            }
            
            // 延迟刷新定时器
            Timer {
                id: refreshTimer
                interval: 100
                repeat: false
                onTriggered: {
                    if (commandManager) {
                        console.log("SidebarTreeView: refreshing with commandManager")
                        treeList.model = treeList.buildTreeModel()
                    } else {
                        console.log("SidebarTreeView: commandManager still null, retry")
                        refreshTimer.start()
                    }
                }
            }
            
            // 监听数据变化
            Connections {
                target: commandManager
                function onCommandsChanged() {
                    treeList.model = treeList.buildTreeModel()
                }
                function onGroupsChanged() {
                    treeList.model = treeList.buildTreeModel()
                }
            }
            
            function buildTreeModel(filterText) {
                if (!commandManager) {
                    console.log("SidebarTreeView: commandManager is null")
                    return []
                }
                var result = []
                var filter = (filterText || "").toLowerCase()
                var addedCmdKeys = {} // 防止重复添加命令

                // 递归构建子树
                // level: 子文件夹显示的层级，命令显示在 level+1
                function addFolderChildren(parentName, level) {
                    var subFolders = commandManager.foldersInFolder(parentName) || []
                    for (var i = 0; i < subFolders.length; i++) {
                        var folder = subFolders[i]
                        var folderName = folder.title
                        var folderMatch = !filter || folderName.toLowerCase().indexOf(filter) !== -1

                        // 该文件夹下的直属命令
                        var cmds = commandManager.commandsInFolder(folderName) || []
                        var filteredCmds = []
                        for (var j = 0; j < cmds.length; j++) {
                            var cmd = cmds[j]
                            if (!filter || cmd.title.toLowerCase().indexOf(filter) !== -1 || folderMatch) {
                                filteredCmds.push(cmd)
                            }
                        }

                        // 检查子文件夹是否有匹配（决定是否显示此文件夹）
                        var subSubFolders = commandManager.foldersInFolder(folderName) || []
                        var hasDescendantMatch = folderMatch || filteredCmds.length > 0
                        if (!hasDescendantMatch && filter) {
                            for (var df = 0; df < subSubFolders.length; df++) {
                                if (subSubFolders[df].title.toLowerCase().indexOf(filter) !== -1) {
                                    hasDescendantMatch = true
                                    break
                                }
                                var deepCmds = commandManager.commandsInFolder(subSubFolders[df].title) || []
                                for (var dc = 0; dc < deepCmds.length; dc++) {
                                    if (deepCmds[dc].title.toLowerCase().indexOf(filter) !== -1) {
                                        hasDescendantMatch = true
                                        break
                                    }
                                }
                                if (hasDescendantMatch) break
                            }
                        }

                        if (!filter || hasDescendantMatch) {
                            result.push({
                                name: folderName,
                                displayName: folderName,
                                icon: "📂",
                                isFolder: true,
                                level: level,
                                expanded: false,
                                childCount: filteredCmds.length + subSubFolders.length,
                                parentGroup: parentName || "All",
                                index: -1
                            })

                            // 递归添加子目录
                            addFolderChildren(folderName, level + 1)

                            // 添加该文件夹下的命令
                            for (var k = 0; k < filteredCmds.length; k++) {
                                var c = filteredCmds[k]
                                var cKey = folderName + "|" + c.sourceIndex
                                if (!addedCmdKeys[cKey]) {
                                    addedCmdKeys[cKey] = true
                                    result.push({
                                        name: c.title,
                                        displayName: c.title,
                                        icon: "📄",
                                        isFolder: false,
                                        level: level + 1,
                                        expanded: false,
                                        childCount: 0,
                                        parentGroup: folderName,
                                        index: c.sourceIndex,
                                        command: c.commandContent,
                                        description: c.description || ""
                                    })
                                }
                            }
                        }
                    }
                }

                // 计算根级别信息
                var rootFolders = commandManager.foldersInFolder("") || []
                var allFolders = commandManager.foldersInFolder("All") || []
                var rootCmdsAll = commandManager.commandsInFolder("All") || []
                var rootCmdsEmpty = commandManager.commandsInFolder("") || []
                var totalRootChildren = rootFolders.length + allFolders.length
                for (var ra = 0; ra < rootCmdsAll.length; ra++) {
                    if (!filter || rootCmdsAll[ra].title.toLowerCase().indexOf(filter) !== -1)
                        totalRootChildren++
                }
                for (var re = 0; re < rootCmdsEmpty.length; re++) {
                    if (!filter || rootCmdsEmpty[re].title.toLowerCase().indexOf(filter) !== -1)
                        totalRootChildren++
                }

                // "全部" 虚拟根节点
                result.push({
                    name: "All",
                    displayName: "全部命令",
                    icon: "🏠",
                    isFolder: true,
                    level: 0,
                    expanded: true,
                    childCount: totalRootChildren,
                    parentGroup: "",
                    index: -1
                })

                // 添加根级别文件夹及其子树 (group == "")
                addFolderChildren("", 1)
                // 添加根级别文件夹及其子树 (group == "All")
                addFolderChildren("All", 1)

                // 添加根级别命令（group == "All" 或 group == ""）
                var allRootCmds = rootCmdsAll.concat(rootCmdsEmpty)
                for (var r = 0; r < allRootCmds.length; r++) {
                    var rc = allRootCmds[r]
                    if (filter && rc.title.toLowerCase().indexOf(filter) === -1) continue
                    var rcKey = (rc.group || "All") + "|" + rc.sourceIndex
                    if (!addedCmdKeys[rcKey]) {
                        addedCmdKeys[rcKey] = true
                        result.push({
                            name: rc.title,
                            displayName: rc.title,
                            icon: "📄",
                            isFolder: false,
                            level: 1,
                            expanded: false,
                            childCount: 0,
                            parentGroup: "All",
                            index: rc.sourceIndex,
                            command: rc.commandContent,
                            description: rc.description || ""
                        })
                    }
                }

                console.log("SidebarTreeView: buildTreeModel result count =", result.length)
                return result
            }
            
            delegate: ItemDelegate {
                id: treeItem
                width: ListView.view ? ListView.view.width : 0
                
                property bool isSelected: modelData.isFolder && modelData.name === selectedGroup
                property bool isExpanded: modelData.expanded || false
                property int itemLevel: modelData.level || 0
                
                // 只显示顶级项目，或者所有祖先都展开的子项
                visible: {
                    if (itemLevel === 0) return true
                    // 检查所有祖先是否都展开
                    var view = ListView.view
                    if (!view || !view.model) return false
                    var parentName = modelData.parentGroup
                    while (parentName && parentName !== "") {
                        var found = false
                        for (var i = 0; i < view.model.length; i++) {
                            var item = view.model[i]
                            if (item.isFolder && item.name === parentName) {
                                if (!item.expanded) return false
                                parentName = item.parentGroup || ""
                                found = true
                                break
                            }
                        }
                        if (!found) return false
                    }
                    return true
                }
                height: visible ? 36 : 0
                
                background: Rectangle {
                    color: {
                        if (isSelected) return selectedColor
                        if (treeItem.hovered) return hoverColor
                        return "transparent"
                    }
                    radius: 6
                    
                    // 左侧选中指示器
                    Rectangle {
                        visible: isSelected
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: 3
                        height: parent.height - 12
                        radius: 2
                        color: primary
                    }
                }
                
                contentItem: RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12 + (itemLevel * 20)
                    anchors.rightMargin: 8
                    spacing: 8
                    // 展开/收起箭头（仅文件夹且有子项）
                    Label {
                        text: {
                            if (!modelData.isFolder || modelData.name === "All") return ""
                            if (modelData.childCount === 0) return ""
                            return modelData.expanded ? "▼" : "▶"
                        }
                        font.pixelSize: 8
                        color: textSecondary
                        Layout.preferredWidth: modelData.isFolder && modelData.childCount > 0 ? 12 : 0
                        visible: modelData.isFolder && modelData.childCount > 0
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -4
                            onClicked: {
                                // 切换展开状态
                                var view = ListView.view
                                if (!view || !view.model) return
                                var newModel = view.model.slice()
                                for (var i = 0; i < newModel.length; i++) {
                                    if (newModel[i].name === modelData.name && newModel[i].isFolder) {
                                        newModel[i].expanded = !newModel[i].expanded
                                        break
                                    }
                                }
                                view.model = newModel
                            }
                        }
                    }
                    // 图标
                    Label {
                        text: modelData.icon || "📄"
                        font.pixelSize: 14
                        Layout.preferredWidth: 20
                    }
                    // 名称
                    Label {
                        text: modelData.displayName || ""
                        font.pixelSize: 13
                        font.bold: modelData.isFolder && itemLevel === 0
                        color: isSelected ? primaryDark : textPrimary
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    // 子项数量标签（仅文件夹）
                    Rectangle {
                        visible: modelData.isFolder && modelData.childCount > 0
                        Layout.preferredWidth: visible ? countLabel.implicitWidth + 12 : 0
                        Layout.preferredHeight: 18
                        radius: 9
                        color: isSelected ? primary : "#e5e5e5"
                        Label {
                            id: countLabel
                            anchors.centerIn: parent
                            text: modelData.childCount || ""
                            font.pixelSize: 10
                            font.bold: true
                            color: isSelected ? "white" : textSecondary
                        }
                    }
                    // 右侧 + 号按钮（仅文件夹）
                    ToolButton {
                        visible: modelData.isFolder
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                        contentItem: Label {
                            text: "+"
                            font.pixelSize: 16
                            color: textSecondary
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            radius: 6
                            color: parent.pressed ? selectedColor : (parent.hovered ? hoverColor : "transparent")
                        }
                        ToolTip.visible: hovered
                        ToolTip.text: "新增目录/命令"
                        ToolTip.delay: 400
                        onClicked: {
                            createOptionView.openFor(modelData.name)
                        }
                    }
                }
                
                onClicked: {
                    if (modelData.isFolder) {
                        selectedGroup = modelData.name
                        groupSelected(modelData.name)
                        
                        // 如果有子项，同时切换展开状态
                        if (modelData.childCount > 0) {
                            var view = ListView.view
                            if (!view || !view.model) return
                            var newModel = view.model.slice()
                            for (var i = 0; i < newModel.length; i++) {
                                if (newModel[i].name === modelData.name && newModel[i].isFolder) {
                                    newModel[i].expanded = !newModel[i].expanded
                                    break
                                }
                            }
                            view.model = newModel
                        }
                    } else {
                        // 点击命令项：先选中其父分组并展开，再触发复制
                        if (modelData.parentGroup && selectedGroup !== modelData.parentGroup) {
                            selectedGroup = modelData.parentGroup
                            groupSelected(modelData.parentGroup)
                        } else if (modelData.parentGroup) {
                            // 即使同分组也触发一次，确保主区域刷新到该 folder 的完整内容
                            groupSelected(modelData.parentGroup)
                        }

                        if (modelData.parentGroup) {
                            var view2 = ListView.view
                            if (!view2 || !view2.model) return
                            var newModel2 = view2.model.slice()
                            for (var k = 0; k < newModel2.length; k++) {
                                if (newModel2[k].isFolder && newModel2[k].name === modelData.parentGroup) {
                                    newModel2[k].expanded = true
                                    break
                                }
                            }
                            view2.model = newModel2
                        }

                        if (commandManager && modelData.command) {
                            commandManager.copyToClipboard(modelData.command)
                            itemClicked(modelData.index, false, modelData.command)
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton
                    propagateComposedEvents: true
                    onPressed: function(mouse) {
                        if (mouse.button !== Qt.RightButton) return
                        // Menu.popup(x,y) expects coordinates in its parent's coordinate space.
                        var p = treeItem.mapToItem(contextMenuView.parent, mouse.x, mouse.y)
                        contextMenuView.openFor(modelData, p.x, p.y)
                        mouse.accepted = true
                    }
                }
                
                // 悬停动画
                scale: hovered ? 1.01 : 1.0
                Behavior on scale {
                    NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
                }
            }
            
            // 滚动条
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                width: 6
                
                contentItem: Rectangle {
                    implicitWidth: 6
                    radius: 3
                    color: parent.pressed ? accent : (parent.hovered ? textSecondary : subtleBorder)
                    opacity: parent.active ? 1 : 0.5
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                }
            }
        }
        
        // 底部区域 - 快捷操作
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: subtleBorder
        }
        
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            color: "transparent"
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8
                
                // 收起所有
                ToolButton {
                    id: collapseBtn
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    
                    contentItem: Label {
                        text: "⊟"
                        font.pixelSize: 14
                        color: textSecondary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    background: Rectangle {
                        radius: 6
                        color: collapseBtn.pressed ? selectedColor : (collapseBtn.hovered ? hoverColor : "transparent")
                    }
                    
                    ToolTip.visible: hovered
                    ToolTip.text: "收起全部"
                    ToolTip.delay: 500
                    
                    onClicked: {
                        var newModel = treeList.model.slice()
                        for (var i = 0; i < newModel.length; i++) {
                            if (newModel[i].isFolder) {
                                newModel[i].expanded = false
                            }
                        }
                        treeList.model = newModel
                    }
                }
                
                // 展开所有
                ToolButton {
                    id: expandBtn
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    
                    contentItem: Label {
                        text: "⊞"
                        font.pixelSize: 14
                        color: textSecondary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    background: Rectangle {
                        radius: 6
                        color: expandBtn.pressed ? selectedColor : (expandBtn.hovered ? hoverColor : "transparent")
                    }
                    
                    ToolTip.visible: hovered
                    ToolTip.text: "展开全部"
                    ToolTip.delay: 500
                    
                    onClicked: {
                        var newModel = treeList.model.slice()
                        for (var i = 0; i < newModel.length; i++) {
                            if (newModel[i].isFolder && newModel[i].childCount > 0) {
                                newModel[i].expanded = true
                            }
                        }
                        treeList.model = newModel
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                // 刷新
                ToolButton {
                    id: refreshBtn
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    
                    contentItem: Label {
                        text: "↻"
                        font.pixelSize: 14
                        color: textSecondary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    background: Rectangle {
                        radius: 6
                        color: refreshBtn.pressed ? selectedColor : (refreshBtn.hovered ? hoverColor : "transparent")
                    }
                    
                    ToolTip.visible: hovered
                    ToolTip.text: "刷新"
                    ToolTip.delay: 500
                    
                    onClicked: {
                        treeList.model = treeList.buildTreeModel()
                    }
                }
            }
        }
    }
}
