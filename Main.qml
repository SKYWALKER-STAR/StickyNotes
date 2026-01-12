import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Dialogs
//import "commandManager"

ApplicationWindow {
    visible: true
    width: 800
    height: 600
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
    property string uiFont: "Segoe UI, Roboto, Noto Sans, Arial"

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
    
    // 标准菜单栏
    menuBar: MenuBar {
        Menu {
            title: "文件"
            
            MenuItem {
                text: "📝  新建命令                    Ctrl+N"
                onTriggered: {
                    if (commandDialog && typeof commandDialog.openForAdd === 'function') {
                        commandDialog.openForAdd()
                    }
                }
            }
            MenuItem {
                text: "📁  新建分组           Ctrl+Shift+N"
                onTriggered: {
                    if (commandDialog && typeof commandDialog.openForAddFolder === 'function') {
                        commandDialog.openForAddFolder()
                    }
                }
            }
            MenuSeparator {}
            MenuItem {
                text: "📥  导入...                       Ctrl+O"
                onTriggered: importDialog.open()
            }
            MenuItem {
                text: "📤  导出...                       Ctrl+S"
                onTriggered: exportDialog.open()
            }
            MenuSeparator {}
            MenuItem {
                text: "🚪  退出                          Ctrl+Q"
                onTriggered: Qt.quit()
            }
        }
        
        Menu {
            title: "编辑"
            
            MenuItem {
                text: "🔍  查找                          Ctrl+F"
                onTriggered: appHeader.searchField.forceActiveFocus()
            }
            MenuSeparator {}
            MenuItem {
                text: "⚙️  偏好设置..."
                enabled: false
            }
        }
        
        Menu {
            title: "视图"
            
            MenuItem {
                text: "🔄  刷新                               F5"
                onTriggered: {
                    if (commandManager) {
                        commandManager.initialize()
                    }
                }
            }
            MenuSeparator {}
            MenuItem {
                text: "📂  展开所有分组"
                enabled: false
            }
            MenuItem {
                text: "📁  折叠所有分组"
                enabled: false
            }
        }
        
        Menu {
            title: "帮助"
            
            MenuItem {
                text: "ℹ️  关于 CMD BOX"
                onTriggered: {
                    if (copyNotification) {
                        copyNotification.text = "CMD BOX v1.0 - 命令管理工具"
                        copyNotification.open()
                    }
                }
            }
            MenuItem {
                text: "⬆️  检查更新..."
                enabled: false
            }
            MenuSeparator {}
            MenuItem {
                text: "📖  文档"
                enabled: false
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

    contentData: ListView {
        id: listView
        anchors.fill: parent
        model: commandManager
        clip: true
        spacing: 2  // 减小间距，让 folder 紧密排列
        signal addFolderRequested()
        signal addCommandRequested()
        
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
    }
    Dialog {
        id: commandDialog
        property var model
        property int editIndex: -1
        property bool folderMode: false
        
        // bind to global context property
        model: commandManager
        
        title: folderMode ? (editIndex === -1 ? "添加新分组" : "修改分组")
                          : (editIndex === -1 ? "添加新命令" : "修改命令")
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: parent
        width: 480
        background: Rectangle {
            color: cardColor
            border.color: subtleBorder
            radius: 12
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
            console.log("Into onAccepted")
            if (!model) {
                console.log("onAccepted: !commandManager")
                return
            }
            if (folderMode) {
                if (titleFieldFolder.text.trim() === "") {
                    console.log("onAccepted: folder title empty")
                    return
                }
            } else {
                if (titleFieldCmd.text.trim() === "") {
                    console.log("onAccepted: cmd title empty")
                    return
                }
                if (commandField.text.trim() === "") {
                    console.log("onAccepted: cmd content empty")
                    return
                }
            }

            const g = groupText()

            if (folderMode) {
                console.log("Processing FolderMode")
                if (editIndex === -1)
                    model.addFolder(titleFieldFolder.text, g)
                else
                    model.editFolder(editIndex, titleFieldFolder.text, g)
            } else {
                console.log("Processing CommandMode")
                if (editIndex === -1)
                    model.addCommand(titleFieldCmd.text, commandField.text, descField.text, g)
                else
                    model.editCommand(editIndex, titleFieldCmd.text, commandField.text, descField.text, g)
            }
        }

        contentItem: ColumnLayout {
            width: commandDialog.width
            spacing: 12
            anchors.margins: 14

            TextField {
                id: titleFieldCmd
                placeholderText: "标题 (例如: 查看日志)"
                Layout.fillWidth: true
                visible: !commandDialog.folderMode
            }

            TextField {
                id: titleFieldFolder
                placeholderText: "分组名称"
                Layout.fillWidth: true
                visible: commandDialog.folderMode
            }

            TextField {
                id: commandField
                placeholderText: "命令内容 (例如: tail -f /var/log/syslog)"
                Layout.fillWidth: true
                Layout.preferredHeight: commandDialog.folderMode ? 0 : 120
                visible: !commandDialog.folderMode
                font.family: "Courier New"
                background: Rectangle { border.color: subtleBorder; color: "#fafafa"; radius: 6 }
            }

            TextField {
                id: descField
                placeholderText: "描述 (可选)"
                Layout.fillWidth: true
                visible: !commandDialog.folderMode
            }

            ComboBox {
                id: groupField
                editable: true
                model: commandDialog.model ? commandDialog.model.groups : []
                Layout.fillWidth: true
                Component.onCompleted: {
                    if (editable && editText === "") editText = ""
                }
                visible: !commandDialog.folderMode
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