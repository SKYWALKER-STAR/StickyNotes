<div align="center">
<div style="margin: 20px 0;">
  <img src="https://github.com/SKYWALKER-STAR/StickyNotes/blob/main/Logo.svg">
</div>

# Sticky Notes
<div align="center">
  <div style="background: linear-gradient(135deg, #ffffff 0%, #ffffff 100%); border-radius: 15px; padding: 25px; text-align: center;">
    <p>
      <img src="https://img.shields.io/date/1764827464?style=plastic">
    </p>
  </div>
</div>
</div>
Sticky Notes is a versatile and lightweight tool designed for organizing and managing your notes and tasks efficiently. It is no longer limited to command management but now supports a wide range of functionalities to enhance productivity.

## Features 💎

* **Note and Task Management** – Create, edit, and organize your notes and tasks effortlessly.
* **One‑click copy** – Quickly copy text or notes to your clipboard with a single click.
* **Fuzzy search** – Case‑insensitive search across all your notes and tasks.
* **Import / Export (JSON)** – Backup or share your notes and tasks easily.
* **Keyboard shortcuts**:
  * `Ctrl+F` Focus the search box
  * `Ctrl+N` Open the Add dialog
* **Cross‑platform** – Available for Linux and Windows (build locally on each platform).

## Build From Source 📥︎

### Dependencies

* Qt >= 6.8 (Qt Quick module required)
* CMake >= 3.16
* C++ compiler (GCC / Clang / MSVC / MinGW)

### Linux (fresh out‑of‑source build)

```bash
git clone <repo-url> sticky-notes
cd sticky-notes
mkdir -p build && cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
cmake --build . -j
./sticky-notes
```

If Qt is installed in a custom prefix (example `/user/local/QT/6.10.1/gcc_64`):
```bash
export QT_HOME=/path/to/qt
export PATH=$QT_HOME/bin:$PATH
cmake -DCMAKE_PREFIX_PATH=$QT_HOME ..
```

## Import / Export ⛵︎
Use menu (⋮) → Import / Export. JSON schema is an array of objects:
```json
[
  { "title": "Meeting Notes", "content": "Discuss project milestones", "description": "Team meeting notes" }
]
```

## Troubleshooting ❓︎
| Issue | Cause | Fix |
|-------|-------|-----|
| Qt plugin "xcb" not loading | Missing system libs (`libxcb-cursor0`, etc.) | `sudo apt install libxcb-cursor0` |
| Empty window / QML errors | Wrong QML import path | Ensure `QML2_IMPORT_PATH` or packaged `qml/` folder |
| Cannot input Chinese | Missing input method env vars | Set `QT_IM_MODULE=fcitx` or `ibus` |


## License ⚖

MIT License
