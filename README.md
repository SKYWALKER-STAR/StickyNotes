<div align="center">
<picture>
 <source media="(prefers-color-scheme: dark)" srcset="https://skywalker-star.github.io/icon/stickynotes-v2.png">
 <img alt="stickynotes banner" src="https://skywalker-star.github.io/icon/stickynotes-v2.png">
</picture>
</div>

# Sticky Note
![Date](https://img.shields.io/date/1764827464?style=plastic)

Sticky Note is a versatile and lightweight tool designed for organizing and managing your notes and tasks efficiently. It supports a wide range of functionalities to enhance productivity.

## Table of Contents

- [Features](#features)
- [Building From Source](#building-from-source)
  - [Dependencies](#dependencies)
  - [Linux](#linux)
- [Binary](#binary)
- [Import / Export](#import--export)
- [License ⚖](#license-⚖)

## Features

* **Note and Task Management** – Create, edit, and organize your notes and tasks effortlessly.
* **One‑click copy** – Quickly copy text or notes to your clipboard with a single click.
* **Fuzzy search** – Case‑insensitive search across all your notes and tasks.
* **Import / Export (JSON)** – Backup or share your notes and tasks easily.
* **Keyboard shortcuts**:
  * `Ctrl+F` Focus the search box
  * `Ctrl+N` Open the Add dialog
* **Cross‑platform** – Available for Linux and Windows (build locally on each platform).

## Building From Source

### Dependencies

* **Qt** >= 6.8 (Qt Quick module required)
* **CMake** >= 3.16
* **C++ compiler (GCC / Clang / MSVC / MinGW)**

### Linux
> [!IMPORTANT]
> If Qt is installed in a custom prefix (example `/user/local/QT/6.10.1/gcc_64`):
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

## Binary
Use packaged prebuilt binaries (recommended):

1. Go to the GitHub repository Releases page and download the archive for your platform (Assets).
2. Extract it to any folder (keep the runtime layout, e.g. `*.dll`, `platforms/`, `qml/`, etc. alongside the executable).
3. Windows: run `snote.exe` (if SmartScreen blocks it, choose “Run anyway”).
4. Linux: run the extracted executable directly; if it’s a `.deb` package, install it via your system package manager.

A locally built Release can also be used as a “portable” build:

- Windows (this repo example): go to `build/Desktop_Qt_6_10_1_MinGW_64_bit-Release/` and run `snote.exe`.
- Note: don’t copy only the single `.exe` file—ship it together with the Qt runtime DLLs and plugin folders, otherwise you’ll hit errors like missing Qt platform plugins.

## Import / Export ⛵︎
Use menu (⋮) → Import / Export. JSON schema is an array of objects:
```json
[
  { "title": "Meeting Notes", "content": "Discuss project milestones", "description": "Team meeting notes" }
]
```

## License ⚖

GNU Lesser General Public License v3.0 or later (LGPL-3.0-or-later).

See `LICENSE`, `COPYING` and `COPYING.LESSER`.
