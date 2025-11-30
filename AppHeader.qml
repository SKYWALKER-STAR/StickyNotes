import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts

ToolBar {
    id: header
    property var commandManager
    height: 60
    padding: 10

    signal importRequested()
    signal exportRequested()

    property alias searchField: searchInput

    background: Rectangle {
        color: "#f5f5f5"
        border.color: "#e0e0e0"
        border.width: 1
    }

    RowLayout {
        anchors.fill: parent
        spacing: 15

        Label {
            text: "CMD BOX"
            font.bold: true
            font.pixelSize: 20
            Layout.alignment: Qt.AlignVCenter
            color: "#333333"
            leftPadding: 10
        }

        TextField {
            id: searchInput
            placeholderText: "搜索命令..."
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignVCenter
            verticalAlignment: Text.AlignVCenter
            leftPadding: 10
            onTextChanged: {
                if (commandManager)
                    commandManager.setFilter(text)
            }
            background: Rectangle {
                color: "white"
                radius: 8
                border.color: searchInput.activeFocus ? "#2196F3" : "#e0e0e0"
                border.width: 1
            }
        }

        ToolButton {
            id: menuButton
            text: "⋮"
            font.pixelSize: 24
            anchors.verticalCenter: parent.verticalCenter
            onClicked: optionsMenu.open()
            background: Rectangle {
                implicitWidth: 40
                implicitHeight: 40
                radius: 20
                color: menuButton.pressed ? "#d0d0d0" : "transparent"
            }
        }

        Menu {
            id: optionsMenu
            x: menuButton.x
            y: menuButton.y + menuButton.height
            MenuItem {
                text: "导入数据"
                onTriggered: header.importRequested()
            }
            MenuItem {
                text: "导出数据"
                onTriggered: header.exportRequested()
            }
        }
    }
}
