#!/system/bin/sh
# 卸载脚本

# 卸载所有临时挂载
APEX_CERT_DIR=/apex/com.android.conscrypt/cacerts
SYS_CERT_DIR=/system/etc/security/cacerts
TEMP_DIR="/data/local/tmp/tmp-ca-copy"
UNINSTALL_LOG="/data/local/tmp/trustusercerts_uninstall.log"

# 开始记录日志
echo "--- TrustUserCerts 卸载日志 ---" > $UNINSTALL_LOG
echo "日期: $(date)" >> $UNINSTALL_LOG
echo "Android版本: $(getprop ro.build.version.release)" >> $UNINSTALL_LOG

# 尝试卸载临时文件系统
echo "尝试卸载 $SYS_CERT_DIR..." >> $UNINSTALL_LOG
if umount -f $SYS_CERT_DIR 2>> $UNINSTALL_LOG; then
    echo "$SYS_CERT_DIR 已成功卸载" >> $UNINSTALL_LOG
else
    echo "无法卸载 $SYS_CERT_DIR 或已经卸载" >> $UNINSTALL_LOG
fi

echo "尝试卸载 $APEX_CERT_DIR..." >> $UNINSTALL_LOG
if umount -f $APEX_CERT_DIR 2>> $UNINSTALL_LOG; then
    echo "$APEX_CERT_DIR 已成功卸载" >> $UNINSTALL_LOG
else
    echo "无法卸载 $APEX_CERT_DIR 或已经卸载" >> $UNINSTALL_LOG
fi

# 清理临时目录
echo "清理临时目录..." >> $UNINSTALL_LOG
rm -rf $TEMP_DIR 2>> $UNINSTALL_LOG

# 检查是否有残留的进程
echo "检查残留进程..." >> $UNINSTALL_LOG
ps | grep -i "trustusercerts" >> $UNINSTALL_LOG 2>&1

# 最后的清理消息
echo "卸载完成" >> $UNINSTALL_LOG
echo "TrustUserCerts 模块已卸载，日志保存在 $UNINSTALL_LOG"
