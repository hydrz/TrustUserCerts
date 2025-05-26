#!/bin/bash
# 版本更新脚本

# 切换到项目根目录
cd "$(dirname "$0")/.." || exit 1

# 检查命令行参数
if [ $# -lt 1 ]; then
  echo "用法: $0 <新版本号> [是否是预发布版本]"
  echo "例如: $0 v1.1"
  echo "例如: $0 v1.1-beta true"
  exit 1
fi

NEW_VERSION=$1
IS_PRERELEASE=${2:-false}
VERSION_CODE=$(echo $NEW_VERSION | sed 's/[^0-9]*//g')

# 如果没有明确的版本代码，递增当前版本代码
if [ -z "$VERSION_CODE" ]; then
  CURRENT_VERSION_CODE=$(grep "versionCode=" src/module.prop | cut -d= -f2)
  VERSION_CODE=$((CURRENT_VERSION_CODE + 1))
fi

# 版本长度检查
if [ ${#VERSION_CODE} -lt 2 ]; then
  VERSION_CODE="1${VERSION_CODE}0"  # 确保至少是三位数
fi

echo "更新版本到: $NEW_VERSION (代码: $VERSION_CODE)"

# 更新module.prop
sed -i "s/version=.*/version=$NEW_VERSION/" src/module.prop
sed -i "s/versionCode=.*/versionCode=$VERSION_CODE/" src/module.prop

# 更新update.json
MODULE_ID=$(grep "id=" src/module.prop | cut -d= -f2)
cat > update.json << EOF
{
    "version": "$NEW_VERSION",
    "versionCode": $VERSION_CODE,
    "zipUrl": "https://github.com/hydrz/TrustUserCerts/releases/download/$NEW_VERSION/${MODULE_ID}_$NEW_VERSION.zip",
    "changelog": "https://raw.githubusercontent.com/hydrz/TrustUserCerts/master/CHANGELOG.md"
}
EOF

# 提示更新CHANGELOG.md
echo "请确保更新CHANGELOG.md文件！"

# 检查是否在GitHub Actions中运行
if [ -z "$GITHUB_ACTIONS" ]; then
  echo "然后，执行以下Git命令创建新的发布:"
  echo "----------------------------------------"
  echo "git add module.prop update.json CHANGELOG.md"
  echo "git commit -m \"准备发布 $NEW_VERSION\""
  echo "git tag $NEW_VERSION"
  echo "git push origin $NEW_VERSION"
  echo "git push origin main"
  echo "----------------------------------------"
  echo "或者使用GitHub Actions工作流:"
  echo "1. 打开项目的GitHub页面"
  echo "2. 转到Actions标签页"
  echo "3. 选择'Update Changelog'工作流"
  echo "4. 点击'Run workflow'"
  echo "5. 输入版本号和描述"
else
  echo "在GitHub Actions中运行 - 版本已成功更新"
fi
echo "----------------------------------------"
echo "GitHub Actions将自动构建并发布此版本。"
