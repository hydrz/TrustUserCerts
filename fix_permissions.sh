#!/bin/bash
# 简单脚本，用于修复所有脚本的执行权限

echo "修复脚本权限..."
chmod +x workflow.sh scripts/*.sh src/*.sh
echo "权限已修复"
