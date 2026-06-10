# Flutter SDK 安装指南

## 方法一：运行自动化脚本（推荐）

1. **以管理员身份运行 PowerShell**
   - 右键点击 PowerShell 图标
   - 选择"以管理员身份运行"

2. **进入项目目录**
   ```powershell
   cd "c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile"
   ```

3. **运行安装脚本**
   ```powershell
   .\install_flutter.ps1
   ```

4. **按照提示操作**
   - 脚本会自动下载、解压和配置Flutter SDK

## 方法二：手动安装

### 步骤1：下载Flutter SDK

访问以下链接下载最新稳定版Flutter SDK（约550MB）：

**官方下载页面**: https://flutter.dev/docs/get-started/install/windows

**直接下载链接**:
- 3.24.0稳定版: https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.0-stable.zip
- 最新版本: https://flutter.dev/docs/get-started/install/windows

### 步骤2：解压Flutter SDK

1. 创建安装目录（推荐）：
   ```powershell
   mkdir "$env:USERPROFILE\AppData\Local\Flutter"
   ```

2. 解压下载的zip文件到该目录

3. 或者右键点击zip文件 → "全部解压缩" → 选择上述目录

### 步骤3：配置环境变量

1. 按 `Win + R` 打开运行对话框
2. 输入 `sysdm.cpl` 回车，打开系统属性
3. 点击"高级"选项卡 → "环境变量"
4. 在"用户变量"中找到"Path" → 点击"编辑"
5. 点击"新建" → 添加Flutter的bin目录路径：
   ```
   C:\Users\你的用户名\AppData\Local\Flutter\bin
   ```
6. 点击"确定"保存

### 步骤4：验证安装

1. **打开新的PowerShell窗口**（重要：需要新窗口才能加载新的PATH）

2. 运行Flutter doctor检查环境：
   ```powershell
   flutter doctor
   ```

3. 查看Flutter版本：
   ```powershell
   flutter --version
   ```

## 方法三：使用Android Studio插件

如果你已经安装了Android Studio：

1. 打开 Android Studio
2. 进入 File → Settings → Plugins
3. 搜索 "Flutter"
4. 点击 "Install"
5. 重启 Android Studio
6. Flutter会自动配置

## 运行项目

安装完成后，在项目目录中运行：

```powershell
# 进入项目目录
cd "c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile"

# 安装依赖
flutter pub get

# 运行应用
flutter run

# 或指定设备运行
flutter devices        # 查看可用设备
flutter run -d <设备ID>  # 在指定设备运行
```

## 常见问题

### Q1: flutter命令找不到？

**原因**: 环境变量未配置或未生效

**解决方法**:
1. 关闭所有PowerShell/CMD窗口
2. 重新打开PowerShell
3. 检查PATH是否包含Flutter的bin目录
   ```powershell
   echo $env:Path
   ```

### Q2: 下载速度慢？

**解决方法**:
1. 使用VPN
2. 使用国内镜像：https://flutter.cn/community/china
3. 使用IDM等下载工具手动下载

### Q3: Android SDK未检测到？

**解决方法**:
1. 安装 Android Studio
2. 在 Android Studio 中安装 Android SDK
3. 运行 `flutter doctor --android-licenses` 接受许可协议
4. 或者手动配置 ANDROID_HOME 环境变量

### Q4: 运行flutter doctor报错？

常见错误和解决方法：

#### "Android license status unknown"
```powershell
flutter doctor --android-licenses
```
按照提示接受所有许可协议。

#### "cmdline-tools component is missing"
在 Android Studio 中：
1. Settings → Appearance & Behavior → System Settings → Android SDK
2. 点击 "SDK Tools" 选项卡
3. 勾选 "Android SDK Command-line Tools (latest)"
4. 点击 "Apply"

#### "Unable to locate Android SDK"
1. 在 Android Studio 中找到 SDK 路径（通常是 `C:\Users\你的用户名\AppData\Local\Android\Sdk`）
2. 设置环境变量：
   ```powershell
   [System.Environment]::SetEnvironmentVariable("ANDROID_HOME", "C:\Users\你的用户名\AppData\Local\Android\Sdk", "User")
   ```

## Flutter doctor 输出说明

运行 `flutter doctor` 后，你会看到类似输出：

```
Doctor summary (2 to show):
  ✗ No devices connected ( Flutter is not detecting any devices )
  ✓ Flutter (Channel stable • 3.24.0)
  ✓ Android toolchain - develop for Android devices
```

- ✓ 表示该项配置正确
- ✗ 表示存在问题
- ! 表示警告（不影响运行但建议修复）

## 项目依赖安装

```powershell
# 安装依赖
flutter pub get

# 升级依赖
flutter pub upgrade

# 清理并重新安装
flutter clean
flutter pub get
```

## 构建发布版本

```powershell
# Android APK
flutter build apk --release

# Android App Bundle (Google Play)
flutter build appbundle --release

# 查看构建输出
ls build/app/outputs/flutter-apk/
```

## IDE配置

### VS Code
1. 安装 Flutter 插件
2. 安装 Dart 插件
3. 按 F5 开始调试

### Android Studio
1. File → Open → 选择项目目录
2. Flutter插件会自动识别项目
3. 运行 main.dart

## 技术支持

- 官方文档: https://flutter.dev/docs
- 中文社区: https://flutter.cn
- Stack Overflow: https://stackoverflow.com/questions/tagged/flutter
- GitHub Issues: https://github.com/flutter/flutter/issues

## 快速检查清单

安装完成后，运行以下命令确认一切正常：

```powershell
# 1. 检查Flutter版本
flutter --version

# 2. 检查Flutter环境
flutter doctor

# 3. 查看可用设备
flutter devices

# 4. 运行应用
cd "c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile"
flutter pub get
flutter run
```

如果所有命令都能正常执行，恭喜你，Flutter环境配置成功！

---

**提示**: 安装过程中如果遇到任何问题，可以查看官方文档或使用 `flutter doctor -v` 获取详细信息。
