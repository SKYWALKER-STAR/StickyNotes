import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: preview
    modal: true
    focus: true
    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    //anchors.centerIn: parent
    width: Math.min(parent ? parent.width * 0.9 : 800, 800)
    height: Math.min(parent ? parent.height * 0.8 : 500, 500)

    property string winTitle: "命令查看"
    property string cmdText: ""

    function openWith(titleStr, cmdStr) {
        winTitle = titleStr && titleStr.length ? titleStr : "命令查看"
        cmdText = cmdStr
        open()
        cmdArea.forceActiveFocus()
        cmdArea.selectAll()
    }

    // 半透明遮罩可在 Main.qml 的 Overlay.modal 配置，见下方
    background: Rectangle { radius: 8; color: "#ffffff"; border.color: "#dddddd" }

    contentItem: ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        Label { text: preview.winTitle; font.bold: true; Layout.fillWidth: true }

        TextArea {
            id: cmdArea
            text: preview.cmdText
            readOnly: true
            wrapMode: TextEdit.NoWrap
            font.family: "Monospace"
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 8
            Button {
                text: "复制"
                onClicked: if (typeof commandManager !== "undefined") commandManager.copyToClipboard(cmdArea.text)
            }
            Button { text: "关闭"; onClicked: preview.close() }
        }
    }
}