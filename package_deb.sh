#!/bin/bash

# ================= 配置部分 =================
APP_NAME="cmdbox"
VERSION="0.1"
ARCH="amd64"
SOURCE_DIR="./cmdbox_dist"  # 刚才手动打包生成的目录
DEB_DIR="deb_build"
OUTPUT_DEB="${APP_NAME}_${VERSION}_${ARCH}.deb"
# ===========================================

if [ ! -d "$SOURCE_DIR" ]; then
    echo "错误: 找不到源目录 $SOURCE_DIR"
    echo "请先运行 ./package_manual.sh 生成依赖包"
    exit 1
fi

echo "正在构建 DEB 包..."

# 1. 清理并创建目录结构
rm -rf "$DEB_DIR"
mkdir -p "$DEB_DIR/opt/$APP_NAME"
mkdir -p "$DEB_DIR/usr/bin"
mkdir -p "$DEB_DIR/usr/share/applications"
mkdir -p "$DEB_DIR/DEBIAN"

# 2. 复制程序文件到 /opt/cmdbox
echo "-> 复制程序文件..."
cp -r "$SOURCE_DIR"/* "$DEB_DIR/opt/$APP_NAME/"

# 3. 创建 /usr/bin 下的软链接脚本
# 这个脚本会在用户输入 cmdbox 时执行 /opt/cmdbox/AppRun
echo "-> 创建启动链接..."
cat > "$DEB_DIR/usr/bin/$APP_NAME" <<EOF
#!/bin/bash
exec /opt/$APP_NAME/AppRun "\$@"
EOF
chmod +x "$DEB_DIR/usr/bin/$APP_NAME"

# 4. 创建 .desktop 文件 (让它出现在应用菜单里)
echo "-> 创建桌面快捷方式..."
cat > "$DEB_DIR/usr/share/applications/$APP_NAME.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=CMD BOX
Comment=A quick command paste tool
Exec=/opt/$APP_NAME/AppRun
Icon=utilities-terminal
Terminal=false
Categories=Utility;Development;
EOF

# 5. 创建控制文件 (Control File)
echo "-> 创建包信息..."
cat > "$DEB_DIR/DEBIAN/control" <<EOF
Package: $APP_NAME
Version: $VERSION
Section: utils
Priority: optional
Architecture: $ARCH
Maintainer: OpsTools <maintainer@example.com>
Description: A quick command paste tool for Ops engineers
 This tool helps you manage and paste frequently used commands.
 It includes all necessary Qt dependencies.
EOF

# 6. 打包
echo "-> 生成 .deb 文件..."
dpkg-deb --build "$DEB_DIR" "$OUTPUT_DEB"

echo "=================================================="
echo "打包完成: $OUTPUT_DEB"
echo "安装测试: sudo dpkg -i $OUTPUT_DEB"
echo "卸载测试: sudo apt remove $APP_NAME"
echo "=================================================="
