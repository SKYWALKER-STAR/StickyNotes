#!/bin/bash

# ================= 配置部分 =================
# 请确保你已经安装了 cqtdeployer
# 安装命令: sudo snap install cqtdeployer

# Qt qmake 路径
QMAKE_PATH="/software/local/QT/6.10.1/gcc_64/bin/qmake"

# 可执行文件路径
EXE_PATH="build/Desktop_Qt_6_10_1-Debug/cmdbox"

# 输出目录
OUTPUT_DIR="./Distribution"
# ===========================================

if [ ! -f "$EXE_PATH" ]; then
    echo "错误: 找不到可执行文件 $EXE_PATH"
    echo "请先运行编译: ./run.sh"
    exit 1
fi

# 检查 cqtdeployer 是否安装
if ! command -v cqtdeployer &> /dev/null; then
    echo "错误: 未找到 cqtdeployer 命令"
    echo "请先安装它: sudo snap install cqtdeployer"
    echo "或者下载 deb 包安装: https://github.com/QuasarApp/CQtDeployer/releases"
    exit 1
fi

echo "正在使用 CQtDeployer 打包 DEB..."

# 清理旧的输出
rm -rf "$OUTPUT_DIR"

# 运行打包命令
# -bin: 指定可执行文件
# -qmake: 指定 qmake 路径 (用于查找依赖)
# -qmlDir: 指定 QML 源码目录 (用于扫描 QML 依赖)
# -type: 指定输出格式为 deb
# -targetDir: 输出目录
# -name: 包名
# -version: 版本号
# -description: 描述
cqtdeployer -bin "$EXE_PATH" \
    -qmake "$QMAKE_PATH" \
    -qmlDir . \
    -type deb \
    -targetDir "$OUTPUT_DIR" \
    -name "cmdbox" \
    -version "0.1" \
    -description "A quick command paste tool for Ops engineers"

echo "=================================================="
echo "打包完成！"
echo "DEB 包位置: $OUTPUT_DIR"
echo "=================================================="
