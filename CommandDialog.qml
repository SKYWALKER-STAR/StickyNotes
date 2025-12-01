import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts

Dialog {
    id: dialog
    property var commandManager 
    property int editIndex: -1
    property bool folderMode: false
    
    title: folderMode ? (editIndex === -1 ? "添加新分组" : "修改分组")
                      : (editIndex === -1 ? "添加新命令" : "修改命令")
    modal: true
    standardButtons: Dialog.Ok | Dialog.Cancel
    anchors.centerIn: parent
    width: 400

    // Helper function to safely get the group text
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
        dialog.open()
    }

    function openForAddFolder() {
        editIndex = -1
        folderMode = true
        titleFieldFolder.text = ""
        if (groupField) { groupField.currentIndex = -1; groupField.editText = "" }
        dialog.open()
    }

    function openForEdit(index, title, cmd, desc, group, isFolder) {
        editIndex = index
        folderMode = isFolder // Corrected: Do not invert!
        
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
        
        // 1. Validation first (with braces)
        if (!commandManager) {
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

        // 2. Get group text
        const g = groupText()

        // 3. Execute logic
        if (folderMode) {
            console.log("Processing FolderMode")
            if (editIndex === -1)
                commandManager.addFolder(titleFieldFolder.text, g)
            else
                commandManager.editFolder(editIndex, titleFieldFolder.text, g)
        } else {
            console.log("Processing CommandMode")
            if (editIndex === -1)
                commandManager.addCommand(titleFieldCmd.text, commandField.text, descField.text, g)
            else
                commandManager.editCommand(editIndex, titleFieldCmd.text, commandField.text, descField.text, g)
        }
    }

    // Corrected: Use contentItem to avoid covering buttons
    contentItem: ColumnLayout {
        width: dialog.width
        spacing: 10

        TextField {
            id: titleFieldCmd
            placeholderText: "标题 (例如: 查看日志)"
            Layout.fillWidth: true
            visible: !folderMode
        }

        TextField {
            id: titleFieldFolder
            placeholderText: "分组名称"
            Layout.fillWidth: true
            visible: folderMode
        }

        TextField {
            id: commandField
            placeholderText: "命令内容 (例如: tail -f /var/log/syslog)"
            Layout.fillWidth: true
            Layout.preferredHeight: folderMode ? 0 : 100
            visible: !folderMode
            background: Rectangle { border.color: "#ccc" }
        }

        TextField {
            id: descField
            placeholderText: "描述 (可选)"
            Layout.fillWidth: true
            visible: !folderMode
        }

        ComboBox {
            id: groupField
            editable: true
            model: commandManager ? commandManager.groups : []
            Layout.fillWidth: true
            // Make group selection visible for folders too, if desired
            // visible: !folderMode 
            Component.onCompleted: {
                if (editable && editText === "") editText = ""
            }
        }
    }
}
