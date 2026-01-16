import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Dialogs
import CommandManager 1.0

Popup {
    id: copyNotification
    property alias text: notificationText.text
    width: notificationText.implicitWidth + 32
    height: 40
    x: (parent.width - width) / 2
    y: parent.height - height - 24
    closePolicy: Popup.NoAutoClose
    
    Timer {
        id: notificationTimer
        interval: 2000
        onTriggered: copyNotification.close()
    }
    
    function open() {
        visible = true
        notificationTimer.restart()
    }

    background: Rectangle {
        color: textPrimary
        radius: 8
        opacity: 0.95
    }
    
    contentItem: Text {
        id: notificationText
        text: "命令已复制到剪贴板"
        color: "white"
        font.pixelSize: 13
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}