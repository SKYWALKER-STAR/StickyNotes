import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.qmlmodels

Popup {
    id: guideDialog
    modal: true
    focus: true
    padding: 0
    anchors.centerIn: Overlay.overlay
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    width: 420
    height: 400
    
    readonly property int rowHeight: 44
    readonly property int headerHeight: 30
    readonly property int footerHeight: 30
    readonly property int leftColWidth: 150
    readonly property int tableMaxWidth: 380
    readonly property int tableMaxHeight: 360

    Rectangle {
        id: popUpInnerRect
        anchors.fill: parent
        color: "#dad9d9"
        ColumnLayout {
            anchors.fill: parent
            spacing: 0
            Rectangle {
                id: popUpHeader
                anchors.top: parent.top
                Layout.fillWidth: true
                Layout.preferredHeight: guideDialog.headerHeight
                border.width: 0
                border.color: "#ffffff"
                Text {
                    anchors.centerIn: parent
                    font.family: "Monospace"
                    text: "快捷键指南"
                    font.bold: true
                    font.pixelSize: 13
                    color: textPrimary
                }
            }
            Rectangle {
                anchors.top: popUpHeader.bottom
                anchors.margins: 0
                Layout.fillWidth: true
                Layout.preferredHeight: popUpInnerRect.height -  guideDialog.headerHeight
                border.width: 0
                border.color: "#ffffff"
                TableView {
                    id: tableView
                    width: parent.width
                    anchors.fill: parent
                    height: Math.min(parent.height - headerHeight, tableMaxHeight)
                    clip: true

                    model: TableModel {
                        TableModelColumn { display: "key" }
                        TableModelColumn { display: "desc" }

                        rows: [
                            { key: "Ctrl + N",         desc: "新建命令" },
                            { key: "Ctrl + Shift + N", desc: "新建分组" },
                            { key: "Ctrl + F",         desc: "搜索命令" },
                            { key: "Ctrl + B",         desc: "显示 / 隐藏侧边栏" },
                            { key: "Ctrl + I",         desc: "导入数据" },
                            { key: "Ctrl + E",         desc: "导出数据" },
                            { key: "F5",               desc: "刷新列表" },
                            { key: "Ctrl + Q",         desc: "退出程序" }
                        ]
                    }

                    rowHeightProvider: function() { return guideDialog.rowHeight }

                    columnWidthProvider: function(column) {
                        return column === 0 ? guideDialog.leftColWidth
                                            : tableView.width - guideDialog.leftColWidth
                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }

                    delegate: Rectangle {
                        border.color: "#c6c6c6f9"
                        border.width: 0
                        implicitHeight: guideDialog.rowHeight
                        color: row % 2 ? "#f8f8f8" : "#dedddd"

                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 1
                            color: "#eeeeee"
                        }

                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            maximumLineCount: column === 0 ? 1 : 2
                            elide: Text.ElideRight

                            font.pixelSize: 13
                            color: "#222222"
                            text: display
                        }
                    }
                }
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: guideDialog.headerHeight
                border.width: 0
                border.color: "#ffffff"
                Button { 
                    anchors.fill: parent
                    text: "确定"
                    onClicked: guideDialog.close() 
                }
            }
        }
    }
}
