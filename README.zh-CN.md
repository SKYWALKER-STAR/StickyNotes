<div align="center">
<picture>
 <source media="(prefers-color-scheme: dark)" srcset="https://skywalker-star.github.io/icon/stickynotes-v2.png">
 <img alt="stickynotes banner" src="https://skywalker-star.github.io/icon/stickynotes-v2.png">
</picture>
</div>

# Sticky Note
![Date](https://img.shields.io/date/1764827464?style=plastic)

Sticky Note 是一款轻量、易用的便签与任务管理工具，帮助你高效整理与管理信息，提升日常工作与学习效率。
[English README](README.md)

## 目录

- [功能特性](#功能特性)
- [从源码构建](#从源码构建)
  - [依赖项](#依赖项)
  - [Linux](#linux)
- [二进制发布版](#二进制发布版)
- [导入/导出](#导入导出)
- [许可证 ⚖](#许可证-⚖)

## 功能特性

* **便签与任务管理** - 轻松创建、编辑与整理便签和任务。
* **一键复制** - 单击即可将文本或便签内容复制到剪贴板。
* **模糊搜索** - 对所有便签与任务进行不区分大小写的搜索。
* **导入/导出 (JSON)** - 便捷备份或分享你的数据。
* **快捷键**:
  * `Ctrl+F` 聚焦搜索框
  * `Ctrl+N` 打开新增对话框
* **跨平台** - 支持 Linux 与 Windows (需在对应平台本地构建)。

## 从源码构建

### 依赖项

* **Qt** >= 6.8 (需要 Qt Quick 模块)
* **CMake** >= 3.16
* **C++ 编译器 (GCC / Clang / MSVC / MinGW)**

### Linux
> [!IMPORTANT]
> 如果 Qt 安装在自定义目录 (例如 `/user/local/QT/6.10.1/gcc_64`):
```bash
export QT_HOME=/path/to/qt
export PATH=$QT_HOME/bin:$PATH
cmake -DCMAKE_PREFIX_PATH=$QT_HOME ..
```

```bash
git clone git@github.com:SKYWALKER-STAR/StickyNotes.git sticky-notes
cd sticky-notes
mkdir -p build && cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
cmake --build . -j
./bin/snotes
```

## 二进制发布版
使用已打包的预构建版本 (推荐):

1. 进入 GitHub 仓库的 Releases 页面，下载对应平台的压缩包 (Assets)。
2. 解压到任意目录 (保持运行时目录结构，例如 `*.dll`, `platforms/`, `qml/` 等与可执行文件同级)。
3. Windows: 运行 `snote.exe` (若 SmartScreen 拦截，选择“仍要运行”)。
4. Linux: 直接运行解压后的可执行文件；若是 `.deb` 包，可通过系统包管理器安装。

本地构建的 Release 版本也可以作为“便携版”使用:

- Windows (本仓库示例): 进入 `build/Desktop_Qt_6_10_1_MinGW_64_bit-Release/` 并运行 `snote.exe`。
- 注意: 不要只复制单独的 `.exe` 文件，需与 Qt 运行时 DLL 与插件目录一起分发，否则会出现缺少 Qt 平台插件等错误。

## 导入/导出 ⛵︎
通过菜单 (⋮) → Import / Export。JSON 格式为对象数组:
```json
[
  { "title": "Meeting Notes", "content": "Discuss project milestones", "description": "Team meeting notes" }
]
```

## 许可证 ⚖

GNU Lesser General Public License v3.0 or later (LGPL-3.0-or-later)。

参见 `LICENSE`, `COPYING` 与 `COPYING.LESSER`。
