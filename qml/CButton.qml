import QtQuick
import QtQuick.Controls 2.15

Button {
    id: control
    property string theme: "primary" // primary, warning, danger, success, neutral
    flat: true
    font.bold: true

    property color mainColor: {
        switch (theme) {
            case "primary": return "#171717"
            case "warning": return "#404040"
            case "danger":  return "#000000"
            case "success": return "#262626"
            case "neutral": return "#ffffff"
            default: return "#171717"
        }
    }
    
    property color textColor: theme === "neutral" ? "#171717" : "#ffffff"
    property color borderColor: theme === "neutral" ? "#e5e5e5" : "transparent"

    contentItem: Text {
        text: control.text
        font: control.font
        color: control.textColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        implicitWidth: 60
        implicitHeight: 30
        radius: 4 // More squared/modern
        color: theme === "neutral" ? 
               (control.pressed ? "#f5f5f5" : (control.hovered ? "#fafafa" : mainColor)) :
               (control.pressed ? Qt.darker(mainColor, 1.2) : (control.hovered ? Qt.lighter(mainColor, 1.2) : mainColor))
        
        border.color: borderColor
        border.width: theme === "neutral" ? 1 : 0
    }

    // Interaction animation
    scale: control.pressed ? 0.94 : (control.hovered ? 1.05 : 1.0)
    Behavior on scale { 
        NumberAnimation { duration: 150; easing.type: Easing.OutBack } 
    }
}
