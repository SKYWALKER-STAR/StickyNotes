import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Dialogs
import CommandManager 1.0

ApplicationWindow {
    id: appWindow
    visible: true
    width: 1000
    height: 650
    minimumWidth: 700
    minimumHeight: 400
    title: "CMD BOX"

    // 全局主题变量（经典黑白 - 现代极简）
    property color bgColor: "#ffffff"      // 纯白背景
    property color cardColor: "#ffffff"
    property color subtleBorder: "#e5e5e5" // 极浅灰边框
    property color primary: "#171717"      // 几乎纯黑
    property color primaryDark: "#000000"  // 纯黑
    property color accent: "#525252"       // 中灰
    property color textPrimary: "#0a0a0a"  // 墨黑
    property color textSecondary: "#737373" // 深灰
    property color menuHoverColor: "#f5f5f5" // 菜单悬停色
    property string uiFont: "Segoe UI, Roboto, Noto Sans, Arial"
    
    // 侧边栏控制
    property bool sidebarVisible: true
    property real sidebarWidth: 240

    font.family: uiFont

    Rectangle {
        anchors.fill: parent
        color: bgColor
    }

    Component.onCompleted: {
        if (CommandManager)
            CommandManager.initialize()
    }

    Shortcut {
        sequence: "Ctrl+F"
        onActivated: appHeader.searchField.forceActiveFocus()
    }

    Shortcut {
        sequence: "Ctrl+N"
        onActivated: commandDialogView.openForAdd()
    }
    Item {
        states: State { name: "running" }
    }
    
    // 现代化扁平菜单栏
    menuBar: HeadManubarView {
        id: mainMenuBar
    }

    // 快捷键指南
    ShortcutGuideDialog {
        id: shortcutGuideDialog
        parent: appWindow
    }
    
    // 关于对话框
    AboutDialogView {
        id: aboutDialogView 
    }
    
    // 顶部搜索框
    header: HeaderToolbarView {
        id: headerToolbarView
    }

    contentData: RowLayout {
        anchors.fill: parent
        spacing: 0
        
        // 左侧边栏
        SidebarTreeView {
            id: sidebarTree
            Layout.preferredWidth: sidebarVisible ? sidebarWidth : 0
            Layout.fillHeight: true
            visible: sidebarVisible
            
            // 传递主题变量
            bgColor: appWindow.bgColor
            cardColor: appWindow.cardColor
            subtleBorder: appWindow.subtleBorder
            primary: appWindow.primary
            primaryDark: appWindow.primaryDark
            accent: appWindow.accent
            textPrimary: appWindow.textPrimary
            textSecondary: appWindow.textSecondary
            
            commandManager: CommandManager
            
            onGroupSelected: function(groupName) {
                // 可选：按分组筛选
                if (commandManager) {
                    commandManager.setGroupFilter(groupName)
                }
            }
            
            onItemClicked: function(index, isFolder) {
                if (!isFolder) {
                    // 命令被点击，显示复制提示
                    copyNotification.text = "已复制命令"
                    copyNotification.open()
                }
            }
            
            // 展开/收起动画
            Behavior on Layout.preferredWidth {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            onCommandManagerChanged: {
                console.log("SidebarTreeView: commandManager changed:", commandManager)
                if (commandManager) {
                    console.log("CommandManager is valid")
                    treeList.model = treeList.buildTreeModel()
                } else {
                    console.log("CommandManager is null!")
                }
            }
        }
        // 主内容区域
        MainDataListView {
            id: mainDataListView
        }
    }  // 关闭 RowLayout (contentData)

    CommandDialogView {
        id: commandDialogView
    }

    // 复制信息提示
    CopyNotificationView {
        id: copyNotificationView
    }

    // 导入数据
    ImportDialogView {
        id: importDialogView
    }

    // 导出数据
    ExportDialogView {
        id: exportDialogView
    }

    CommandBlok { id: previewWin }
}