#!/bin/bash

# 尝试根据系统环境自动设置 QT_IM_MODULE
if [[ "$XMODIFIERS" == *"fcitx"* ]]; then
    export QT_IM_MODULE=fcitx
elif [[ "$XMODIFIERS" == *"ibus"* ]]; then
    export QT_IM_MODULE=ibus
else
    # 如果无法检测，默认尝试 fcitx，你可以根据实际情况修改为 ibus
    export QT_IM_MODULE=fcitx
fi

echo "当前设置的输入法环境变量: QT_IM_MODULE=$QT_IM_MODULE"

# 确保构建
cmake --build build/Desktop_Qt_6_10_1-Debug

# 运行程序
./build/Desktop_Qt_6_10_1-Debug/cmdbox
