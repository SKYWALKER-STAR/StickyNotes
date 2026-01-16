import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts
import Qt.labs.qmlmodels

Dialog {
    id: aboutDialog
    title: "关于 CMD BOX"
    modal: true
    anchors.centerIn: parent
    width: 360
    standardButtons: Dialog.Ok
    
    background: Rectangle {
        color: cardColor
        border.color: subtleBorder
        radius: 12
    }
    
    contentItem: ColumnLayout {
        spacing: 16
        
        Label {
            text: "CMD BOX"
            font.bold: true
            font.pixelSize: 24
            color: textPrimary
            Layout.alignment: Qt.AlignHCenter
        }
        
        Label {
            text: "版本 1.0.0"
            font.pixelSize: 13
            color: textSecondary
            Layout.alignment: Qt.AlignHCenter
        }
        
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: subtleBorder
        }
        
        Label {
            text: "快速管理你的常用命令\n一款现代化的命令管理工具"
            font.pixelSize: 13
            color: textSecondary
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }
        
        Label {
            text: "© 2024-2026 OpsTools"
            font.pixelSize: 11
            color: textSecondary
            Layout.alignment: Qt.AlignHCenter
        }
    }
}  