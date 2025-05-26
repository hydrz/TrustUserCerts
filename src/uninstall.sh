#!/system/bin/sh
# 卸载脚本

# 卸载所有临时挂载
APEX_CERT_DIR=/apex/com.android.conscrypt/cacerts
SYS_CERT_DIR=/system/etc/security/cacerts
TEMP_DIR="/data/local/tmp/tmp-ca-copy"

# 尝试卸载临时文件系统
umount -f $SYS_CERT_DIR 2>/dev/null
umount -f $APEX_CERT_DIR 2>/dev/null

# 清理临时目录
rm -rf $TEMP_DIR 2>/dev/null

# 最后的清理消息
echo "TrustUserCerts 模块已卸载"
