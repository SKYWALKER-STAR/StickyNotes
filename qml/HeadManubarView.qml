import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts

MenuBar {
        id: headMenuBar
        
        background: Rectangle {
            color: bgColor
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: subtleBorder
            }
        }
        
        delegate: MenuBarItem {
            id: menuBarItem
            
            contentItem: Text {
                text: menuBarItem.text
                font.pixelSize: 13
                font.family: uiFont
                color: menuBarItem.highlighted ? primaryDark : textSecondary
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
            
            background: Rectangle {
                implicitWidth: 40
                implicitHeight: 32
                color: menuBarItem.highlighted ? menuHoverColor : "transparent"
                radius: 4
            }
        }
        
        // 文件菜单
        Menu {
            id: fileMenu
            title: qsTr("文件")
            
            background: Rectangle {
                implicitWidth: 220
                implicitHeight: fileMenu.contentHeight + 16
                color: "#ffffff"
                border.color: subtleBorder
                border.width: 1
                radius: 8
                opacity: 1
            }
            
            delegate: MenuItem {
                id: fileMenuItem
                implicitWidth: 200
                implicitHeight: 36
                
                contentItem: RowLayout {
                    spacing: 12
                    
                    Text {
                        text: fileMenuItem.text
                        font.pixelSize: 13
                        font.family: uiFont
                        color: fileMenuItem.enabled ? textPrimary : textSecondary
                        Layout.fillWidth: true
                    }
                    
                    Text {
                        text: {
                            if (fileMenuItem.action && fileMenuItem.action.shortcut)
                                return fileMenuItem.action.shortcut
                            return ""
                        }
                        font.pixelSize: 11
                        font.family: uiFont
                        color: textSecondary
                        visible: text !== ""
                    }
                }
                
                background: Rectangle {
                    color: fileMenuItem.highlighted ? menuHoverColor : "transparent"
                    radius: 4
                    anchors.margins: 4
                }
            }
            
            Action {
                text: qsTr("新建命令")
                shortcut: "Ctrl+N"
                onTriggered: commandDialog.openForAdd()
            }
            
            Action {
                text: qsTr("新建分组")
                shortcut: "Ctrl+Shift+N"
                onTriggered: commandDialog.openForAddFolder()
            }
            
            MenuSeparator {
                contentItem: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 1
                    color: subtleBorder
                }
            }
            
            Action {
                text: qsTr("导入数据...")
                shortcut: "Ctrl+I"
                onTriggered: importDialog.open()
            }
            
            Action {
                text: qsTr("导出数据...")
                shortcut: "Ctrl+E"
                onTriggered: exportDialog.open()
            }
            
            MenuSeparator {
                contentItem: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 1
                    color: subtleBorder
                }
            }
            
            Action {
                text: qsTr("退出")
                shortcut: "Ctrl+Q"
                onTriggered: Qt.quit()
            }
        }
        
        // 编辑菜单
        Menu {
            id: editMenu
            title: qsTr("编辑")
            
            background: Rectangle {
                implicitWidth: 220
                implicitHeight: editMenu.contentHeight + 16
                color: "#ffffff"
                border.color: subtleBorder
                border.width: 1
                radius: 8
                opacity: 1
            }
            
            delegate: MenuItem {
                id: editMenuItem
                implicitWidth: 200
                implicitHeight: 36
                
                contentItem: RowLayout {
                    spacing: 12
                    
                    Text {
                        text: editMenuItem.text
                        font.pixelSize: 13
                        font.family: uiFont
                        color: editMenuItem.enabled ? textPrimary : textSecondary
                        Layout.fillWidth: true
                    }
                    
                    Text {
                        text: {
                            if (editMenuItem.action && editMenuItem.action.shortcut)
                                return editMenuItem.action.shortcut
                            return ""
                        }
                        font.pixelSize: 11
                        font.family: uiFont
                        color: textSecondary
                        visible: text !== ""
                    }
                }
                
                background: Rectangle {
                    color: editMenuItem.highlighted ? menuHoverColor : "transparent"
                    radius: 4
                    anchors.margins: 4
                }
            }
            
            Action {
                text: qsTr("搜索")
                shortcut: "Ctrl+F"
                onTriggered: appHeader.searchField.forceActiveFocus()
            }
            
            MenuSeparator {
                contentItem: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 1
                    color: subtleBorder
                }
            }
            
            Action {
                text: qsTr("刷新列表")
                shortcut: "F5"
                onTriggered: {
                    if (commandManager) {
                        commandManager.setFilter("")
                        appHeader.searchField.text = ""
                    }
                }
            }
        }
        
        // 视图菜单
        Menu {
            id: viewMenu
            title: qsTr("视图")
            
            background: Rectangle {
                implicitWidth: 220
                implicitHeight: viewMenu.contentHeight + 16
                color: "#ffffff"
                border.color: subtleBorder
                border.width: 1
                radius: 8
                opacity: 1
            }
            
            delegate: MenuItem {
                id: viewMenuItem
                implicitWidth: 200
                implicitHeight: 36
                
                contentItem: RowLayout {
                    spacing: 12
                    
                    Text {
                        text: viewMenuItem.text
                        font.pixelSize: 13
                        font.family: uiFont
                        color: viewMenuItem.enabled ? textPrimary : textSecondary
                        Layout.fillWidth: true
                    }
                    
                    Text {
                        text: {
                            if (viewMenuItem.action && viewMenuItem.action.shortcut)
                                return viewMenuItem.action.shortcut
                            return ""
                        }
                        font.pixelSize: 11
                        font.family: uiFont
                        color: textSecondary
                        visible: text !== ""
                    }
                    
                    // 复选标记
                    Text {
                        text: viewMenuItem.checkable && viewMenuItem.checked ? "✓" : ""
                        font.pixelSize: 12
                        color: primary
                        visible: viewMenuItem.checkable
                    }
                }
                
                background: Rectangle {
                    color: viewMenuItem.highlighted ? menuHoverColor : "transparent"
                    radius: 4
                    anchors.margins: 4
                }
            }
            
            Action {
                text: qsTr("显示侧边栏")
                shortcut: "Ctrl+B"
                checkable: true
                checked: sidebarVisible
                onTriggered: sidebarVisible = !sidebarVisible
            }
            
            MenuSeparator {
                contentItem: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 1
                    color: subtleBorder
                }
            }
            
            Action {
                text: qsTr("展开所有分组")
                onTriggered: {
                    if (sidebarTree) {
                        // 触发侧边栏展开所有
                    }
                }
            }
            
            Action {
                text: qsTr("收起所有分组")
                onTriggered: {
                    if (sidebarTree) {
                        // 触发侧边栏收起所有
                    }
                }
            }
        }
        
        // 帮助菜单
        Menu {
            id: helpMenu
            title: qsTr("帮助")
            
            background: Rectangle {
                implicitWidth: 220
                implicitHeight: helpMenu.contentHeight + 16
                color: "#ffffff"
                border.color: subtleBorder
                border.width: 1
                radius: 8
                opacity: 1
            }
            
            delegate: MenuItem {
                id: helpMenuItem
                implicitWidth: 200
                implicitHeight: 36
                
                contentItem: RowLayout {
                    spacing: 12
                    
                    Text {
                        text: helpMenuItem.text
                        font.pixelSize: 13
                        font.family: uiFont
                        color: helpMenuItem.enabled ? textPrimary : textSecondary
                        Layout.fillWidth: true
                    }
                }
                
                background: Rectangle {
                    color: helpMenuItem.highlighted ? menuHoverColor : "transparent"
                    radius: 4
                    anchors.margins: 4
                }
            }
            
            Action {
                text: qsTr("快捷键指南")
                onTriggered: shortcutGuideDialog.open()
            }
            
            MenuSeparator {
                contentItem: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 1
                    color: subtleBorder
                }
            }
            
            Action {
                text: qsTr("关于 CMD BOX")
                onTriggered: aboutDialogView.open()
            }
        }
    }

