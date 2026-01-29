import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts
import Qt.labs.qmlmodels
import QtQuick.Dialogs
import CommandManager 1.0

Window {
    id: commandDialog
    property var model
    property int editIndex: -1
    property bool folderMode: false
    
    model: CommandManager
    
    // Window属性
    modality: Qt.ApplicationModal
    //flags: Qt.Dialog | Qt.WindowCloseButtonHint
    title: editIndex === -1 ? qsTr("新建命令") : qsTr("编辑命令")
    
    // 窗口尺寸
    width: 480
    minimumWidth: 400
    minimumHeight: 300
    height: folderMode ? 300 : 520
    
    //color: "#ffffff"
    
    signal accepted()
    signal rejected()
    
    function groupText() {
        if (!groupField) return ""
        // ComboBox.currentText is read-only; for editable combobox use editText.
        const t = (typeof groupField.editText !== "undefined" && groupField.editText !== "")
                    ? groupField.editText
                    : groupField.currentText
        return t || ""
    }

    function openForAdd() {
        editIndex = -1
        folderMode = false
        titleFieldCmd.text = ""
        commandField.text = ""
        descField.text = ""
        if (groupField) {
            groupField.currentIndex = -1
            groupField.editText = ""
        }
        commandDialog.show()
        commandDialog.raise()
        commandDialog.requestActivate()
    }

    function openForAddFolder() {
        editIndex = -1
        folderMode = true
        titleFieldFolder.text = ""
        if (groupField) {
            groupField.currentIndex = -1
            groupField.editText = ""
        }
        commandDialog.show()
        commandDialog.raise()
        commandDialog.requestActivate()
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
            groupField.editText = g
        }
        commandDialog.show()
        commandDialog.raise()
        commandDialog.requestActivate()
    }
    
    function accept() {
        accepted()
        close()
    }
    
    function reject() {
        rejected()
        close()
    }

    onAccepted: {
        if (!model) return
        if (folderMode) {
            if (titleFieldFolder.text.trim() === "") return
        } else {
            if (titleFieldCmd.text.trim() === "") return
            if (commandField.text.trim() === "") return
        }

        const g = groupText()

        if (folderMode) {
            if (editIndex === -1)
                model.addFolder(titleFieldFolder.text, g)
            else
                model.editFolder(editIndex, titleFieldFolder.text, g)
        } else {
            if (editIndex === -1)
                model.addCommand(titleFieldCmd.text, commandField.text, descField.text, g)
            else
                model.editCommand(editIndex, titleFieldCmd.text, commandField.text, descField.text, g)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        MouseArea {
            anchors.fill: parent
            z: -1
            enabled: groupField && groupField.popup && groupField.popup.visible
            onClicked: {
                if (groupField && groupField.popup) groupField.popup.close()
            }
        }
        
        // 标题栏
        Rectangle {
            Layout.fillWidth: true
            height: 52
            color: "transparent"
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 12
                
                // 图标
                Text {
                    text: "⌘"
                    font.pixelSize: 20
                }
                
                // 标题
                Text {
                    text: editIndex === -1 ? "新建命令" : "编辑命令"
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    color: "#171717"
                    Layout.fillWidth: true
                }
            }
            
            // 分隔线
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: "#e5e5e5"
            }
        }
        
        // 表单内容
        ColumnLayout {
            Layout.fillWidth: true
            Layout.margins: 20
            spacing: 16
            
            // 标题输入（命令模式）
            ColumnLayout {
                Layout.fillWidth: true
                Layout.topMargin: 0
                spacing: 6
                visible: !commandDialog.folderMode
                
                Text {
                    text: "命令名称"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: "#525252"
                }
                
                TextField {
                    id: titleFieldCmd
                    placeholderText: "例如：查看系统日志"
                    Layout.fillWidth: true
                    font.pixelSize: 13
                    leftPadding: 12
                    rightPadding: 12
                    topPadding: 10
                    bottomPadding: 10
                    
                    background: Rectangle {
                        color: titleFieldCmd.activeFocus ? "#ffffff" : "#fafafa"
                        border.color: titleFieldCmd.activeFocus ? "#171717" : "#e5e5e5"
                        border.width: titleFieldCmd.activeFocus ? 2 : 1
                        radius: 6
                        
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                        Behavior on border.width { NumberAnimation { duration: 150 } }
                    }
                }
            }
            
            // 标题输入（分组模式）
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                visible: commandDialog.folderMode
                
                Text {
                    text: "分组名称"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: "#525252"
                }
                
                TextField {
                    id: titleFieldFolder
                    placeholderText: "例如：服务器运维"
                    Layout.fillWidth: true
                    font.pixelSize: 13
                    leftPadding: 12
                    rightPadding: 12
                    topPadding: 10
                    bottomPadding: 10
                    
                    background: Rectangle {
                        color: titleFieldFolder.activeFocus ? "#ffffff" : "#fafafa"
                        border.color: titleFieldFolder.activeFocus ? "#171717" : "#e5e5e5"
                        border.width: titleFieldFolder.activeFocus ? 2 : 1
                        radius: 6
                        
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                        Behavior on border.width { NumberAnimation { duration: 150 } }
                    }
                }
            }
            
            // 命令内容
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                visible: !commandDialog.folderMode
                
                Text {
                    text: "命令内容"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: "#525252"
                }
                
                ScrollView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    
                    TextArea {
                        id: commandField
                        placeholderText: "例如：tail -f /var/log/syslog"
                        placeholderTextColor: "#ffffff"
                        font.pixelSize: 12
                        font.family: "JetBrains Mono, Consolas, Monaco, monospace"
                        wrapMode: TextArea.Wrap
                        leftPadding: 12
                        rightPadding: 12
                        topPadding: 10
                        bottomPadding: 10
                        
                        background: Rectangle {
                            color: commandField.activeFocus ? "#1a1a1a" : "#262626"
                            border.color: commandField.activeFocus ? "#404040" : "#333333"
                            border.width: 1
                            radius: 6
                            
                            Behavior on color { ColorAnimation { duration: 150 } }
                            Behavior on border.color { ColorAnimation { duration: 150 } }
                        }
                        
                        color: "#10b981"  // 绿色代码风格
                        selectionColor: "#065f46"
                        selectedTextColor: "#ffffff"
                    }
                }
            }
            
            // 描述
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                visible: !commandDialog.folderMode
                
                Text {
                    text: "描述（可选）"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: "#525252"
                }
                
                TextField {
                    id: descField
                    placeholderText: "简要说明这条命令的用途"
                    Layout.fillWidth: true
                    font.pixelSize: 13
                    leftPadding: 12
                    rightPadding: 12
                    topPadding: 10
                    bottomPadding: 10
                    
                    background: Rectangle {
                        color: descField.activeFocus ? "#ffffff" : "#fafafa"
                        border.color: descField.activeFocus ? "#171717" : "#e5e5e5"
                        border.width: descField.activeFocus ? 2 : 1
                        radius: 6
                        
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                        Behavior on border.width { NumberAnimation { duration: 150 } }
                    }
                }
            }
        
            ComboBox {
                id: groupField
                editable: true
                model: commandDialog.model ? commandDialog.model.groups : []
                Layout.fillWidth: true
                height: 32
                font.pixelSize: 13


                popup: Popup {
                    y: groupField.height
                    width: groupField.width
                    implicitHeight: contentItem.implicitHeight
                    padding: 1

                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: groupField.popup.visible ? groupField.delegateModel : null
                        currentIndex: groupField.highlightedIndex

                        ScrollIndicator.vertical: ScrollIndicator { }
                    }

                    background: Rectangle {
                        border.color: "#e5e5e5"
                        border.width: 1
                        radius: 6
                    }
                }
                
                background: Rectangle {
                    //color: groupField.pressed ? "#f51e1e" : "#fafafa"
                    color: "#ffffff"
                    //border.color: groupField.activeFocus ? "#171717" : "#e5e5e5"
                    border.color: "#e5e5e5"
                    //border.width: groupField.activeFocus ? 2 : 1
                    border.width: 1
                    radius: 6
                    
                    Behavior on border.color { ColorAnimation { duration: 150 } }
                }
                
                contentItem: Text {
                    leftPadding: 12
                    rightPadding: groupField.indicator.width + 12
                    text: groupField.editText || groupField.displayText || "选择或输入分组名"
                    font: groupField.font
                    color: (groupField.editText || groupField.displayText) ? "#171717" : "#a3a3a3"
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                
                indicator: Text {
                    x: groupField.width - width - 12
                    y: (groupField.height - height) / 2
                    text: "▼"
                    font.pixelSize: 10
                    color: "#737373"
                }
            }
        }
        
        // 底部按钮区
        Rectangle {
            Layout.fillWidth: true
            height: 56
            color: "#fafafa"
            
            // 顶部分隔线
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: "#e5e5e5"
            }
            
            RowLayout {
                anchors.centerIn: parent
                anchors.right: parent.right
                anchors.rightMargin: 20
                spacing: 10
                
                // 取消按钮
                Rectangle {
                    width: 72
                    height: 34
                    radius: 6
                    color: cancelBtn.containsMouse ? "#f5f5f5" : "#ffffff"
                    border.color: "#e5e5e5"
                    border.width: 1
                    
                    Text {
                        anchors.centerIn: parent
                        text: "取消"
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: "#525252"
                    }
                    
                    MouseArea {
                        id: cancelBtn
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: commandDialog.reject()
                    }
                    
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
                
                // 确认按钮
                Rectangle {
                    width: 72
                    height: 34
                    radius: 0
                    color: confirmBtn.pressed ? "#000000" : (confirmBtn.containsMouse ? "#262626" : "#171717")
                    
                    Text {
                        anchors.centerIn: parent
                        text: commandDialog.editIndex === -1 ? "创建" : "保存"
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: "#ffffff"
                    }
                    
                    MouseArea {
                        id: confirmBtn
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: commandDialog.accept()
                    }
                    
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }
        }
    }
}