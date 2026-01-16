import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Dialogs
import CommandManager 1.0

FileDialog {
    id: importDialog
    title: "选择要导入的 JSON 文件"
    nameFilters: ["JSON files (*.json)", "All files (*)"]
    fileMode: FileDialog.OpenFile
    onAccepted: {
        if (CommandManager && CommandManager.importCommands(selectedFile)) {
            copyNotification.text = "数据导入成功"
            copyNotification.open()
        } else {
            copyNotification.text = "导入失败"
            copyNotification.open()
        }
    }
}
