import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Dialogs
//import "commandManager"

ApplicationWindow {
    id: appWindow
    visible: true
    width: 1000
    height: 650
    minimumWidth: 700
    minimumHeight: 400
    title: "CMD BOX"

    // 全局主题变量（经典黑白 - 现代极简）
    property color bgColor: "#ffffff"      // 纯白背景
    property color cardColor: "#ffffff"
    property color subtleBorder: "#e5e5e5" // 极浅灰边框
    property color primary: "#171717"      // 几乎纯黑
    property color primaryDark: "#000000"  // 纯黑
    property color accent: "#525252"       // 中灰
    property color textPrimary: "#0a0a0a"  // 墨黑
    property color textSecondary: "#737373" // 深灰
    property color menuHoverColor: "#f5f5f5" // 菜单悬停色
    property string uiFont: "Segoe UI, Roboto, Noto Sans, Arial"
    
    // 侧边栏控制
    property bool sidebarVisible: true
    property real sidebarWidth: 240

    font.family: uiFont

    Rectangle {
        anchors.fill: parent
        color: bgColor
    }

    Component.onCompleted: {
        if (commandManager)
            commandManager.initialize()
        console.log('Hello')
    }

    Shortcut {
        sequence: "Ctrl+F"
        onActivated: appHeader.searchField.forceActiveFocus()
    }

    Shortcut {
        sequence: "Ctrl+N"
        onActivated: commandDialog.openForAdd()
    }
    Item {
        states: State { name: "running" }
    }
    
    // 现代化扁平菜单栏
    menuBar: MenuBar {
        id: mainMenuBar
        
        background: Rectangle {
            color: bgColor
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: subtleBorder
            }
        }
        
        delegate: MenuBarItem {
            id: menuBarItem
            
            contentItem: Text {
                text: menuBarItem.text
                font.pixelSize: 13
                font.family: uiFont
                color: menuBarItem.highlighted ? primaryDark : textSecondary
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
            
            background: Rectangle {
                implicitWidth: 40
                implicitHeight: 32
                color: menuBarItem.highlighted ? menuHoverColor : "transparent"
                radius: 4
            }
        }
        
        // 文件菜单
        Menu {
            id: fileMenu
            title: qsTr("文件")
            
            background: Rectangle {
                implicitWidth: 220
                implicitHeight: fileMenu.contentHeight + 16
                color: "#ffffff"
                border.color: subtleBorder
                border.width: 1
                radius: 8
                opacity: 1
            }
            
            delegate: MenuItem {
                id: fileMenuItem
                implicitWidth: 200
                implicitHeight: 36
                
                contentItem: RowLayout {
                    spacing: 12
                    
                    Text {
                        text: fileMenuItem.text
                        font.pixelSize: 13
                        font.family: uiFont
                        color: fileMenuItem.enabled ? textPrimary : textSecondary
                        Layout.fillWidth: true
                    }
                    
                    Text {
                        text: {
                            if (fileMenuItem.action && fileMenuItem.action.shortcut)
                                return fileMenuItem.action.shortcut
                            return ""
                        }
                        font.pixelSize: 11
                        font.family: uiFont
                        color: textSecondary
                        visible: text !== ""
                    }
                }
                
                background: Rectangle {
                    color: fileMenuItem.highlighted ? menuHoverColor : "transparent"
                    radius: 4
                    anchors.margins: 4
                }
            }
            
            Action {
                text: qsTr("新建命令")
                shortcut: "Ctrl+N"
                onTriggered: commandDialog.openForAdd()
            }
            
            Action {
                text: qsTr("新建分组")
                shortcut: "Ctrl+Shift+N"
                onTriggered: commandDialog.openForAddFolder()
            }
            
            MenuSeparator {
                contentItem: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 1
                    color: subtleBorder
                }
            }
            
            Action {
                text: qsTr("导入数据...")
                shortcut: "Ctrl+I"
                onTriggered: importDialog.open()
            }
            
            Action {
                text: qsTr("导出数据...")
                shortcut: "Ctrl+E"
                onTriggered: exportDialog.open()
            }
            
            MenuSeparator {
                contentItem: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 1
                    color: subtleBorder
                }
            }
            
            Action {
                text: qsTr("退出")
                shortcut: "Ctrl+Q"
                onTriggered: Qt.quit()
            }
        }
        
        // 编辑菜单
        Menu {
            id: editMenu
            title: qsTr("编辑")
            
            background: Rectangle {
                implicitWidth: 220
                implicitHeight: editMenu.contentHeight + 16
                color: "#ffffff"
                border.color: subtleBorder
                border.width: 1
                radius: 8
                opacity: 1
            }
            
            delegate: MenuItem {
                id: editMenuItem
                implicitWidth: 200
                implicitHeight: 36
                
                contentItem: RowLayout {
                    spacing: 12
                    
                    Text {
                        text: editMenuItem.text
                        font.pixelSize: 13
                        font.family: uiFont
                        color: editMenuItem.enabled ? textPrimary : textSecondary
                        Layout.fillWidth: true
                    }
                    
                    Text {
                        text: {
                            if (editMenuItem.action && editMenuItem.action.shortcut)
                                return editMenuItem.action.shortcut
                            return ""
                        }
                        font.pixelSize: 11
                        font.family: uiFont
                        color: textSecondary
                        visible: text !== ""
                    }
                }
                
                background: Rectangle {
                    color: editMenuItem.highlighted ? menuHoverColor : "transparent"
                    radius: 4
                    anchors.margins: 4
                }
            }
            
            Action {
                text: qsTr("搜索")
                shortcut: "Ctrl+F"
                onTriggered: appHeader.searchField.forceActiveFocus()
            }
            
            MenuSeparator {
                contentItem: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 1
                    color: subtleBorder
                }
            }
            
            Action {
                text: qsTr("刷新列表")
                shortcut: "F5"
                onTriggered: {
                    if (commandManager) {
                        commandManager.setFilter("")
                        appHeader.searchField.text = ""
                    }
                }
            }
        }
        
        // 视图菜单
        Menu {
            id: viewMenu
            title: qsTr("视图")
            
            background: Rectangle {
                implicitWidth: 220
                implicitHeight: viewMenu.contentHeight + 16
                color: "#ffffff"
                border.color: subtleBorder
                border.width: 1
                radius: 8
                opacity: 1
            }
            
            delegate: MenuItem {
                id: viewMenuItem
                implicitWidth: 200
                implicitHeight: 36
                
                contentItem: RowLayout {
                    spacing: 12
                    
                    Text {
                        text: viewMenuItem.text
                        font.pixelSize: 13
                        font.family: uiFont
                        color: viewMenuItem.enabled ? textPrimary : textSecondary
                        Layout.fillWidth: true
                    }
                    
                    Text {
                        text: {
                            if (viewMenuItem.action && viewMenuItem.action.shortcut)
                                return viewMenuItem.action.shortcut
                            return ""
                        }
                        font.pixelSize: 11
                        font.family: uiFont
                        color: textSecondary
                        visible: text !== ""
                    }
                    
                    // 复选标记
                    Text {
                        text: viewMenuItem.checkable && viewMenuItem.checked ? "✓" : ""
                        font.pixelSize: 12
                        color: primary
                        visible: viewMenuItem.checkable
                    }
                }
                
                background: Rectangle {
                    color: viewMenuItem.highlighted ? menuHoverColor : "transparent"
                    radius: 4
                    anchors.margins: 4
                }
            }
            
            Action {
                text: qsTr("显示侧边栏")
                shortcut: "Ctrl+B"
                checkable: true
                checked: sidebarVisible
                onTriggered: sidebarVisible = !sidebarVisible
            }
            
            MenuSeparator {
                contentItem: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 1
                    color: subtleBorder
                }
            }
            
            Action {
                text: qsTr("展开所有分组")
                onTriggered: {
                    if (sidebarTree) {
                        // 触发侧边栏展开所有
                    }
                }
            }
            
            Action {
                text: qsTr("收起所有分组")
                onTriggered: {
                    if (sidebarTree) {
                        // 触发侧边栏收起所有
                    }
                }
            }
        }
        
        // 帮助菜单
        Menu {
            id: helpMenu
            title: qsTr("帮助")
            
            background: Rectangle {
                implicitWidth: 220
                implicitHeight: helpMenu.contentHeight + 16
                color: "#ffffff"
                border.color: subtleBorder
                border.width: 1
                radius: 8
                opacity: 1
            }
            
            delegate: MenuItem {
                id: helpMenuItem
                implicitWidth: 200
                implicitHeight: 36
                
                contentItem: RowLayout {
                    spacing: 12
                    
                    Text {
                        text: helpMenuItem.text
                        font.pixelSize: 13
                        font.family: uiFont
                        color: helpMenuItem.enabled ? textPrimary : textSecondary
                        Layout.fillWidth: true
                    }
                }
                
                background: Rectangle {
                    color: helpMenuItem.highlighted ? menuHoverColor : "transparent"
                    radius: 4
                    anchors.margins: 4
                }
            }
            
            Action {
                text: qsTr("快捷键指南")
                onTriggered: shortcutGuideDialog.open()
            }
            
            MenuSeparator {
                contentItem: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 1
                    color: subtleBorder
                }
            }
            
            Action {
                text: qsTr("关于 CMD BOX")
                onTriggered: aboutDialog.open()
            }
        }
    }
    
    // 快捷键指南对话框
    Dialog {
        id: shortcutGuideDialog
        title: "快捷键指南"
        modal: true
        anchors.centerIn: parent
        width: 400
        standardButtons: Dialog.Ok
        
        background: Rectangle {
            color: cardColor
            border.color: subtleBorder
            radius: 12
        }
        
        contentItem: ColumnLayout {
            spacing: 12
            
            Label {
                text: "常用快捷键"
                font.bold: true
                font.pixelSize: 16
                color: textPrimary
            }
            
            GridLayout {
                columns: 2
                columnSpacing: 24
                rowSpacing: 8
                
                Label { text: "Ctrl+N"; font.family: "Courier New"; color: accent }
                Label { text: "新建命令"; color: textPrimary }
                
                Label { text: "Ctrl+Shift+N"; font.family: "Courier New"; color: accent }
                Label { text: "新建分组"; color: textPrimary }
                
                Label { text: "Ctrl+F"; font.family: "Courier New"; color: accent }
                Label { text: "搜索"; color: textPrimary }
                
                Label { text: "Ctrl+I"; font.family: "Courier New"; color: accent }
                Label { text: "导入数据"; color: textPrimary }
                
                Label { text: "Ctrl+E"; font.family: "Courier New"; color: accent }
                Label { text: "导出数据"; color: textPrimary }
                
                Label { text: "Ctrl+B"; font.family: "Courier New"; color: accent }
                Label { text: "切换侧边栏"; color: textPrimary }
                
                Label { text: "F5"; font.family: "Courier New"; color: accent }
                Label { text: "刷新列表"; color: textPrimary }
            }
        }
    }
    
    // 关于对话框
    Dialog {
        id: aboutDialog
        title: "关于 CMD BOX"
        modal: true
        anchors.centerIn: parent
        width: 360
        standardButtons: Dialog.Ok
        
        background: Rectangle {
            color: cardColor
            border.color: subtleBorder
            radius: 12
        }
        
        contentItem: ColumnLayout {
            spacing: 16
            
            Label {
                text: "CMD BOX"
                font.bold: true
                font.pixelSize: 24
                color: textPrimary
                Layout.alignment: Qt.AlignHCenter
            }
            
            Label {
                text: "版本 1.0.0"
                font.pixelSize: 13
                color: textSecondary
                Layout.alignment: Qt.AlignHCenter
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: subtleBorder
            }
            
            Label {
                text: "快速管理你的常用命令\n一款现代化的命令管理工具"
                font.pixelSize: 13
                color: textSecondary
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }
            
            Label {
                text: "© 2024-2026 OpsTools"
                font.pixelSize: 11
                color: textSecondary
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }  
    
    header: ToolBar {
        id: appHeader
        height: 64
        padding: 12

        property alias searchField: searchInput

        background: Rectangle {
            color: "transparent"
            border.color: "transparent"
        }

        RowLayout {
            anchors.fill: parent
            spacing: 16
            anchors.leftMargin: 12
            anchors.rightMargin: 12

            ColumnLayout {
                Layout.preferredWidth: 220
                spacing: 2
                Label {
                    text: "CMD BOX"
                    font.bold: true
                    font.pixelSize: 20
                    color: textPrimary
                }
                Label {
                    text: "快速管理你的常用命令"
                    font.pixelSize: 12
                    color: textSecondary
                }
            }

            // 侧边栏切换按钮
            ToolButton {
                id: sidebarToggle
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                onClicked: sidebarVisible = !sidebarVisible
                
                background: Rectangle {
                    radius: 6
                    color: sidebarToggle.pressed ? "#f0f0f0" : (sidebarToggle.hovered ? "#f5f5f5" : "transparent")
                }
                
                contentItem: Label {
                    text: sidebarVisible ? "◀" : "▶"
                    font.pixelSize: 12
                    color: textSecondary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                ToolTip.visible: hovered
                ToolTip.text: sidebarVisible ? "隐藏侧边栏" : "显示侧边栏"
                ToolTip.delay: 500
            }

            TextField {
                id: searchInput
                placeholderText: "搜索命令..."
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                Layout.alignment: Qt.AlignVCenter
                verticalAlignment: Text.AlignVCenter
                leftPadding: 12
                rightPadding: 12
                font.pixelSize: 14
                onTextChanged: {
                    if (commandManager) 
                        commandManager.setFilter(text)
                }
                background: Rectangle {
                    color: "#f5f5f5" // Slight gray for input area
                    radius: 6
                    border.color: "transparent" // Flat style usually has no border or minimal
                    border.width: 0 
                    
                    // Add a focus indicator
                    Rectangle {
                        anchors.fill: parent
                        radius: 6
                        color: "transparent"
                        border.color: searchInput.activeFocus ? primary : "transparent"
                        border.width: 1.5
                    }
                }
            }

            ToolButton {
                id: menuButton
                text: "⋮"
                font.pixelSize: 20
                anchors.verticalCenter: parent.verticalCenter
                onClicked: optionsMenu.open()
                background: Rectangle {
                    implicitWidth: 40
                    implicitHeight: 40
                    radius: 12
                    color: menuButton.pressed ? "#f5f5f5" : "transparent"
                    border.color: menuButton.pressed ? subtleBorder : "transparent"
                    border.width: menuButton.pressed ? 1 : 0
                }
                contentItem: Label { text: menuButton.text; color: textSecondary; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                scale: menuButton.pressed ? 0.95 : 1.0
                Behavior on scale { NumberAnimation { duration: 100 } }
            }

            Menu {
                id: optionsMenu
                x: menuButton.x
                y: menuButton.y + menuButton.height
                MenuItem {
                    text: "导入数据"
                    onTriggered: importDialog.open()
                }
                MenuItem {
                    text: "导出数据"
                    onTriggered: exportDialog.open()
                }
            }
        }
    }

    contentData: RowLayout {
        anchors.fill: parent
        spacing: 0
        
        // 左侧边栏
        SidebarTreeView {
            id: sidebarTree
            Layout.preferredWidth: sidebarVisible ? sidebarWidth : 0
            Layout.fillHeight: true
            visible: sidebarVisible
            
            // 传递主题变量
            bgColor: appWindow.bgColor
            cardColor: appWindow.cardColor
            subtleBorder: appWindow.subtleBorder
            primary: appWindow.primary
            primaryDark: appWindow.primaryDark
            accent: appWindow.accent
            textPrimary: appWindow.textPrimary
            textSecondary: appWindow.textSecondary
            
            commandManager: commandManager
            
            onGroupSelected: function(groupName) {
                // 可选：按分组筛选
                if (commandManager) {
                    commandManager.setGroupFilter(groupName)
                }
            }
            
            onItemClicked: function(index, isFolder) {
                if (!isFolder) {
                    // 命令被点击，显示复制提示
                    copyNotification.text = "已复制命令"
                    copyNotification.open()
                }
            }
            
            // 展开/收起动画
            Behavior on Layout.preferredWidth {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
        }
        
        // 主内容区域
        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: commandManager
            clip: true
            spacing: 2  // 减小间距，让 folder 紧密排列
            signal addFolderRequested()
            signal addCommandRequested()
        
        onAddFolderRequested: {
            if (commandDialog && typeof commandDialog.openForAddFolder === 'function') {
                commandDialog.openForAddFolder()
            } else {
                console.log("Add folder requested but commandDialog unavailable")
            }
        }
        onAddCommandRequested: {
            if (commandDialog && typeof commandDialog.openForAdd === 'function') {
                commandDialog.openForAdd()
            } else {
                console.log("Add command requested but commandDialog unavailable")
            }
        }
        
        delegate: ItemDelegate {
            width: listView.width
            // 动态计算高度：如果是 Folder，高度由 folderColumn 决定
            height: isFolder ? folderColumn.implicitHeight + 22 : cmdColumn.implicitHeight + 22

            onClicked: {
                if (isFolder) return
                if (!commandManager) return
                commandManager.copyToClipboard(commandContent)
                if (copyNotification) {
                    copyNotification.text = "已复制: " + title
                    copyNotification.open()
                }
            }

            background: Rectangle {
                color: cardColor
                // 移除 folder 的悬停效果，保持固定边框
                border.color: subtleBorder
                border.width: 1
                radius: 6 // Sharper corners
            }

            ColumnLayout {
                id: folderColumn
                anchors.fill: parent
                anchors.margins: 12
                visible: isFolder
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    visible: isFolder
                    spacing: 10

                    Label {
                        text: title
                        font.bold: true
                        font.pixelSize: 15
                        Layout.fillWidth: true
                        color: textPrimary
                    }

                    CButton {
                        text: "复制"
                        theme: "primary"
                        onClicked: {
                            if (!commandManager) return
                            commandManager.copyToClipboard(commandContent)
                            if (copyNotification) {
                                copyNotification.text = "已复制: " + title
                                copyNotification.open()
                            }
                        }
                    }
                    CButton {
                        text: "修改"
                        theme: "warning"
                        onClicked: {
                            // 注意：这里传入 true 表示是 folder
                            commandDialog.openForEdit(index, title, commandContent, description, group, true)
                        }
                    }
                    CButton {
                        text: "删除"
                        theme: "danger"
                        onClicked: {
                            if (commandManager) commandManager.removeCommand(index)
                        }
                    }
                    CButton {
                        text: nested.visible ? "收起" : "展开"
                        theme: "neutral"
                        onClicked: nested.visible = !nested.visible
                    }
                }

                // 2. 修复嵌套列表
                ListView {
                    id: nested
                    Layout.fillWidth: true
                    // 关键：让列表高度随内容自动撑开，否则高度为0看不见
                    Layout.preferredHeight: visible ? contentItem.childrenRect.height : 0
                    visible: true
                    clip: true
                    spacing: 8
                    interactive: false // 嵌套列表通常禁止独立滚动，随外层滚动

                    // 使用 dataList 快照 + Connections 以便在模型变化时刷新
                    property var dataList: commandManager ? commandManager.commandsInFolder(title) : []
                    model: dataList
                    Connections {
                        target: commandManager
                        function onCommandsChanged() {
                            nested.dataList = commandManager ? commandManager.commandsInFolder(title) : []
                        }
                        function onGroupsChanged() {
                            nested.dataList = commandManager ? commandManager.commandsInFolder(title) : []
                        }
                    }

                    delegate: ItemDelegate {
                        // 点击嵌套元素进行复制
                        onClicked: {
                            if (!commandManager) return
                            commandManager.copyToClipboard(commandContent)
                            if (copyNotification) {
                                copyNotification.text = "已复制: " + title
                                copyNotification.open()
                            }
                        }
                        // Declare explicit roles from dataList to avoid shadowing parent roles
                        required property string title
                        required property string commandContent
                        required property string description
                        required property string group
                        required property int sourceIndex
                        width: nested.width
                        height: innerCol.implicitHeight + 12
                        background: Rectangle {
                            color: parent.hovered ? "#f5f5f5" : cardColor
                            // 为 command 添加悬停效果
                            border.color: parent.hovered ? primary : subtleBorder
                            border.width: 1
                            radius: 4
                            
                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                            Behavior on border.color {
                                ColorAnimation { duration: 150 }
                            }
                        }
                        ColumnLayout {
                            id: innerCol
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 8
                            RowLayout {
                                Layout.fillWidth: true
                                Label {
                                    text: title // 使用嵌套模型的 title，而非父级
                                    font.bold: true
                                    Layout.fillWidth: true
                                    color: textPrimary
                                }
                                CButton {
                                    text: "复制"
                                    theme: "primary"
                                    onClicked: {
                                        if (commandManager) {
                                            commandManager.copyToClipboard(commandContent)
                                            if (copyNotification) {
                                                copyNotification.text = "已复制: " + title
                                                copyNotification.open()
                                            }
                                        }
                                    }
                                }
                                CButton {
                                    text: "修改"
                                    theme: "warning"
                                    onClicked: {
                                        // 使用 sourceIndex（来自 commandsInFolder 快照）指向主模型
                                        if (commandDialog) commandDialog.openForEdit(sourceIndex, title, commandContent, description, group, false)
                                    }
                                }
                                CButton {
                                    text: "删除"
                                    theme: "danger"
                                    onClicked: {
                                        if (commandManager) commandManager.removeCommand(sourceIndex)
                                    }
                                }

                                CButton {
                                    text: "</>"
                                    theme: "success"
                                    implicitWidth: 40
                                    onClicked: previewWin.openWith(title,commandContent)
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                height: 44
                                color: "#f7fafc"
                                radius: 6
                                border.color: "#eef2f5"

                                Text {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    text: commandContent // 使用嵌套模型的 commandContent
                                    font.family: "Courier New"
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                    color: textPrimary
                                }
                            }

                            Label {
                                text: description
                                color: textSecondary
                                font.pixelSize: 12
                                visible: description !== ""
                            }
                        }
                    }
                }
            }
        }
    }  // 关闭 ListView
    }  // 关闭 RowLayout (contentData)
    Dialog {
        id: commandDialog
        property var model
        property int editIndex: -1
        property bool folderMode: false
        
        model: commandManager
        
        modal: true
        // 使用 x 和 y 手动居中，确保不会超出窗口
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
        // 响应式宽度：最大不超过父窗口宽度的 80%，且不超过 480px
        width: Math.min(480, parent.width * 0.8)
        // 响应式高度：最大不超过父窗口高度的 75%
        height: Math.min(implicitHeight, parent.height * 0.75)
        padding: 0
        
        // 移除默认按钮，使用自定义按钮
        standardButtons: Dialog.NoButton
        
        background: Rectangle {
            color: "#ffffff"
            radius: 12
            border.color: "#e5e5e5"
            border.width: 1
        }

        function groupText() {
            if (!groupField) return ""
            return groupField.editable
                   ? (groupField.editText !== "" ? groupField.editText : groupField.currentText)
                   : groupField.currentText
        }

        function openForAdd() {
            editIndex = -1
            folderMode = false
            titleFieldCmd.text = ""
            commandField.text = ""
            descField.text = ""
            if (groupField) { groupField.currentIndex = -1; groupField.editText = "" }
            commandDialog.open()
        }

        function openForAddFolder() {
            editIndex = -1
            folderMode = true
            titleFieldFolder.text = ""
            if (groupField) { groupField.currentIndex = -1; groupField.editText = "" }
            commandDialog.open()
        }

        function openForEdit(index, title, cmd, desc, group, isFolder) {
            editIndex = index
            folderMode = isFolder
            
            if (folderMode) {
                titleFieldFolder.text = title
            } else {
                titleFieldCmd.text = title
            }
            commandField.text = cmd
            descField.text = desc
            
            if (groupField) {
                const g = (typeof group !== 'undefined') ? group : ""
                const i = g !== "" ? groupField.find(g) : -1
                if (i >= 0) {
                    groupField.currentIndex = i
                    groupField.editText = ""
                } else {
                    groupField.currentIndex = -1
                    groupField.editText = g
                }
            }
            commandDialog.open()
        }

        onAccepted: {
            if (!model) return
            if (folderMode) {
                if (titleFieldFolder.text.trim() === "") return
            } else {
                if (titleFieldCmd.text.trim() === "") return
                if (commandField.text.trim() === "") return
            }

            const g = groupText()

            if (folderMode) {
                if (editIndex === -1)
                    model.addFolder(titleFieldFolder.text, g)
                else
                    model.editFolder(editIndex, titleFieldFolder.text, g)
            } else {
                if (editIndex === -1)
                    model.addCommand(titleFieldCmd.text, commandField.text, descField.text, g)
                else
                    model.editCommand(editIndex, titleFieldCmd.text, commandField.text, descField.text, g)
            }
        }

        contentItem: ColumnLayout {
            spacing: 0
            
            // 标题栏
            Rectangle {
                Layout.fillWidth: true
                height: 52
                color: "transparent"
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 12
                    
                    // 图标
                    Text {
                        text: commandDialog.folderMode ? "📁" : "⌘"
                        font.pixelSize: 20
                    }
                    
                    // 标题
                    Text {
                        text: commandDialog.folderMode 
                              ? (commandDialog.editIndex === -1 ? "新建分组" : "编辑分组")
                              : (commandDialog.editIndex === -1 ? "新建命令" : "编辑命令")
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        color: "#171717"
                        Layout.fillWidth: true
                    }
                    
                    // 关闭按钮
                    Rectangle {
                        width: 28
                        height: 28
                        radius: 14
                        color: closeBtn.containsMouse ? "#f5f5f5" : "transparent"
                        
                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            font.pixelSize: 12
                            color: "#737373"
                        }
                        
                        MouseArea {
                            id: closeBtn
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: commandDialog.reject()
                        }
                    }
                }
                
                // 分隔线
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: "#e5e5e5"
                }
            }
            
            // 表单内容
            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: 20
                spacing: 16
                
                // 标题输入（命令模式）
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    visible: !commandDialog.folderMode
                    
                    Text {
                        text: "命令名称"
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: "#525252"
                    }
                    
                    TextField {
                        id: titleFieldCmd
                        placeholderText: "例如：查看系统日志"
                        Layout.fillWidth: true
                        font.pixelSize: 13
                        leftPadding: 12
                        rightPadding: 12
                        topPadding: 10
                        bottomPadding: 10
                        
                        background: Rectangle {
                            color: titleFieldCmd.activeFocus ? "#ffffff" : "#fafafa"
                            border.color: titleFieldCmd.activeFocus ? "#171717" : "#e5e5e5"
                            border.width: titleFieldCmd.activeFocus ? 2 : 1
                            radius: 6
                            
                            Behavior on border.color { ColorAnimation { duration: 150 } }
                            Behavior on border.width { NumberAnimation { duration: 150 } }
                        }
                    }
                }
                
                // 标题输入（分组模式）
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    visible: commandDialog.folderMode
                    
                    Text {
                        text: "分组名称"
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: "#525252"
                    }
                    
                    TextField {
                        id: titleFieldFolder
                        placeholderText: "例如：服务器运维"
                        Layout.fillWidth: true
                        font.pixelSize: 13
                        leftPadding: 12
                        rightPadding: 12
                        topPadding: 10
                        bottomPadding: 10
                        
                        background: Rectangle {
                            color: titleFieldFolder.activeFocus ? "#ffffff" : "#fafafa"
                            border.color: titleFieldFolder.activeFocus ? "#171717" : "#e5e5e5"
                            border.width: titleFieldFolder.activeFocus ? 2 : 1
                            radius: 6
                            
                            Behavior on border.color { ColorAnimation { duration: 150 } }
                            Behavior on border.width { NumberAnimation { duration: 150 } }
                        }
                    }
                }
                
                // 命令内容
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    visible: !commandDialog.folderMode
                    
                    Text {
                        text: "命令内容"
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: "#525252"
                    }
                    
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        
                        TextArea {
                            id: commandField
                            placeholderText: "例如：tail -f /var/log/syslog"
                            font.pixelSize: 12
                            font.family: "JetBrains Mono, Consolas, Monaco, monospace"
                            wrapMode: TextArea.Wrap
                            leftPadding: 12
                            rightPadding: 12
                            topPadding: 10
                            bottomPadding: 10
                            
                            background: Rectangle {
                                color: commandField.activeFocus ? "#1a1a1a" : "#262626"
                                border.color: commandField.activeFocus ? "#404040" : "#333333"
                                border.width: 1
                                radius: 6
                                
                                Behavior on color { ColorAnimation { duration: 150 } }
                                Behavior on border.color { ColorAnimation { duration: 150 } }
                            }
                            
                            color: "#10b981"  // 绿色代码风格
                            selectionColor: "#065f46"
                            selectedTextColor: "#ffffff"
                        }
                    }
                }
                
                // 描述
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    visible: !commandDialog.folderMode
                    
                    Text {
                        text: "描述（可选）"
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: "#525252"
                    }
                    
                    TextField {
                        id: descField
                        placeholderText: "简要说明这条命令的用途"
                        Layout.fillWidth: true
                        font.pixelSize: 13
                        leftPadding: 12
                        rightPadding: 12
                        topPadding: 10
                        bottomPadding: 10
                        
                        background: Rectangle {
                            color: descField.activeFocus ? "#ffffff" : "#fafafa"
                            border.color: descField.activeFocus ? "#171717" : "#e5e5e5"
                            border.width: descField.activeFocus ? 2 : 1
                            radius: 6
                            
                            Behavior on border.color { ColorAnimation { duration: 150 } }
                            Behavior on border.width { NumberAnimation { duration: 150 } }
                        }
                    }
                }
                
                // 分组选择
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    visible: !commandDialog.folderMode
                    
                    Text {
                        text: "所属分组"
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: "#525252"
                    }
                    
                    ComboBox {
                        id: groupField
                        editable: true
                        model: commandDialog.model ? commandDialog.model.groups : []
                        Layout.fillWidth: true
                        font.pixelSize: 13
                        
                        background: Rectangle {
                            color: groupField.pressed ? "#f5f5f5" : "#fafafa"
                            border.color: groupField.activeFocus ? "#171717" : "#e5e5e5"
                            border.width: groupField.activeFocus ? 2 : 1
                            radius: 6
                            
                            Behavior on border.color { ColorAnimation { duration: 150 } }
                        }
                        
                        contentItem: Text {
                            leftPadding: 12
                            rightPadding: groupField.indicator.width + 12
                            text: groupField.editText || groupField.displayText || "选择或输入分组名"
                            font: groupField.font
                            color: (groupField.editText || groupField.displayText) ? "#171717" : "#a3a3a3"
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                        
                        indicator: Text {
                            x: groupField.width - width - 12
                            y: (groupField.height - height) / 2
                            text: "▼"
                            font.pixelSize: 10
                            color: "#737373"
                        }
                    }
                }
            }
            
            // 底部按钮区
            Rectangle {
                Layout.fillWidth: true
                height: 56
                color: "#fafafa"
                
                // 顶部分隔线
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: "#e5e5e5"
                }
                
                RowLayout {
                    anchors.centerIn: parent
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    spacing: 10
                    
                    // 取消按钮
                    Rectangle {
                        width: 72
                        height: 34
                        radius: 6
                        color: cancelBtn.containsMouse ? "#f5f5f5" : "#ffffff"
                        border.color: "#e5e5e5"
                        border.width: 1
                        
                        Text {
                            anchors.centerIn: parent
                            text: "取消"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: "#525252"
                        }
                        
                        MouseArea {
                            id: cancelBtn
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: commandDialog.reject()
                        }
                        
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                    
                    // 确认按钮
                    Rectangle {
                        width: 72
                        height: 34
                        radius: 6
                        color: confirmBtn.pressed ? "#000000" : (confirmBtn.containsMouse ? "#262626" : "#171717")
                        
                        Text {
                            anchors.centerIn: parent
                            text: commandDialog.editIndex === -1 ? "创建" : "保存"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: "#ffffff"
                        }
                        
                        MouseArea {
                            id: confirmBtn
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: commandDialog.accept()
                        }
                        
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                }
            }
        }
    }

    // 使用 Popup 替代 ToolTip，因为 ToolTip 不支持 anchors
    Popup {
        id: copyNotification
        property alias text: notificationText.text
        width: notificationText.implicitWidth + 32
        height: 40
        x: (parent.width - width) / 2
        y: parent.height - height - 24
        closePolicy: Popup.NoAutoClose
        
        Timer {
            id: notificationTimer
            interval: 2000
            onTriggered: copyNotification.close()
        }
        
        function open() {
            visible = true
            notificationTimer.restart()
        }

        background: Rectangle {
            color: textPrimary
            radius: 8
            opacity: 0.95
        }
        
        contentItem: Text {
            id: notificationText
            text: "命令已复制到剪贴板"
            color: "white"
            font.pixelSize: 13
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    FileDialog {
        id: importDialog
        title: "选择要导入的 JSON 文件"
        nameFilters: ["JSON files (*.json)", "All files (*)"]
        fileMode: FileDialog.OpenFile
        onAccepted: {
            if (commandManager && commandManager.importCommands(selectedFile)) {
                copyNotification.text = "数据导入成功"
                copyNotification.open()
            } else {
                copyNotification.text = "导入失败"
                copyNotification.open()
            }
        }
    }

    FileDialog {
        id: exportDialog
        title: "导出为 JSON 文件"
        nameFilters: ["JSON files (*.json)", "All files (*)"]
        fileMode: FileDialog.SaveFile
        currentFile: "commands.json"
        onAccepted: {
            if (commandManager && commandManager.exportCommands(selectedFile)) {
                copyNotification.text = "数据导出成功"
                copyNotification.open()
            } else {
                copyNotification.text = "导出失败"
                copyNotification.open()
            }
        }
    }
    CommandBlok { id: previewWin }
}