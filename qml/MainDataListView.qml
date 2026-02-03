import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Dialogs
import CommandManager 1.0

ListView {
    id: listView
    Layout.fillWidth: true
    Layout.fillHeight: true
    model: buildMainModel()
    clip: true
    spacing: 2  // 减小间距，让 folder 紧密排列
    signal addFolderRequested()
    signal addCommandRequested()
    
    property string selectedGroup: "All"

    // Sidebar 点击 command 时，用于触发主列表对应命令的悬浮动画
    property int pulseSourceIndex: -1
    property int pulseCounter: 0
    property int pendingPulseSourceIndex: -1
    
    // 引用外部组件
    property var commandDialog: null
    property var copyNotification: null
    property var previewWin: null
    
    onSelectedGroupChanged: {
        listView.model = buildMainModel()
    }

    function pulseCommand(sourceIndex) {
        pendingPulseSourceIndex = sourceIndex
        pulseTriggerTimer.restart()
    }

    Timer {
        id: pulseTriggerTimer
        interval: 0
        repeat: false
        onTriggered: {
            if (pendingPulseSourceIndex < 0) return
            pulseSourceIndex = pendingPulseSourceIndex
            pendingPulseSourceIndex = -1
            pulseCounter = pulseCounter + 1
        }
    }
    
    Connections {
        target: CommandManager
        function onCommandsChanged() {
            listView.model = buildMainModel()
        }
        function onGroupsChanged() {
            listView.model = buildMainModel()
        }
    }
    
    function buildMainModel() {
        if (selectedGroup === "" || !CommandManager) {
            return []
        }
        
        var result = []

        // 显示全部命令：按 folder 分组展示
        if (selectedGroup === "All") {
            var groups = CommandManager.groups || []
            for (var g = 0; g < groups.length; g++) {
                var groupName = groups[g]
                if (!groupName || groupName === "All") continue

                result.push({
                    isFolder: true,
                    title: groupName,
                    commandContent: "",
                    description: "",
                    group: groupName,
                    sourceIndex: -1
                })

                var groupCommands = CommandManager.commandsInFolder(groupName)
                for (var iAll = 0; iAll < groupCommands.length; iAll++) {
                    result.push(groupCommands[iAll])
                }
            }
            return result
        }
        
        // 添加folder条目
        result.push({
            isFolder: true,
            title: selectedGroup,
            commandContent: "", // folder没有命令内容
            description: "",
            group: selectedGroup,
            sourceIndex: -1
        })
        
        // 添加该folder下的所有命令
        var commands = CommandManager.commandsInFolder(selectedGroup)
        for (var i = 0; i < commands.length; i++) {
            result.push(commands[i])
        }
        
        return result
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
        id: mainItem
        required property bool isFolder
        required property string title
        required property string commandContent
        required property string description
        required property string group
        required property int sourceIndex
        
        width: listView.width
        // 动态计算高度
        height: isFolder ? folderColumn.implicitHeight + 22 : commandColumn.implicitHeight + 22

        property bool shouldPulse: !isFolder && sourceIndex === listView.pulseSourceIndex
        property real pulseScale: 1.0
        property real pulseLift: 0.0
        property real pulseGlow: 0.0

        onClicked: {
            if (isFolder) return
            if (!CommandManager) return
            CommandManager.copyToClipboard(commandContent)
            if (copyNotification) {
                copyNotification.text = "已复制: " + commandContent
                copyNotification.open()
            }
        }

        background: Rectangle {
            color: cardColor
            // 移除 folder 的悬停效果，保持固定边框
            border.color: subtleBorder
            border.width: 1
            radius: 6 // Sharper corners

            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: textPrimary
                opacity: pulseGlow
                visible: opacity > 0
            }
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
            }
        }

        // Command delegate
        ColumnLayout {
            id: commandColumn
            anchors.fill: parent
            anchors.margins: 12
            visible: !isFolder
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: title
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
                    text: commandContent
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

        // 悬停 + 点击脉冲动画（上浮/轻微放大/高亮）
        transform: Translate { y: pulseLift }
        property real baseScale: hovered ? 1.01 : 1.0
        scale: baseScale * pulseScale

        Behavior on baseScale {
            NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
        }

        SequentialAnimation {
            id: pulseAnim
            running: false
            ParallelAnimation {
                NumberAnimation { target: mainItem; property: "pulseScale"; from: 1.0; to: 1.03; duration: 120; easing.type: Easing.OutCubic }
                NumberAnimation { target: mainItem; property: "pulseLift"; from: 0; to: -6; duration: 120; easing.type: Easing.OutCubic }
                NumberAnimation { target: mainItem; property: "pulseGlow"; from: 0.0; to: 0.10; duration: 120; easing.type: Easing.OutCubic }
            }
            ParallelAnimation {
                NumberAnimation { target: mainItem; property: "pulseScale"; to: 1.0; duration: 220; easing.type: Easing.OutQuad }
                NumberAnimation { target: mainItem; property: "pulseLift"; to: 0; duration: 220; easing.type: Easing.OutQuad }
                NumberAnimation { target: mainItem; property: "pulseGlow"; to: 0.0; duration: 220; easing.type: Easing.OutQuad }
            }
        }

        Connections {
            target: listView
            function onPulseCounterChanged() {
                if (!shouldPulse) return
                // 尝试把该条目滚到可见区域，再播放动画
                listView.positionViewAtIndex(index, ListView.Contain)
                pulseAnim.restart()
            }
        }
    }
}  // 关闭 ListView