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
    
    header: AppHeader {
        id: appHeader
        commandManager: commandManager
        onImportRequested: importDialog.open()
        onExportRequested: exportDialog.open()
    }

    contentData: ListView {
        id: listView
        anchors.fill: parent
        model: commandManager
        clip: true
        spacing: 10 
        signal addFolderRequested()
        signal addCommandRequested()
        
        footer: Item {
            width: listView.width
            height: 60
            z: 2

            ToolButton {
                id: addButton
                anchors.centerIn: parent
                text: "+"
                font.pixelSize: 24
                width: 50
                height: 50
                onClicked: addMenu.open()
                background: Rectangle {
                    color: addButton.pressed ? "#d0d0d0" : "#e0e0e0"
                    radius: 25
                    border.color: "#cccccc"
                }
            }
            Menu {
                id: addMenu
                z: 3
                x: addButton.x
                y: addButton.y + addButton.height + 2
                MenuItem {
                    text: "Add Folder"
                    onTriggered: {
                        if (commandDialog && typeof commandDialog.openForAddFolder === 'function') {
                            commandDialog.openForAddFolder()
                        } else {
                            addFolderRequested()
                        }
                    }
                }
                MenuItem {
                    text: "Add Command"
                    onTriggered: {
                        if (commandDialog && typeof commandDialog.openForAdd === 'function') {
                            commandDialog.openForAdd()
                        } else {
                            addCommandRequested()
                        }
                    }
                }
            }
        }
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
            height: isFolder ? folderColumn.implicitHeight + 20 : cmdColumn.implicitHeight + 20

            onClicked: {
                if (!commandManager)
                    return
                commandManager.copyToClipboard(commandContent)
                if (copyNotification) {
                    copyNotification.text = "已复制: " + title
                    copyNotification.open()
                }
            }

            background: Rectangle {
                color: parent.hovered ? "#f9f9f9ff" : "white"
                border.color: "#e0e0e0"
                radius: 5
            }

            ColumnLayout {
                id: folderColumn
                anchors.fill: parent
                anchors.margins: 10
                visible: isFolder
                spacing: 8

                // 1. 修复标题栏布局
                RowLayout {
                    // 错误：anchors.fill: parent // 不能在 ColumnLayout 里用这个
                    // 正确：
                    Layout.fillWidth: true
                    visible: isFolder
                    spacing: 6

                    Label {
                        text: title
                        font.bold: true
                        font.pixelSize: 16
                        Layout.fillWidth: true
                    }

                    Button {
                        text: "复制"
                        onClicked: {
                            if (!commandManager) return
                            commandManager.copyToClipboard(commandContent)
                            if (copyNotification) {
                                copyNotification.text = "已复制: " + title
                                copyNotification.open()
                            }
                        }
                    }
                    Button {
                        text: "修改"
                        onClicked: {
                            // 注意：这里传入 true 表示是 folder
                            commandDialog.openForEdit(index, title, commandContent, description, group, true)
                        }
                    }
                    Button {
                        text: "删除"
                        onClicked: {
                            if (commandManager) commandManager.removeCommand(index)
                        }
                    }
                    Button {
                        text: nested.visible ? "收起" : "展开"
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
                    spacing: 6
                    interactive: false // 嵌套列表通常禁止独立滚动，随外层滚动

                    // 关键：只显示属于当前 Folder 的命令
                    // 假设 C++ 已经实现了 commandsInFolder(QString folderName)
                    model: commandManager ? commandManager.commandsInFolder(title) : []

                    delegate: ItemDelegate {
                        width: nested.width
                        height: innerCol.implicitHeight + 12
                        background: Rectangle {
                            color: parent.hovered ? "#FAFAFA" : "white"
                            border.color: "#E0E0E0"
                            radius: 5
                        }
                        ColumnLayout {
                            id: innerCol
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 6
                            RowLayout {
                                Layout.fillWidth: true
                                Label {
                                    text: title // 这里的 title 是命令的标题
                                    font.bold: true
                                    Layout.fillWidth: true
                                }
                                Button {
                                    text: "复制"
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
                                Button {
                                    text: "修改"
                                    onClicked: {
                                        // 修改命令，isFolder = false
                                        if (commandDialog) commandDialog.openForEdit(index, title, commandContent, description, group, false)
                                    }
                                }
                                Button {
                                    text: "删除"
                                    onClicked: {
                                        if (commandManager) commandManager.removeCommand(index)
                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                height: 40
                                color: "#f5f5f5"
                                radius: 3
                                border.color: "#dddddd"

                                Text {
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    text: commandContent
                                    font.family: "Courier New"
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                }
                            }

                            Label {
                                text: description
                                color: "gray"
                                font.pixelSize: 12
                                visible: description !== ""
                            }
                        }
                    }
                }
            }
            
            ColumnLayout {
                id: cmdColumn
                anchors.fill: parent
                anchors.margins: 10
                visible: !isFolder
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        text: title
                        font.bold: true
                        font.pixelSize: 16
                        Layout.fillWidth: true
                    }
                    Button {
                        text: "复制"
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
                    Button {
                        text: "修改"
                        onClicked: {
                            if (commandDialog) commandDialog.openForEdit(index, title, commandContent, description, group, false)
                        }
                    }
                    Button {
                        text: "删除"
                        onClicked: {
                            if (commandManager) commandManager.removeCommand(index)
                        }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 48
                    color: "#F5F5F5"
                    radius: 3
                    border.color: "#DDDDDD"
                    Text {
                        anchors.fill: parent
                        anchors.margins: 6
                        text: commandContent
                        font.family: "Consolas"
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                }

                Label {
                    text: description
                    color: "gray"
                    font.pixelSize: 12
                    visible: description !== ""
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
        width: 400

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
            spacing: 10

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
                Layout.preferredHeight: commandDialog.folderMode ? 0 : 100
                visible: !commandDialog.folderMode
                background: Rectangle { border.color: "#ccc" }
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
            }
        }
    }

    ToolTip {
        id: copyNotification
        text: "命令已复制到剪贴板"
        timeout: 2000
        anchors.centerIn: parent
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
}