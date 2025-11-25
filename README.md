# CMD BOX (cpaste-quick)

CMD BOX 是一款基于 Qt6 和 QML 开发的轻量级运维命令管理工具，旨在帮助运维工程师快速记录、搜索和复制常用命令。

## 功能特性

*   **命令管理**：轻松添加、修改和删除常用命令。
*   **一键复制**：点击命令即可复制到剪贴板，支持鼠标左键单击和专用按钮。
*   **模糊搜索**：支持对命令标题、内容和描述进行模糊搜索，快速定位。
*   **数据导入/导出**：支持 JSON 格式的数据导入和导出，方便备份和迁移。
*   **快捷键支持**：
    *   `Ctrl+F`: 聚焦搜索框
    *   `Ctrl+N`: 新建命令
*   **跨平台**：支持 Linux 和 Windows (需自行编译)。

## 构建指南

### 依赖

*   Qt 6.8 或更高版本 (包含 Qt Quick 模块)
*   CMake 3.16+
*   C++ 编译器 (GCC, Clang, MSVC)

### Linux 构建

```bash
mkdir build
cd build
cmake ..
cmake --build .
```

运行：
```bash
./cmdbox
```

### Windows 构建

1.  使用 Qt Creator 打开 `CMakeLists.txt`。
2.  配置构建套件 (Kit)。
3.  点击运行。

或者使用命令行：
```powershell
mkdir build
cd build
cmake -G "MinGW Makefiles" ..
cmake --build .
```

## 安装包制作

本项目支持使用 CPack 生成安装包（如 .deb）。

```bash
cd build
cpack
```

## 许可证

MIT License
