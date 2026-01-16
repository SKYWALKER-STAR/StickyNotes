import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Dialogs
import CommandManager 1.0

FileDialog {
    id: exportDialog
    title: "导出为 JSON 文件"
    nameFilters: ["JSON files (*.json)", "All files (*)"]
    fileMode: FileDialog.SaveFile
    currentFile: "commands.json"
    onAccepted: {
        if (CommandManager && CommandManager.exportCommands(selectedFile)) {
            copyNotification.text = "数据导出成功"
            copyNotification.open()
        } else {
            copyNotification.text = "导出失败"
            copyNotification.open()
        }
    }
}