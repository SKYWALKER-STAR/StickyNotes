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
                text: "Sticky Note"
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

        TextField {
            id: searchInput
            placeholderText: "搜索命令..."
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            Layout.alignment: Qt.AlignVCenter
            verticalAlignment: Text.AlignVCenter
            leftPadding: 14
            rightPadding: 32
            font.pixelSize: 14
            onTextChanged: {
                if (CommandManager) 
                    CommandManager.setFilter(text)
            }
            background: Rectangle {
                color: "#f8f8f8"
                radius: 10
                border.color: searchInput.activeFocus ? primary : "#e5e5e5"
                border.width: searchInput.activeFocus ? 2 : 1
                Behavior on border.color { ColorAnimation { duration: 120 } }
                Behavior on border.width { NumberAnimation { duration: 120 } }
            }

            ToolButton {
                id: headerClearBtn
                visible: searchInput.text.length > 0
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                width: 22
                height: 22
                flat: true
                contentItem: Label {
                    text: "✕"
                    font.pixelSize: 11
                    color: textSecondary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    radius: 11
                    color: parent.hovered ? "#e5e5e5" : "transparent"
                }
                onClicked: {
                    searchInput.text = ""
                    searchInput.forceActiveFocus()
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