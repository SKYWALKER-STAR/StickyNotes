#!/bin/bash

# ================= 配置部分 =================
# Qt 安装目录
QT_DIR="/software/local/QT/6.10.1/gcc_64"
# 编译好的可执行文件路径
EXE_PATH="./build/Desktop_Qt_6_10_1-Debug/cmdbox"
# 输出目录
OUTPUT_DIR="./cmdbox_dist"
# ===========================================

if [ ! -f "$EXE_PATH" ]; then
    echo "错误: 找不到可执行文件 $EXE_PATH"
    echo "请先运行编译: ./run.sh"
    exit 1
fi

echo "正在打包到 $OUTPUT_DIR ..."

# 1. 准备目录结构
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/lib"
mkdir -p "$OUTPUT_DIR/plugins"
mkdir -p "$OUTPUT_DIR/qml"

# 2. 复制可执行文件
echo "-> 复制可执行文件..."
cp "$EXE_PATH" "$OUTPUT_DIR/cmdbox"

# 3. 定义复制库的函数 (递归查找依赖)
copy_libs() {
    local binary="$1"
    # ldd 查找依赖 -> 过滤出包含 QT_DIR 的行 -> 提取路径
    local deps=$(ldd "$binary" | awk '{print $3}' | grep "$QT_DIR")
    
    for lib in $deps; do
        if [ -f "$lib" ]; then
            local lib_name=$(basename "$lib")
            # 如果目标目录没有这个库，则复制并递归检查它的依赖
            if [ ! -f "$OUTPUT_DIR/lib/$lib_name" ]; then
                echo "   复制库: $lib_name"
                cp "$lib" "$OUTPUT_DIR/lib/"
                # 递归处理库的依赖 (因为 libQt6Gui 可能依赖 libQt6Core)
                copy_libs "$lib"
            fi
        fi
    done
}

# 4. 复制主程序的依赖库
echo "-> 分析并复制依赖库..."
copy_libs "$OUTPUT_DIR/cmdbox"

# 5. 复制必要的插件
# 平台插件 (必须，否则报错 "Could not find the Qt platform plugin 'xcb'")
echo "-> 复制平台插件..."
mkdir -p "$OUTPUT_DIR/plugins/platforms"
cp "$QT_DIR/plugins/platforms/libqxcb.so" "$OUTPUT_DIR/plugins/platforms/"
# 别忘了复制插件本身的依赖
copy_libs "$OUTPUT_DIR/plugins/platforms/libqxcb.so"

# 6. 复制 QML 模块
# 这是一个难点，因为很难自动检测用到了哪些 QML。
# 这里我们采取“宁滥勿缺”的策略，复制常用的 QtQuick 模块。
# 如果体积太大，你可以手动删除不需要的文件夹。
echo "-> 复制 QML 模块 (这可能需要一点时间)..."

# 复制 QtQuick 核心模块
if [ -d "$QT_DIR/qml/QtQuick" ]; then
    mkdir -p "$OUTPUT_DIR/qml/QtQuick"
    cp -r "$QT_DIR/qml/QtQuick" "$OUTPUT_DIR/qml/"
fi

# 复制 Qt 基础模块 (包含 Qt.labs 等)
if [ -d "$QT_DIR/qml/Qt" ]; then
    mkdir -p "$OUTPUT_DIR/qml/Qt"
    cp -r "$QT_DIR/qml/Qt" "$OUTPUT_DIR/qml/"
fi

# 7. 创建启动脚本 (AppRun)
echo "-> 创建启动脚本..."
cat > "$OUTPUT_DIR/AppRun" <<EOF
#!/bin/bash
# 获取脚本所在目录
DIR="\$( cd "\$( dirname "\${BASH_SOURCE[0]}" )" && pwd )"

# 设置环境变量，优先使用目录内的库
export LD_LIBRARY_PATH=\$DIR/lib:\$LD_LIBRARY_PATH
export QT_PLUGIN_PATH=\$DIR/plugins
export QML2_IMPORT_PATH=\$DIR/qml
export QT_QPA_PLATFORM_PLUGIN_PATH=\$DIR/plugins/platforms

# 运行程序
exec "\$DIR/cmdbox" "\$@"
EOF

chmod +x "$OUTPUT_DIR/AppRun"

echo "=================================================="
echo "打包完成！"
echo "请运行以下命令测试: $OUTPUT_DIR/AppRun"
echo "如果一切正常，你可以将 $OUTPUT_DIR 文件夹压缩发给别人。"
echo "=================================================="
