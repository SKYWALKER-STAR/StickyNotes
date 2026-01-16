import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Dialogs
import CommandManager 1.0

ListView {
    id: listView
    Layout.fillWidth: true
    Layout.fillHeight: true
    model: CommandManager
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
            if (!CommandManager) return
            CommandManager.copyToClipboard(commandContent)
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
                        if (!CommandManager) return
                        CommandManager.copyToClipboard(commandContent)
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
                        if (CommandManager) CommandManager.removeCommand(index)
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
                property var dataList: CommandManager ? CommandManager.commandsInFolder(title) : []
                model: dataList
                Connections {
                    target: CommandManager
                    function onCommandsChanged() {
                        nested.dataList = CommandManager ? CommandManager.commandsInFolder(title) : []
                    }
                    function onGroupsChanged() {
                        nested.dataList = CommandManager ? CommandManager.commandsInFolder(title) : []
                    }
                }

                delegate: ItemDelegate {
                    // 点击嵌套元素进行复制
                    onClicked: {
                        if (!CommandManager) return
                        CommandManager.copyToClipboard(commandContent)
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
                                    if (CommandManager) {
                                        CommandManager.copyToClipboard(commandContent)
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
                                    if (CommandManager) CommandManager.removeCommand(sourceIndex)
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