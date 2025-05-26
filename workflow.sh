#!/bin/bash
# 工作流脚本包装器 - 集成了模块开发和发布的工作流程

# 显示帮助信息函数
show_help() {
    echo "工作流脚本包装器"
    echo "用法:"
    echo "  ./workflow.sh build            - 构建模块"
    echo "  ./workflow.sh test             - 测试模块"
    echo "  ./workflow.sh version <版本号>  - 更新版本号"
    echo "  ./workflow.sh fix-perm         - 修复所有脚本的执行权限"
    echo "  ./workflow.sh clean            - 清理生成的文件"
}

# 如果没有参数或显式要求帮助，则显示帮助
if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ -z "$1" ]; then
    show_help
    exit 0
fi

# 确保关键目录存在
if [ ! -d "src" ] || [ ! -d "scripts" ]; then
    echo "错误: 关键目录缺失。确保项目结构正确，包含 'src' 和 'scripts' 目录。"
    exit 1
fi

# 确保关键目录存在
if [ ! -d "src" ] || [ ! -d "scripts" ]; then
    echo "错误: 关键目录缺失。确保项目结构正确，包含 'src' 和 'scripts' 目录。"
    exit 1
fi

# 定义支持的命令和对应的脚本
case "$1" in
    build)
        ./scripts/build.sh
        ;;
    test)
        ./scripts/test_module.sh
        ;;
    version)
        shift  # 移除第一个参数，保留其他参数传递给脚本
        ./scripts/update_version.sh "$@"
        ;;
    fix-perm)
        echo "修复脚本权限..."
        chmod +x workflow.sh scripts/*.sh src/*.sh 2>/dev/null
        echo "权限已修复"
        ;;
    clean)
        echo "清理生成的文件..."
        rm -f *.zip 2>/dev/null
        echo "清理完成"
        ;;
    *)
        echo "未知的命令: $1"
        show_help
        exit 1
        ;;
esac
