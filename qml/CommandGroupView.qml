import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts
import Qt.labs.qmlmodels
import QtQuick.Dialogs
import CommandManager 1.0

Window {
    id: groupDialog
    property var model
    property int editIndex: -1
    property bool folderMode: false
    property string parentGroup: ""
    
    model: CommandManager
    
    // Window属性
    modality: Qt.ApplicationModal
    //flags: Qt.Dialog | Qt.WindowCloseButtonHint
    title: editIndex === -1 ? qsTr("新建分组") : qsTr("编辑分组")
    
    // 窗口尺寸
    width: 480
    minimumWidth: 400
    minimumHeight: 300
    height: folderMode ? 300 : 520
    
    //color: "#ffffff"
    
    signal accepted()
    signal rejected()


    function openForAddFolder() {
        editIndex = -1
        folderMode = true
        parentGroup = ""
        titleFieldFolder.text = ""
        groupDialog.show()
        groupDialog.raise()
        groupDialog.requestActivate()
    }

    function openForAddFolderInGroup(group) {
        editIndex = -1
        folderMode = true
        parentGroup = group || ""
        titleFieldFolder.text = ""
        groupDialog.show()
        groupDialog.raise()
        groupDialog.requestActivate()
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

        groupDialog.show()
        groupDialog.raise()
        groupDialog.requestActivate()
    }
    
    function accept() {
        accepted()
        close()
    }
    
    function reject() {
        rejected()
        close()
    }

    function groupText() {
        return "Hello world"
    }

    onAccepted: {
        if (!model) return
        const g = parentGroup

        if (editIndex === -1)
            model.addFolder(titleFieldFolder.text, g)
        else
            model.editFolder(editIndex, titleFieldFolder.text, g)
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
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
                    text: "📁"
                    font.pixelSize: 20
                }
                
                // 标题
                Text {
                    text: groupDialog.editIndex === -1 ? "新建分组" : "编辑分组"
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
            // 标题输入（分组模式）
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                visible: groupDialog.folderMode
                
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
                        onClicked: groupDialog.reject()
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
                        text: groupDialog.editIndex === -1 ? "创建" : "保存"
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: "#ffffff"
                    }
                    
                    MouseArea {
                        id: confirmBtn
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: groupDialog.accept()
                    }
                    
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }
        }
    }
}