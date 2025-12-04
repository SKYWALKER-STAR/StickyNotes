<div align="center">
<div style="margin: 20px 0;">
  <img src="./Logo.png">
</div>

# CMDBOX
<div align="center">
  <div style="background: linear-gradient(135deg, #ffffff 0%, #ffffff 100%); border-radius: 15px; padding: 25px; text-align: center;">
    <p>
      <a href="https://aibox.richaibox.com"><img src="https://img.shields.io/date/1764827464?style=plastic"></a>
    </p>
  </div>
</div>
</div>
CMDBOX is a lightweight command management tool for operations engineers – record, search and copy frequently used commands fast.

## Features 💎

* **Command management** – Add, edit and delete frequently used commands.
* **One‑click copy** – Left‑click the list item or press the dedicated Copy button to place the command on the clipboard with a toast notification.
* **Fuzzy search** – Case‑insensitive search over title, command content and description.
* **Import / Export (JSON)** – Backup or share your command set easily.
* **Keyboard shortcuts**:
  * `Ctrl+F` Focus the search box
  * `Ctrl+N` Open the Add dialog
* **Cross‑platform** – Linux and Windows (build locally on each platform).

## Screenshots 📸
<div align="center">
<img src="./capture.png",alt="example">
</div>

## Build 📥︎

### Dependencies

* Qt >= 6.8 (Qt Quick module required)
* CMake >= 3.16
* C++ compiler (GCC / Clang / MSVC / MinGW)

### Linux (fresh out‑of‑source build)

```bash
git clone <repo-url> cmdbox
cd cmdbox
mkdir -p build && cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
cmake --build . -j
./cmdbox
```

If Qt is installed in a custom prefix (example `/software/local/QT/6.10.1/gcc_64`):
```bash
export QT_HOME=/software/local/QT/6.10.1/gcc_64
export PATH=$QT_HOME/bin:$PATH
cmake -DCMAKE_PREFIX_PATH=$QT_HOME ..
```

#### One‑liner using helper script
From project root you can also use the portable helper:
```bash
./build.sh                   # Debug build
./build.sh -t Release -r     # Release build and run
./build.sh -q /software/local/QT/6.10.1/gcc_64 -t Release
```

### Windows (Qt Creator)
1. Open `CMakeLists.txt` in Qt Creator.
2. Select a Kit (e.g. "Desktop Qt 6.x MinGW 64-bit").
3. Build & Run.

### Windows (CLI, MinGW example)
```powershell
mkdir build
cd build
cmake -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release ..
cmake --build . -j
./cmdbox.exe
```

## Packaging 📦

### CPack (Deb + Tarball)
After building:
```bash
cd build
cpack
```
Outputs: `cmdbox-<version>-Linux.deb`, `cmdbox-<version>-Linux.tar.gz`.

### Manual self‑contained folder
Use `package_manual.sh` (copies Qt libs & plugins) then compress `cmdbox_dist`.

### CQtDeployer (recommended)
Run:
```bash
./package_with_cqtdeployer.sh
```
Resulting `.deb` will include required Qt runtime pieces.

## Import / Export ⛵︎
Use menu (⋮) → Import / Export. JSON schema is an array of objects:
```json
[
  { "title": "Check Docker images", "command": "docker images", "description": "List images" }
]
```

## Troubleshooting ❓︎
| Issue | Cause | Fix |
|-------|-------|-----|
| Qt plugin "xcb" not loading | Missing system libs (`libxcb-cursor0`, etc.) | `sudo apt install libxcb-cursor0` |
| Empty window / QML errors | Wrong QML import path | Ensure `QML2_IMPORT_PATH` or packaged `qml/` folder |
| Cannot input Chinese | Missing input method env vars | Set `QT_IM_MODULE=fcitx` or `ibus` |

Enable plugin debug:
```bash
export QT_DEBUG_PLUGINS=1
./cmdbox
```

## License ⚖

MIT License
