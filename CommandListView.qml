import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts

ListView {
    id: listView
    anchors.fill: parent
    model: commandManager
    clip: true
    spacing: 10
    property Item commandDialog
    property ToolTip copyNotification
    property var commandManager
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
                        console.log("Hello from add folder menu-1")
                    } else {
                        addFolderRequested()
                        console.log("Hello from add folder menu-2")
                    }
                }
            }
            MenuItem {
                text: "Add Command"
                onTriggered: {
                    if (commandDialog && typeof commandDialog.openForAdd === 'function') {
                        console.log("Hello from add command menu")
                        commandDialog.openForAdd()
                        console.log("Hello from add cmd menu-1")
                    } else {
                        addCommandRequested()
                        console.log("Hello from add cmd menu-2")
                    }
                }
            }
        }
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
