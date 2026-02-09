import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts
import CommandManager 1.0

Rectangle {
    id: workspace
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: "#fafafa"

    // 主题变量
    property color cardColor: "#ffffff"
    property color subtleBorder: "#e5e5e5"
    property color primary: "#171717"
    property color textPrimary: "#0a0a0a"
    property color textSecondary: "#737373"
    property color accent: "#525252"

    // 外部引用
    property var commandDialog: null
    property var copyNotification: null
    property var previewWin: null

    // 信号
    signal commandDeleted()

    // ── 标签页数据模型 ──
    ListModel {
        id: tabsModel
    }

    property int activeTabIndex: -1
    property bool hasTabs: tabsModel.count > 0

    // 防止切换标签时的循环更新
    property bool _switching: false

    // ── 打开命令（新标签或切到已有标签）──
    function openCommand(index, title, cmd, description, group) {
        for (var i = 0; i < tabsModel.count; i++) {
            if (tabsModel.get(i).sourceIndex === index) {
                activeTabIndex = i
                return
            }
        }
        tabsModel.append({
            tabId: Date.now(),
            sourceIndex: index,
            origTitle: title || "",
            origCommand: cmd || "",
            origDescription: description || "",
            origGroup: group || "",
            editTitle: title || "",
            editCommand: cmd || "",
            editDescription: description || "",
            editGroup: group || "",
            dirty: false
        })
        activeTabIndex = tabsModel.count - 1
    }

    // ── 关闭标签 ──
    function closeTab(tabIndex) {
        if (tabIndex < 0 || tabIndex >= tabsModel.count) return
        if (tabsModel.get(tabIndex).dirty) {
            pendingCloseIndex = tabIndex
            unsavedCloseDialog.open()
            return
        }
        doCloseTab(tabIndex)
    }

    property int pendingCloseIndex: -1

    function doCloseTab(tabIndex) {
        tabsModel.remove(tabIndex)
        if (tabsModel.count === 0) {
            activeTabIndex = -1
        } else if (activeTabIndex >= tabsModel.count) {
            activeTabIndex = tabsModel.count - 1
        } else if (activeTabIndex === tabIndex) {
            var newIdx = Math.min(tabIndex, tabsModel.count - 1)
            activeTabIndex = -1
            activeTabIndex = newIdx
        }
    }

    // ── 保存当前标签 ──
    function saveCurrentTab() {
        if (activeTabIndex < 0 || activeTabIndex >= tabsModel.count) return
        var tab = tabsModel.get(activeTabIndex)
        if (!tab.dirty) return

        if (CommandManager && tab.sourceIndex >= 0) {
            CommandManager.editCommand(
                tab.sourceIndex,
                tab.editTitle,
                tab.editCommand,
                tab.editDescription,
                tab.editGroup
            )
            tabsModel.setProperty(activeTabIndex, "origTitle", tab.editTitle)
            tabsModel.setProperty(activeTabIndex, "origCommand", tab.editCommand)
            tabsModel.setProperty(activeTabIndex, "origDescription", tab.editDescription)
            tabsModel.setProperty(activeTabIndex, "origGroup", tab.editGroup)
            tabsModel.setProperty(activeTabIndex, "dirty", false)
        }
    }

    // ── 检查脏状态 ──
    function checkDirty(tabIndex) {
        if (tabIndex < 0 || tabIndex >= tabsModel.count) return
        var tab = tabsModel.get(tabIndex)
        var isDirty = (tab.editTitle !== tab.origTitle) ||
                      (tab.editCommand !== tab.origCommand) ||
                      (tab.editDescription !== tab.origDescription) ||
                      (tab.editGroup !== tab.origGroup)
        tabsModel.setProperty(tabIndex, "dirty", isDirty)
    }

    // 切换标签时同步编辑字段
    onActiveTabIndexChanged: {
        if (_switching) return
        _switching = true
        syncFieldsFromTab()
        _switching = false
    }

    function syncFieldsFromTab() {
        if (activeTabIndex < 0 || activeTabIndex >= tabsModel.count) return
        var tab = tabsModel.get(activeTabIndex)
        titleField.text = tab.editTitle
        cmdBarField.text = tab.editCommand
        detailTitleField.text = tab.editTitle
        detailGroupField.text = tab.editGroup
        cmdEditArea.text = tab.editCommand
        descEditArea.text = tab.editDescription
    }

    // Ctrl+S 保存
    Shortcut {
        sequence: "Ctrl+S"
        onActivated: saveCurrentTab()
    }

    // Ctrl+W 关闭标签
    Shortcut {
        sequence: "Ctrl+W"
        onActivated: {
            if (activeTabIndex >= 0) closeTab(activeTabIndex)
        }
    }

    // ── 空状态 ──
    Item {
        anchors.fill: parent
        visible: !hasTabs

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 16

            Label {
                text: "⌘"
                font.pixelSize: 56
                color: "#d4d4d4"
                Layout.alignment: Qt.AlignHCenter
            }
            Label {
                text: "选择一个命令开始"
                font.pixelSize: 16
                font.weight: Font.Medium
                color: textSecondary
                Layout.alignment: Qt.AlignHCenter
            }
            Label {
                text: "在左侧导航栏中点击命令，即可在此查看详情"
                font.pixelSize: 13
                color: "#a3a3a3"
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    // ── 主布局 ──
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        visible: hasTabs

        // ═══════════════ 标签栏 ═══════════════
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            color: "#f0f0f0"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 0
                spacing: 0

                ListView {
                    id: tabBar
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    orientation: ListView.Horizontal
                    model: tabsModel
                    clip: true
                    spacing: 0

                    delegate: Rectangle {
                        id: tabDelegate
                        width: Math.min(tabLabelText.implicitWidth + 56, 200)
                        height: tabBar.height
                        color: index === activeTabIndex ? cardColor : (tabHover.hovered ? "#e8e8e8" : "transparent")

                        Behavior on color { ColorAnimation { duration: 100 } }

                        // 底部活跃指示线
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 2
                            color: primary
                            visible: index === activeTabIndex
                        }

                        // 右侧分隔线
                        Rectangle {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: 1
                            height: parent.height - 12
                            color: subtleBorder
                            opacity: 0.5
                            visible: index !== activeTabIndex
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 4
                            spacing: 6

                            // 红点（脏状态指示）
                            Rectangle {
                                width: 8
                                height: 8
                                radius: 4
                                color: "#ef4444"
                                visible: model.dirty
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Label {
                                id: tabLabelText
                                text: model.editTitle || "未命名"
                                font.pixelSize: 12
                                font.weight: index === activeTabIndex ? Font.DemiBold : Font.Normal
                                color: index === activeTabIndex ? textPrimary : textSecondary
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                            }

                            // 关闭按钮
                            ToolButton {
                                Layout.preferredWidth: 20
                                Layout.preferredHeight: 20
                                Layout.alignment: Qt.AlignVCenter
                                flat: true
                                contentItem: Label {
                                    text: "✕"
                                    font.pixelSize: 9
                                    color: parent.hovered ? textPrimary : textSecondary
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                background: Rectangle {
                                    radius: 4
                                    color: parent.hovered ? "#d4d4d4" : "transparent"
                                }
                                onClicked: closeTab(index)
                            }
                        }

                        HoverHandler { id: tabHover }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                            z: -1
                            onClicked: function(mouse) {
                                if (mouse.button === Qt.MiddleButton)
                                    closeTab(index)
                                else
                                    activeTabIndex = index
                            }
                        }
                    }
                }

                Item { Layout.fillWidth: true }
            }

            // 底线
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: subtleBorder
            }
        }

        // ═══════════════ 活跃标签内容 ═══════════════
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0
            visible: activeTabIndex >= 0 && activeTabIndex < tabsModel.count

            // ── 顶部操作栏 ──
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 56
                color: cardColor

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 24
                    anchors.rightMargin: 24
                    spacing: 10

                    // CMD 标签
                    Rectangle {
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 26
                        radius: 4
                        color: "#171717"
                        Label {
                            anchors.centerIn: parent
                            text: "CMD"
                            font.pixelSize: 11
                            font.bold: true
                            color: "#ffffff"
                        }
                    }

                    // 标题（可编辑）
                    TextField {
                        id: titleField
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                        color: textPrimary
                        placeholderText: "命令名称"
                        Layout.fillWidth: true
                        background: Rectangle {
                            color: titleField.activeFocus ? "#f5f5f5" : "transparent"
                            radius: 6
                            border.color: titleField.activeFocus ? subtleBorder : "transparent"
                        }
                        onTextEdited: {
                            if (_switching) return
                            if (activeTabIndex >= 0 && activeTabIndex < tabsModel.count) {
                                tabsModel.setProperty(activeTabIndex, "editTitle", text)
                                detailTitleField.text = text
                                checkDirty(activeTabIndex)
                            }
                        }
                    }

                    // 保存按钮（仅脏状态时显示）
                    CButton {
                        text: "💾 保存"
                        theme: "primary"
                        visible: activeTabIndex >= 0 && activeTabIndex < tabsModel.count && tabsModel.get(activeTabIndex).dirty
                        onClicked: saveCurrentTab()
                    }

                    CButton {
                        text: "复制"
                        theme: "neutral"
                        onClicked: {
                            if (CommandManager && activeTabIndex >= 0 && activeTabIndex < tabsModel.count) {
                                var tab = tabsModel.get(activeTabIndex)
                                CommandManager.copyToClipboard(tab.editCommand)
                                if (copyNotification) {
                                    copyNotification.text = "已复制: " + tab.editTitle
                                    copyNotification.open()
                                }
                            }
                        }
                    }

                    CButton {
                        text: "删除"
                        theme: "danger"
                        onClicked: deleteConfirmDialog.open()
                    }

                    CButton {
                        text: "</>"
                        theme: "success"
                        flat: true
                        implicitWidth: 40
                        onClicked: {
                            if (previewWin && activeTabIndex >= 0 && activeTabIndex < tabsModel.count) {
                                var tab = tabsModel.get(activeTabIndex)
                                previewWin.openWith(tab.editTitle, tab.editCommand)
                            }
                        }
                    }
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: subtleBorder
                }
            }

            // ── 命令栏（Postman URL 栏风格）──
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                Layout.leftMargin: 24
                Layout.rightMargin: 24
                Layout.topMargin: 16
                color: cardColor
                radius: 8
                border.color: cmdBarField.activeFocus ? primary : subtleBorder
                border.width: cmdBarField.activeFocus ? 2 : 1

                Behavior on border.color { ColorAnimation { duration: 150 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 8
                    spacing: 8

                    Label {
                        text: "❯"
                        font.pixelSize: 16
                        font.bold: true
                        color: accent
                        Layout.preferredWidth: 20
                    }

                    TextField {
                        id: cmdBarField
                        selectByMouse: true
                        font.family: "Consolas, Courier New, monospace"
                        font.pixelSize: 13
                        color: textPrimary
                        placeholderText: "输入命令..."
                        Layout.fillWidth: true
                        background: Item {}
                        onTextEdited: {
                            if (_switching) return
                            if (activeTabIndex >= 0 && activeTabIndex < tabsModel.count) {
                                tabsModel.setProperty(activeTabIndex, "editCommand", text)
                                cmdEditArea.text = text
                                checkDirty(activeTabIndex)
                            }
                        }
                    }

                    ToolButton {
                        Layout.preferredWidth: 34
                        Layout.preferredHeight: 34
                        flat: true
                        contentItem: Label {
                            text: "📋"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            radius: 6
                            color: parent.pressed ? "#e5e5e5" : (parent.hovered ? "#f0f0f0" : "transparent")
                        }
                        ToolTip.visible: hovered
                        ToolTip.text: "复制命令"
                        ToolTip.delay: 300
                        onClicked: {
                            if (CommandManager && activeTabIndex >= 0 && activeTabIndex < tabsModel.count) {
                                CommandManager.copyToClipboard(tabsModel.get(activeTabIndex).editCommand)
                                if (copyNotification) {
                                    copyNotification.text = "已复制"
                                    copyNotification.open()
                                }
                            }
                        }
                    }
                }
            }

            // ── 详情/说明 Tab 栏 ──
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                Layout.leftMargin: 24
                Layout.rightMargin: 24
                Layout.topMargin: 12
                color: "transparent"

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Repeater {
                        model: [
                            { label: "详情", tab: 0 },
                            { label: "说明", tab: 1 }
                        ]

                        delegate: Rectangle {
                            Layout.preferredWidth: 72
                            Layout.fillHeight: true
                            color: "transparent"
                            property bool isActive: contentStack.currentIndex === modelData.tab

                            Label {
                                anchors.centerIn: parent
                                text: modelData.label
                                font.pixelSize: 13
                                font.weight: isActive ? Font.DemiBold : Font.Normal
                                color: isActive ? textPrimary : textSecondary
                            }

                            Rectangle {
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: parent.width - 16
                                height: 2
                                radius: 1
                                color: primary
                                visible: isActive
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: contentStack.currentIndex = modelData.tab
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: subtleBorder
                }
            }

            // ── 内容区 ──
            StackLayout {
                id: contentStack
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: 0

                // ══════ Tab 0: 详情（可编辑表单）══════
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    ColumnLayout {
                        width: contentStack.width
                        spacing: 0

                        // ── 命令名称 ──
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 56
                            color: "#ffffff"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 24
                                anchors.rightMargin: 24
                                spacing: 16

                                Label {
                                    text: "命令名称"
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                    color: textSecondary
                                    Layout.preferredWidth: 80
                                    Layout.alignment: Qt.AlignVCenter
                                }
                                TextField {
                                    id: detailTitleField
                                    font.pixelSize: 13
                                    color: textPrimary
                                    placeholderText: "命令名称"
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    background: Rectangle {
                                        color: detailTitleField.activeFocus ? "#f9f9f9" : "transparent"
                                        radius: 4
                                        border.color: detailTitleField.activeFocus ? subtleBorder : "transparent"
                                    }
                                    onTextEdited: {
                                        if (_switching) return
                                        if (activeTabIndex >= 0 && activeTabIndex < tabsModel.count) {
                                            tabsModel.setProperty(activeTabIndex, "editTitle", text)
                                            titleField.text = text
                                            checkDirty(activeTabIndex)
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
                                height: 1; color: subtleBorder; opacity: 0.4
                            }
                        }

                        // ── 所属分组 ──
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 56
                            color: "#fafafa"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 24
                                anchors.rightMargin: 24
                                spacing: 16

                                Label {
                                    text: "所属分组"
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                    color: textSecondary
                                    Layout.preferredWidth: 80
                                    Layout.alignment: Qt.AlignVCenter
                                }
                                TextField {
                                    id: detailGroupField
                                    font.pixelSize: 13
                                    color: textPrimary
                                    placeholderText: "分组名称"
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    background: Rectangle {
                                        color: detailGroupField.activeFocus ? "#f9f9f9" : "transparent"
                                        radius: 4
                                        border.color: detailGroupField.activeFocus ? subtleBorder : "transparent"
                                    }
                                    onTextEdited: {
                                        if (_switching) return
                                        if (activeTabIndex >= 0 && activeTabIndex < tabsModel.count) {
                                            tabsModel.setProperty(activeTabIndex, "editGroup", text)
                                            checkDirty(activeTabIndex)
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
                                height: 1; color: subtleBorder; opacity: 0.4
                            }
                        }

                        // ── 命令内容（深色代码编辑区）──
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.leftMargin: 24
                            Layout.rightMargin: 24
                            Layout.topMargin: 20
                            Layout.preferredHeight: Math.max(cmdEditArea.implicitHeight + 64, 180)
                            radius: 8
                            color: "#1e1e1e"

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 8

                                RowLayout {
                                    Layout.fillWidth: true
                                    Label {
                                        text: "命令内容"
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
                                        color: "#9ca3af"
                                        Layout.fillWidth: true
                                    }
                                    ToolButton {
                                        flat: true
                                        contentItem: Label {
                                            text: "📋 复制"
                                            font.pixelSize: 11
                                            color: "#9ca3af"
                                        }
                                        background: Rectangle {
                                            radius: 4
                                            color: parent.hovered ? "#374151" : "transparent"
                                        }
                                        onClicked: {
                                            if (CommandManager && activeTabIndex >= 0 && activeTabIndex < tabsModel.count) {
                                                CommandManager.copyToClipboard(tabsModel.get(activeTabIndex).editCommand)
                                                if (copyNotification) {
                                                    copyNotification.text = "已复制"
                                                    copyNotification.open()
                                                }
                                            }
                                        }
                                    }
                                }

                                TextArea {
                                    id: cmdEditArea
                                    selectByMouse: true
                                    wrapMode: TextEdit.Wrap
                                    font.family: "Consolas, Courier New, monospace"
                                    font.pixelSize: 13
                                    color: "#e5e7eb"
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    background: Item {}
                                    onTextChanged: {
                                        if (_switching) return
                                        if (activeFocus && activeTabIndex >= 0 && activeTabIndex < tabsModel.count) {
                                            tabsModel.setProperty(activeTabIndex, "editCommand", text)
                                            cmdBarField.text = text
                                            checkDirty(activeTabIndex)
                                        }
                                    }
                                }
                            }
                        }

                        Item { Layout.preferredHeight: 24 }
                    }
                }

                // ══════ Tab 1: 说明（可编辑）══════
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    ColumnLayout {
                        width: contentStack.width
                        spacing: 0

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.leftMargin: 24
                            Layout.rightMargin: 24
                            Layout.topMargin: 20
                            Layout.preferredHeight: Math.max(descEditArea.implicitHeight + 32, 200)
                            radius: 8
                            color: cardColor
                            border.color: descEditArea.activeFocus ? primary : subtleBorder
                            border.width: descEditArea.activeFocus ? 2 : 1

                            Behavior on border.color { ColorAnimation { duration: 150 } }

                            TextArea {
                                id: descEditArea
                                anchors.fill: parent
                                anchors.margins: 16
                                selectByMouse: true
                                wrapMode: TextEdit.Wrap
                                font.pixelSize: 14
                                color: textPrimary
                                placeholderText: "在此输入说明..."
                                background: Item {}
                                onTextChanged: {
                                    if (_switching) return
                                    if (activeFocus && activeTabIndex >= 0 && activeTabIndex < tabsModel.count) {
                                        tabsModel.setProperty(activeTabIndex, "editDescription", text)
                                        checkDirty(activeTabIndex)
                                    }
                                }
                            }
                        }

                        Item { Layout.preferredHeight: 24 }
                    }
                }
            }
        }
    }

    // ═══════════════ 删除确认对话框 ═══════════════
    Popup {
        id: deleteConfirmDialog
        modal: true; focus: true; padding: 0
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        parent: Overlay.overlay
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
        width: 380; height: 200

        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 120; easing.type: Easing.OutCubic }
            NumberAnimation { property: "scale"; from: 0.96; to: 1; duration: 140; easing.type: Easing.OutCubic }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 100; easing.type: Easing.InCubic }
            NumberAnimation { property: "scale"; from: 1; to: 0.96; duration: 100; easing.type: Easing.InCubic }
        }

        background: Rectangle { radius: 12; color: "#ffffff"; border.color: "#E5E7EB"; border.width: 1 }

        contentItem: ColumnLayout {
            anchors.fill: parent; anchors.margins: 20; spacing: 16

            RowLayout {
                Layout.fillWidth: true; spacing: 10
                Rectangle { width: 36; height: 36; radius: 18; color: "#FEF2F2"
                    Label { anchors.centerIn: parent; text: "⚠"; font.pixelSize: 18 }
                }
                Label { text: "删除命令"; font.pixelSize: 16; font.bold: true; color: "#111827"; Layout.fillWidth: true }
            }

            Label {
                text: (activeTabIndex >= 0 && activeTabIndex < tabsModel.count)
                      ? "确定要删除「" + tabsModel.get(activeTabIndex).editTitle + "」吗？此操作不可撤销。"
                      : ""
                font.pixelSize: 13; color: "#6B7280"; wrapMode: Text.Wrap; Layout.fillWidth: true
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true; spacing: 10
                Item { Layout.fillWidth: true }
                CButton { text: "取消"; theme: "neutral"; onClicked: deleteConfirmDialog.close() }
                CButton { text: "删除"; theme: "danger"
                    onClicked: {
                        if (CommandManager && activeTabIndex >= 0 && activeTabIndex < tabsModel.count) {
                            var idx = tabsModel.get(activeTabIndex).sourceIndex
                            CommandManager.removeCommand(idx)
                            tabsModel.remove(activeTabIndex)
                            if (tabsModel.count === 0) activeTabIndex = -1
                            else activeTabIndex = Math.min(activeTabIndex, tabsModel.count - 1)
                            workspace.commandDeleted()
                        }
                        deleteConfirmDialog.close()
                    }
                }
            }
        }
    }

    // ═══════════════ 未保存关闭确认 ═══════════════
    Popup {
        id: unsavedCloseDialog
        modal: true; focus: true; padding: 0
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        parent: Overlay.overlay
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
        width: 400; height: 200

        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 120; easing.type: Easing.OutCubic }
            NumberAnimation { property: "scale"; from: 0.96; to: 1; duration: 140; easing.type: Easing.OutCubic }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 100; easing.type: Easing.InCubic }
            NumberAnimation { property: "scale"; from: 1; to: 0.96; duration: 100; easing.type: Easing.InCubic }
        }

        background: Rectangle { radius: 12; color: "#ffffff"; border.color: "#E5E7EB"; border.width: 1 }

        contentItem: ColumnLayout {
            anchors.fill: parent; anchors.margins: 20; spacing: 16

            RowLayout {
                Layout.fillWidth: true; spacing: 10
                Rectangle { width: 36; height: 36; radius: 18; color: "#FEF3C7"
                    Label { anchors.centerIn: parent; text: "💾"; font.pixelSize: 18 }
                }
                Label { text: "未保存的更改"; font.pixelSize: 16; font.bold: true; color: "#111827"; Layout.fillWidth: true }
            }

            Label {
                text: "当前标签有未保存的更改，关闭前是否保存？"
                font.pixelSize: 13; color: "#6B7280"; wrapMode: Text.Wrap; Layout.fillWidth: true
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true; spacing: 10
                Item { Layout.fillWidth: true }
                CButton { text: "不保存"; theme: "neutral"
                    onClicked: {
                        var idx = pendingCloseIndex
                        unsavedCloseDialog.close()
                        if (idx >= 0) doCloseTab(idx)
                        pendingCloseIndex = -1
                    }
                }
                CButton { text: "保存并关闭"; theme: "primary"
                    onClicked: {
                        var idx = pendingCloseIndex
                        if (idx >= 0 && idx < tabsModel.count) {
                            var tab = tabsModel.get(idx)
                            if (CommandManager && tab.sourceIndex >= 0) {
                                CommandManager.editCommand(tab.sourceIndex, tab.editTitle, tab.editCommand, tab.editDescription, tab.editGroup)
                            }
                        }
                        unsavedCloseDialog.close()
                        if (idx >= 0) doCloseTab(idx)
                        pendingCloseIndex = -1
                    }
                }
            }
        }
    }
}
