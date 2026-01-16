import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts
import Qt.labs.qmlmodels
import QtQuick.Dialogs
import CommandManager 1.0

ToolBar {
    id: appHeader
    height: 64
    padding: 12

    property alias searchField: searchInput

    background: Rectangle {
        color: "transparent"
        border.color: "transparent"
    }

    RowLayout {
        anchors.fill: parent
        spacing: 16
        anchors.leftMargin: 12
        anchors.rightMargin: 12

        ColumnLayout {
            Layout.preferredWidth: 220
            spacing: 2
            Label {
                text: "CMD BOX"
                font.bold: true
                font.pixelSize: 20
                color: textPrimary
            }
            Label {
                text: "快速管理你的常用命令"
                font.pixelSize: 12
                color: textSecondary
            }
        }

        // 侧边栏切换按钮
        ToolButton {
            id: sidebarToggle
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            onClicked: sidebarVisible = !sidebarVisible
            
            background: Rectangle {
                radius: 6
                color: sidebarToggle.pressed ? "#f0f0f0" : (sidebarToggle.hovered ? "#f5f5f5" : "transparent")
            }
            
            contentItem: Label {
                text: sidebarVisible ? "◀" : "▶"
                font.pixelSize: 12
                color: textSecondary
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            ToolTip.visible: hovered
            ToolTip.text: sidebarVisible ? "隐藏侧边栏" : "显示侧边栏"
            ToolTip.delay: 500
        }

        TextField {
            id: searchInput
            placeholderText: "搜索命令..."
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            Layout.alignment: Qt.AlignVCenter
            verticalAlignment: Text.AlignVCenter
            leftPadding: 12
            rightPadding: 12
            font.pixelSize: 14
            onTextChanged: {
                if (CommandManager) 
                    CmmandManager.setFilter(text)
            }
            background: Rectangle {
                color: "#f5f5f5" // Slight gray for input area
                radius: 6
                border.color: "transparent" // Flat style usually has no border or minimal
                border.width: 0 
                
                // Add a focus indicator
                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    color: "transparent"
                    border.color: searchInput.activeFocus ? primary : "transparent"
                    border.width: 1.5
                }
            }
        }

        ToolButton {
            id: menuButton
            text: "⋮"
            font.pixelSize: 20
            anchors.verticalCenter: parent.verticalCenter
            onClicked: optionsMenu.open()
            background: Rectangle {
                implicitWidth: 40
                implicitHeight: 40
                radius: 12
                color: menuButton.pressed ? "#f5f5f5" : "transparent"
                border.color: menuButton.pressed ? subtleBorder : "transparent"
                border.width: menuButton.pressed ? 1 : 0
            }
            contentItem: Label { text: menuButton.text; color: textSecondary; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            scale: menuButton.pressed ? 0.95 : 1.0
            Behavior on scale { NumberAnimation { duration: 100 } }
        }

        Menu {
            id: optionsMenu
            x: menuButton.x
            y: menuButton.y + menuButton.height
            MenuItem {
                text: "导入数据"
                onTriggered: importDialog.open()
            }
            MenuItem {
                text: "导出数据"
                onTriggered: exportDialog.open()
            }
        }
    }
}