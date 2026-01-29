import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts

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
    
    // 信号
    signal groupSelected(string groupName)
    signal itemClicked(int index, bool isFolder, string cmd)
    
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
        
        // 侧边栏标题
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            color: "transparent"
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 12
                spacing: 8
                
                Label {
                    text: "📁"
                    font.pixelSize: 16
                }
                
                Label {
                    text: "分组导航"
                    font.bold: true
                    font.pixelSize: 13
                    color: textPrimary
                    Layout.fillWidth: true
                }
            }
            
            // 底部分隔线
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 12
                anchors.rightMargin: 12
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
                    treeList.model = buildTreeModel()
                }
                function onGroupsChanged() {
                    treeList.model = buildTreeModel()
                }
            }
            
            function buildTreeModel() {
                if (!commandManager) {
                    console.log("SidebarTreeView: commandManager is null")
                    return []
                }
                
                var result = []
                
                // 添加 "全部" 选项
                result.push({
                    name: "All",
                    displayName: "全部命令",
                    icon: "🏠",
                    isFolder: true,
                    level: 0,
                    expanded: true,
                    childCount: 0,
                    index: -1
                })
                
                // 获取所有分组（文件夹）
                var groups = commandManager.groups
                
                for (var i = 0; i < groups.length; i++) {
                    var groupName = groups[i]
                    if (groupName === "All") continue
                    
                    // 获取该分组下的命令数量
                    var commands = commandManager.commandsInFolder(groupName)
                    console.log("SidebarTreeView: group", groupName, "has", commands.length, "commands")
                    
                    result.push({
                        name: groupName,
                        displayName: groupName,
                        icon: "📂",
                        isFolder: true,
                        level: 0,
                        expanded: false,
                        childCount: commands.length,
                        index: -1
                    })
                    
                    // 添加子命令（可展开显示）
                    for (var j = 0; j < commands.length; j++) {
                        var cmd = commands[j]
                        result.push({
                            name: cmd.title,
                            displayName: cmd.title,
                            icon: "📄",
                            isFolder: false,
                            level: 1,
                            expanded: false,
                            childCount: 0,
                            parentGroup: groupName,
                            index: cmd.sourceIndex,
                            command: cmd.commandContent
                        })
                    }
                }
                
                console.log("SidebarTreeView: buildTreeModel result count =", result.length)
                return result
            }
            
            delegate: ItemDelegate {
                id: treeItem
                width: treeList.width
                
                property bool isSelected: modelData.isFolder && modelData.name === selectedGroup
                property bool isExpanded: modelData.expanded || false
                property int itemLevel: modelData.level || 0
                
                // 只显示顶级项目，或者父级展开的子项
                visible: {
                    if (itemLevel === 0) return true
                    // 查找父级是否展开
                    var parentGroup = modelData.parentGroup
                    for (var i = 0; i < treeList.model.length; i++) {
                        var item = treeList.model[i]
                        if (item.isFolder && item.name === parentGroup) {
                            return item.expanded
                        }
                    }
                    return false
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
                                var newModel = treeList.model.slice()
                                for (var i = 0; i < newModel.length; i++) {
                                    if (newModel[i].name === modelData.name && newModel[i].isFolder) {
                                        newModel[i].expanded = !newModel[i].expanded
                                        break
                                    }
                                }
                                treeList.model = newModel
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
                }
                
                onClicked: {
                    if (modelData.isFolder) {
                        selectedGroup = modelData.name
                        groupSelected(modelData.name)
                        
                        // 如果有子项，同时切换展开状态
                        if (modelData.childCount > 0) {
                            var newModel = treeList.model.slice()
                            for (var i = 0; i < newModel.length; i++) {
                                if (newModel[i].name === modelData.name && newModel[i].isFolder) {
                                    newModel[i].expanded = !newModel[i].expanded
                                    break
                                }
                            }
                            treeList.model = newModel
                        }
                    } else {
                        // 点击命令项，触发复制
                        if (commandManager && modelData.command) {
                            commandManager.copyToClipboard(modelData.command)
                            itemClicked(modelData.index, false, modelData.command)
                        }
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
