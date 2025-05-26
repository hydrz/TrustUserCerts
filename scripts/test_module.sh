#!/bin/bash
# 本地测试脚本，用于在提交前验证模块的正确性

# 切换到项目根目录
cd "$(dirname "$0")/.." || exit 1

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # 无颜色

echo -e "${YELLOW}开始模块测试...${NC}"

# 检查文件存在性
echo -n "检查必要文件... "
REQUIRED_FILES=(
  "src/module.prop"
  "src/service.sh"
  "src/post-fs-data.sh"
  "src/META-INF/com/google/android/updater-script"
  "src/META-INF/com/google/android/update-binary"
)

ALL_EXIST=true
for file in "${REQUIRED_FILES[@]}"; do
  if [ ! -f "$file" ]; then
    echo -e "${RED}错误: 找不到 $file${NC}"
    ALL_EXIST=false
  fi
done

if $ALL_EXIST; then
  echo -e "${GREEN}通过${NC}"
else
  echo -e "${RED}检查文件: 失败${NC}"
  exit 1
fi

# 检查module.prop格式
echo -n "检查模块属性文件... "
if ! grep -q "^id=" src/module.prop || \
   ! grep -q "^name=" src/module.prop || \
   ! grep -q "^version=" src/module.prop || \
   ! grep -q "^versionCode=" src/module.prop || \
   ! grep -q "^author=" src/module.prop || \
   ! grep -q "^description=" src/module.prop; then
  echo -e "${RED}失败: module.prop 缺少必要字段${NC}"
  exit 1
fi

# 检查脚本权限
echo -n "检查脚本权限... "
SCRIPT_FILES=(
  "src/service.sh"
  "src/post-fs-data.sh"
  "src/customize.sh"
  "src/uninstall.sh"
  "src/debug_tool.sh"
)

PERMISSION_OK=true
for script in "${SCRIPT_FILES[@]}"; do
  if [ -f "$script" ] && [ ! -x "$script" ]; then
    echo -e "${RED}失败: $script 没有执行权限${NC}"
    PERMISSION_OK=false
  fi
done

if $PERMISSION_OK; then
  echo -e "${GREEN}通过${NC}"
else
  echo -e "${YELLOW}警告: 部分脚本没有执行权限，请运行 'chmod +x *.sh' 修复${NC}"
fi

# 验证update.json
echo -n "检查更新配置... "
if [ -f "update.json" ]; then
  if ! grep -q "\"version\"" update.json || \
     ! grep -q "\"versionCode\"" update.json || \
     ! grep -q "\"zipUrl\"" update.json || \
     ! grep -q "\"changelog\"" update.json; then
    echo -e "${RED}失败: update.json 格式不正确${NC}"
    exit 1
  else
    echo -e "${GREEN}通过${NC}"
  fi
else
  echo -e "${YELLOW}警告: 未找到 update.json${NC}"
fi

# 确保模块脚本文件拥有执行权限
if ! $PERMISSION_OK; then
  echo -e "${YELLOW}正在修复脚本权限...${NC}"
  chmod +x src/*.sh 2>/dev/null
  echo -e "${GREEN}已修复${NC}"
fi

echo -e "${GREEN}所有测试通过！${NC}"
echo "你可以通过运行 './workflow.sh build' 来构建Magisk模块"
