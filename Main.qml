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
        //importRequested: importDialog.open()
        //exportRequested: exportDialog.open()
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
            if (commandDialog && typeof commandDialog.openForAddFolder === 'function')
                commandDialog.openForAddFolder()
                console.log("Hello world")
        }
        onAddCommandRequested: {
            if (commandDialog && typeof commandDialog.openForAdd === 'function')
                commandDialog.openForAdd()
                console.log("Hello world from cmd req")
        }
        
        delegate: ItemDelegate {
            width: listView.width
            height: column.implicitHeight + 20

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
                id: column
                anchors.fill: parent
                anchors.margins: 10
                spacing: 5

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
                            if (!commandManager)
                                return
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
                            commandDialog.openForEdit(index, title, commandContent, description, group, isFolder)
                        }
                    }   
                    Button {
                        text: "删除"
                        onClicked: {
                            if (commandManager)
                                commandManager.removeCommand(index)
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
    
    CommandDialog {
        id: commandDialog
        //commandManager: commandManager
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