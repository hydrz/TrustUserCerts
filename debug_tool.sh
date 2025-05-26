#!/system/bin/sh
# 调试工具脚本
MODDIR=${0%/*}
LOG_FILE="$MODDIR/log.txt"

# 设备信息
echo "======= 设备信息 =======" > $LOG_FILE
echo "Android版本: $(getprop ro.build.version.release)" >> $LOG_FILE
echo "SDK版本: $(getprop ro.build.version.sdk)" >> $LOG_FILE
echo "设备型号: $(getprop ro.product.model)" >> $LOG_FILE
echo "设备名称: $(getprop ro.product.device)" >> $LOG_FILE
echo "制造商: $(getprop ro.product.manufacturer)" >> $LOG_FILE
echo "" >> $LOG_FILE

# 检查是否存在Conscrypt
echo "======= 证书存储状态 =======" >> $LOG_FILE
if [ -d "/apex/com.android.conscrypt/cacerts/" ]; then
    echo "Conscrypt证书存在: 是" >> $LOG_FILE
    echo "证书数量: $(ls -1 /apex/com.android.conscrypt/cacerts/ 2>/dev/null | wc -l)" >> $LOG_FILE
else
    echo "Conscrypt证书存在: 否" >> $LOG_FILE
fi

echo "系统证书数量: $(ls -1 /system/etc/security/cacerts/ 2>/dev/null | wc -l)" >> $LOG_FILE
echo "" >> $LOG_FILE

# 检查是否存在用户证书
echo "======= 用户证书状态 =======" >> $LOG_FILE
user_certs=0
for dir in /data/misc/user/*/; do
    if [ -d "${dir}cacerts-added" ]; then
        user_id=$(basename "$dir")
        cert_count=$(ls -1 "${dir}cacerts-added/" 2>/dev/null | wc -l)
        echo "用户$user_id证书数量: $cert_count" >> $LOG_FILE
        user_certs=$((user_certs + cert_count))
    fi
done
echo "总用户证书数量: $user_certs" >> $LOG_FILE

echo "调试信息已保存至: $LOG_FILE"
