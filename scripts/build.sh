#!/bin/bash
# 打包脚本，创建可安装的Magisk模块

# 切换到项目根目录
cd "$(dirname "$0")/.." || exit 1

# 初始化
VERSION=$(grep 'version=' src/module.prop | cut -d= -f2)
MODULE_NAME=$(grep 'name=' src/module.prop | cut -d= -f2 | tr ' ' '_')
ZIP_NAME="${MODULE_NAME}_${VERSION}.zip"

echo "构建 $MODULE_NAME $VERSION"

# 移除旧的zip文件
rm -f "$ZIP_NAME" 2>/dev/null

# 创建临时构建目录
BUILD_DIR=$(mktemp -d)
echo "创建临时构建目录: $BUILD_DIR"

# 复制代码脚本
cp -r src/* "$BUILD_DIR/" 2>/dev/null

# 检查必要文件是否已复制
for file in module.prop post-fs-data.sh service.sh; do
    if [ ! -f "$BUILD_DIR/$file" ]; then
        echo "错误: 找不到必要文件 $file"
        rm -rf "$BUILD_DIR"
        exit 1
    fi
done

# 检查META-INF
if [ ! -d "$BUILD_DIR/META-INF" ]; then
    echo "错误: 找不到META-INF目录"
    rm -rf "$BUILD_DIR"
    exit 1
fi

# 进入构建目录
cd "$BUILD_DIR" || exit 1

# 创建ZIP文件
echo "正在创建 $ZIP_NAME..."
zip -r "$ZIP_NAME" . >/dev/null

# 移动ZIP文件到项目根目录
mv "$ZIP_NAME" "$OLDPWD/"

# 返回项目根目录
cd "$OLDPWD" || exit 1

# 清理临时目录
rm -rf "$BUILD_DIR"

# 完成
if [ -f "$ZIP_NAME" ]; then
    echo "打包完成: $ZIP_NAME ($(du -h "$ZIP_NAME" | cut -f1))"
    echo "模块可以通过Magisk管理器安装"
else
    echo "错误: 打包失败"
    exit 1
fi
