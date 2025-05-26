# 贡献指南

感谢您考虑为 Trust User Certificates 模块做出贡献！以下是一些指导原则，以帮助您开始。

## 开发环境设置

1. 克隆仓库：
```bash
git clone https://github.com/hydrz/TrustUserCerts.git
cd TrustUserCerts
```

2. 设置开发环境：
```bash
./workflow.sh fix-perm  # 确保所有脚本有执行权限
```

3. 进行更改并测试：
   - 修改 `src/` 目录下的相关文件
   - 使用 `./workflow.sh test` 检查模块完整性
   - 使用 `./workflow.sh build` 构建模块
   - 在测试设备上通过Magisk Manager安装构建的ZIP文件
   - 确认功能正常工作

## 提交流程

1. 创建新分支：
```bash
git checkout -b feature-name
```

2. 进行更改并提交：
```bash
git add .
git commit -m "添加了xxx功能"
```

3. 推送到GitHub：
```bash
git push origin feature-name
```

4. 创建拉取请求

## 版本发布流程

1. 使用版本更新工作流：
```bash
./workflow.sh version v1.x
```

2. 更新 CHANGELOG.md 文件，添加版本更新内容

3. 提交更改并创建标签：
```bash
git add module.prop update.json CHANGELOG.md
git commit -m "准备发布 vX.X"
git tag vX.X
git push origin vX.X
git push origin main
git push origin vX.X
git push origin main
```

4. GitHub Actions 将自动构建和发布新版本

## 代码规范

- 脚本中使用清晰的注释
- 提供有意义的提交消息
- 遵循README.md中描述的项目结构

## 测试

- 在提交之前，请在不同的Android版本上测试您的更改
- 确保模块在有和没有Conscrypt的设备上都能工作
- 验证用户证书是否正确添加到信任存储

## 报告问题

如发现问题，请在GitHub Issues中报告，并包括：
- 您的设备信息（型号、Android版本）
- 详细的问题描述
- 复现步骤
- 日志文件（如可能）
