#!/bin/bash
# 打包脚本，创建可安装的Magisk模块

# 初始化
VERSION=$(grep 'version=' module.prop | cut -d= -f2)
MODULE_NAME=$(grep 'name=' module.prop | cut -d= -f2 | tr ' ' '_')
ZIP_NAME="${MODULE_NAME}_${VERSION}.zip"

# 确保在工作目录下
cd "$(dirname "$0")" || exit 1

echo "构建 $MODULE_NAME $VERSION"

# 移除旧的zip文件
rm -f "$ZIP_NAME" 2>/dev/null

# 检查必要文件
for file in module.prop post-fs-data.sh service.sh; do
    if [ ! -f "$file" ]; then
        echo "错误: 找不到必要文件 $file"
        exit 1
    fi
done

# 检查META-INF
if [ ! -d "META-INF" ]; then
    echo "错误: 找不到META-INF目录"
    exit 1
fi

# 创建ZIP文件
echo "正在创建 $ZIP_NAME..."
zip -r "$ZIP_NAME" . -x ".git*" -x "build.sh" -x "*.zip" -x ".DS_Store" -x "__MACOSX" > /dev/null

# 完成
if [ -f "$ZIP_NAME" ]; then
    echo "打包完成: $ZIP_NAME ($(du -h "$ZIP_NAME" | cut -f1))"
    echo "模块可以通过Magisk管理器安装"
else
    echo "错误: 打包失败"
    exit 1
fi
