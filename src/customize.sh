#!/system/bin/sh
##########################################################################################
#
# Magisk 模块定制脚本
#
##########################################################################################

SKIPUNZIP=1
ASH_STANDALONE=1

# 打印信息
ui_print() {
  echo "$1"
}

# 复制文件
install_module() {
  ui_print "- 提取模块文件"
  unzip -o "$ZIPFILE" -x 'META-INF/*' -d $MODPATH >&2

  # 确保脚本有执行权限
  ui_print "- 设置权限"
  set_perm_recursive $MODPATH 0 0 0755 0644
  set_perm $MODPATH/service.sh 0 0 0755
  set_perm $MODPATH/post-fs-data.sh 0 0 0755

  # 创建系统证书目录
  mkdir -p $MODPATH/system/etc/security/cacerts
  touch $MODPATH/system/etc/security/cacerts/.replace
}

# 检测Android版本
check_android_version() {
  android_version=$(getprop ro.build.version.release)
  sdk_version=$(getprop ro.build.version.sdk)

  ui_print "- 设备运行 Android $android_version (SDK $sdk_version)"

  if [ "$sdk_version" -lt "24" ]; then
    ui_print "! 警告: 此模块最佳支持Android 7.0 (SDK 24)及更高版本"
    ui_print "  但仍将尝试安装"
    sleep 2
  fi
}

# 主函数
main() {
  ui_print "******************************"
  ui_print "  高级用户证书信任模块 v1.1   "
  ui_print "******************************"

  # 检测Android版本
  check_android_version

  # 安装模块文件
  install_module

  # 完成
  ui_print "- 安装完成"
  ui_print "- 重启后模块将自动生效"
  ui_print "  支持Android 7-16"
  ui_print "  支持Magisk/KernelSU"
}

# 执行主函数
main
