import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts

Dialog {
    id: dialog
    property int editIndex: -1
    property bool folderMode: false
    title: folderMode ? (editIndex === -1 ? "添加新分组" : "修改分组")
                  : (editIndex === -1 ? "添加新命令" : "修改命令")
    modal: true
    standardButtons: Dialog.Ok | Dialog.Cancel
    anchors.centerIn: parent
    width: 400

    function openForAdd() {
        editIndex = -1
        folderMode = false
        titleFieldCmd.text = ""
        commandField.text = ""
        descField.text = ""
        dialog.open()
        console.log("Hello from dialog openForAdd")
    }

    function openForAddFolder() {
        editIndex = -1
        folderMode = true
        titleFieldFolder.text = ""
        commandField.text = ""
        descField.text = ""
        dialog.open()
        console.log("Hello from dialog openForAddFolder")
    }

    function openForEdit(index, title, cmd, desc, group, isFolder) {
        editIndex = index
        folderMode = !isFolder
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
        dialog.open()
    }

    onAccepted: {
        console.log("Into onAccepted")
        if (commandManager)
            if (folderMode) {
                console.log("FolderMode")
                if (editIndex === -1)
                    commandManager.addFolder(titleFieldFolder.text, groupField.text)
                else
                    commandManager.editFolder(editIndex, titleFieldFolder.text, groupField.text)
            } else {
                console.log("!FoldMode")
                if (editIndex === -1)
                    commandManager.addCommand(titleFieldCmd.text, commandField.text, descField.text, groupField.text)
                else
                    commandManager.editCommand(editIndex, titleFieldCmd.text, commandField.text, descField.text, groupField.text)
            }
        if (!commandManager)
            console.log("onAccepted: !commandManager")
            return
        if (folderMode && titleFieldFolder.text === "")
            console.log("onAccepted: folderMode")
            return
        if (!folderMode && titleFieldCmd.text === "")
            console.log("onAccepted: !folderMode && titleFieldCmd.text")
            return
        if (!folderMode && commandField.text === "")
            console.log("onAccepted: !folderMode && commandField.text")
            return
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        TextField {
            id: titleFieldCmd
            placeholderText: "标题 (例如: 查看日志)"
            Layout.fillWidth: true
            visible: !folderMode
        }

        TextField {
            id: titleFieldFolder
            placeholderText: "分组"
            Layout.fillWidth: true
            height: 100
            visible: folderMode
        }

        TextField {
            id: commandField
            placeholderText: "命令内容 (例如: tail -f /var/log/syslog)"
            Layout.fillWidth: true
            Layout.preferredHeight: folderMode ? 0 : 100
            visible: !folderMode
            background: Rectangle {
                border.color: "#ccc"
            }
        }

        TextField {
            id: descField
            placeholderText: "描述 (可选)"
            Layout.fillWidth: true
            visible: !folderMode
        }

        ComboBox {
            id: groupField
            //placeholderText: "分组 (可选)"
            editable: true
            model: commandManager ? commandManager.groups : []
            Component.onCompleted: {
                if (editable && editText === "")
                    editText = ""
            }
            Layout.fillWidth: true
            visible: !folderMode
        }
    }
}
