# Trust User Certificates

这个Magisk模块将用户安装的证书添加到系统证书存储区和APEX Conscrypt证书存储区，使其在构建信任链时自动被使用。该模块使开发者不需要在应用程序的清单文件中添加network_security_config属性。

## 特点

* 支持多用户
* 支持Magisk/KernelSU/KernelSU Next
* 支持有和没有mainline/conscrypt更新的设备
* 增强的日志记录和错误处理
* 支持从Android 7到Android 16的设备
* 自动更新支持
* 优化的性能和资源使用

根据您的Android版本和Google Play安全更新版本，您的证书将存储在`/system/etc/security/cacerts`或`/apex/com.android.conscrypt/cacerts/`中。此模块处理所有场景，并在任何Android 7到Android 16的设备上都能工作。

## 使用方法

### 安装证书

1. 通过[正常流程](https://support.portswigger.net/customer/portal/articles/1841102-installing-burp-s-ca-certificate-in-an-android-device)安装证书作为用户证书
2. 重启设备
3. 证书复制过程会在设备启动时进行
4. 安装的用户证书现在会自动成为系统信任的证书

### 删除证书

通过设置从用户证书存储区中删除证书，并重启设备。模块会自动从系统证书存储区中删除相应的证书。

## 日志和调试

模块运行日志保存在`/data/adb/modules/trustusercerts_enhanced/log.txt`中，可用于调试和故障排除。

## 更新日志

### v1.0
* 首次发布
* 结合了ConscryptTrustUserCerts和AlwaysTrustUserCerts的功能
* 增加了对多用户支持
* 增加了详细的日志记录
* 优化了脚本性能
* 添加了错误处理
* 支持Android 7-16
* 支持Magisk/KernelSU

## 致谢

本模块基于以下项目的工作：
* [ConscryptTrustUserCerts](https://github.com/nccgroup/ConscryptTrustUserCerts) by Xavier Cervilla (NCC Group)
* [AlwaysTrustUserCerts](https://github.com/NVISOsecurity/AlwaysTrustUserCerts) by Jeroen Beckers (NVISO.eu)
