# 🚀 水厂订货管理系统 - 项目启动指南

## ⚠️ Flutter SDK 安装说明

由于当前环境未预装Flutter SDK，你需要手动完成安装。以下是详细步骤：

---

## 📥 第一步：安装 Flutter SDK

### 快速安装（约5分钟）

#### Windows 系统

**方法A：使用我为你准备的自动化脚本（推荐）**

1. **打开 PowerShell（管理员）**
   - 按 `Win + X` → 选择 "Windows PowerShell (管理员)"

2. **允许脚本执行**
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. **运行安装脚本**
   ```powershell
   cd "c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile"
   .\install_flutter.ps1
   ```

4. **按照脚本提示完成安装**
   - 脚本会自动下载Flutter SDK（约550MB）
   - 自动解压到正确位置
   - 自动配置环境变量
   - 自动验证安装

**方法B：手动安装**

1. **下载Flutter SDK**
   - 访问：https://flutter.dev/docs/get-started/install/windows
   - 或直接下载：https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.0-stable.zip

2. **解压文件**
   - 创建文件夹：`C:\Users\你的用户名\AppData\Local\Flutter`
   - 解压zip文件到该目录

3. **配置环境变量**
   - 按 `Win + R` → 输入 `sysdm.cpl` → 回车
   - 点击 "环境变量"
   - 在"用户变量"的Path中添加：`C:\Users\你的用户名\AppData\Local\Flutter\bin`

4. **验证安装**
   - 打开新的PowerShell窗口
   - 运行：`flutter doctor`
   - 运行：`flutter --version`

#### macOS 系统

```bash
# 使用Homebrew安装
brew install flutter

# 或手动下载并配置
# 下载: https://flutter.dev/docs/get-started/install/macos
```

#### Linux 系统

```bash
# 使用snap安装
sudo snap install flutter --classic

# 或手动下载并配置
# 下载: https://flutter.dev/docs/get-started/install/linux
```

---

## ✅ 第二步：验证安装

安装完成后，打开**新的** PowerShell 窗口（重要！），运行以下命令：

```powershell
# 1. 检查Flutter版本
flutter --version

# 2. 检查Flutter环境状态
flutter doctor

# 3. 查看可用设备
flutter devices
```

**预期输出示例：**
```
Flutter 3.24.0 • channel stable • https://github.com/flutter/flutter.git
Framework • revision 309b52e69d (7 months ago) • 2024-07-16
Engine • revision 9d13ea00c2
Tools • Dart 3.5.0 • DevTools 2.37.0
```

---

## 📦 第三步：安装项目依赖

```powershell
# 进入项目目录
cd "c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile"

# 安装依赖包
flutter pub get
```

**预期输出：**
```
Getting dependencies... 
Resolving dependencies... 
Downloading packages... 
Got dependencies!
```

---

## 🎯 第四步：运行项目

### 开发模式运行

```powershell
# 在默认设备上运行
flutter run

# 查看所有可用设备
flutter devices

# 在指定设备上运行
flutter run -d <device_id>

# 示例：在Android模拟器上运行
flutter run -d emulator-5554

# 示例：在Chrome上运行
flutter run -d chrome
```

### Web平台运行

```powershell
flutter run -d chrome
```

### Android模拟器运行

```powershell
# 启动模拟器（需要先在Android Studio中配置）
flutter emulators --launch <emulator_id>

# 运行应用
flutter run -d <emulator_id>
```

### 真机调试

**Android：**
1. 手机开启开发者模式
2. 手机开启USB调试
3. 用USB连接电脑
4. 运行：`flutter run -d <手机设备ID>`

**iOS（仅macOS）：**
1. Xcode中添加Apple ID
2. 选择目标设备和签名证书
3. 运行：`flutter run -d <ios设备ID>`

---

## 🏗️ 第五步：构建发布版本

### Android

```powershell
# 构建Release APK
flutter build apk --release

# 构建Debug APK（更快）
flutter build apk --debug

# 构建App Bundle（Google Play）
flutter build appbundle --release
```

APK输出位置：`build/app/outputs/flutter-apk/`

### iOS（仅macOS）

```powershell
# 构建Release版本
flutter build ios --release

# 构建用于测试的版本
flutter build ios --debug
```

IPA输出位置：`build/ios/iphoneos/`

---

## 🐛 常见问题排查

### 问题1：flutter命令找不到

**症状：** `'flutter' 不是内部或外部命令`

**解决方法：**
1. 确认已添加Flutter到PATH
2. 关闭并重新打开PowerShell窗口
3. 运行：`echo $env:Path` 确认包含Flutter路径

### 问题2：Android license未授权

**症状：** `Android license status unknown`

**解决方法：**
```powershell
flutter doctor --android-licenses
# 按提示接受所有许可协议
```

### 问题3：Android SDK未找到

**症状：** `Unable to locate Android SDK`

**解决方法：**
1. 安装 Android Studio
2. 或者手动设置环境变量：
   ```powershell
   [System.Environment]::SetEnvironmentVariable(
       "ANDROID_HOME", 
       "C:\Users\你的用户名\AppData\Local\Android\Sdk", 
       "User"
   )
   ```

### 问题4：依赖安装失败

**症状：** `Error retrieving dependencies`

**解决方法：**
```powershell
# 清理缓存
flutter clean

# 重新安装依赖
flutter pub get

# 或升级依赖
flutter pub upgrade
```

### 问题5：设备未检测到

**症状：** `No devices connected`

**解决方法：**
```powershell
# 查看所有设备（包括未连接的）
flutter devices

# 如果是模拟器，先启动模拟器
flutter emulators
flutter emulators --launch <emulator_id>
```

---

## 📋 项目结构回顾

安装完成后，你可以浏览以下文件：

```
bucket-water-oms-admin-mobile/
├── lib/
│   ├── main.dart                          # 应用入口
│   ├── core/theme/                        # 主题系统
│   │   ├── app_colors.dart               # 颜色定义
│   │   ├── app_text_styles.dart          # 文字样式
│   │   └── app_theme.dart                 # 主题配置
│   ├── shared/
│   │   ├── widgets/                       # UI组件库
│   │   │   ├── app_app_bar.dart         # 应用栏
│   │   │   ├── app_tab_bar.dart         # 标签栏
│   │   │   ├── app_card.dart            # 卡片
│   │   │   ├── app_button.dart          # 按钮
│   │   │   ├── app_text_field.dart      # 输入框
│   │   │   └── app_bottom_bar.dart      # 底部导航
│   │   └── components/                   # 业务组件
│   │       ├── status_badge.dart         # 状态徽章
│   │       ├── stat_card.dart           # 统计卡片
│   │       ├── quick_action_button.dart # 快捷操作
│   │       └── product_card.dart         # 商品卡片
│   └── pages/
│       ├── login/                         # 登录页
│       │   └── login_page.dart
│       ├── owner/                         # 水站老板端
│       │   ├── owner_home_page.dart     # 首页
│       │   ├── owner_orders_page.dart   # 订单列表
│       │   ├── owner_statement_page.dart # 对账单
│       │   └── owner_profile_page.dart  # 个人中心
│       ├── driver/                        # 司机端
│       │   └── driver_tasks_page.dart   # 任务中心
│       └── warehouse/                      # 仓库端
│           └── warehouse_home_page.dart   # 首页
├── pubspec.yaml                           # 项目配置
├── README.md                              # 项目说明
├── QUICKSTART.md                          # 快速启动
├── SETUP_INSTRUCTIONS.md                   # 安装指南
└── STARTUP.md                             # 启动指南（本文档）
```

---

## 🎨 应用功能预览

运行 `flutter run` 后，你可以体验：

### 🌟 水站老板端
- **首页仪表盘**：账户余额、信用额度、欠桶预警
- **订单管理**：订单状态跟踪、配送进度
- **对账单**：月度账单查看
- **个人中心**：用户信息、菜单导航

### 🚚 司机端
- **任务中心**：今日任务统计、待配送列表
- **空桶管理**：押金统计、欠桶预警

### 🏭 仓库端
- **首页概览**：出入库统计、库存预警
- **入库管理**：采购入库单处理
- **出库管理**：订单出库管理
- **库存盘点**：实时库存查看

---

## 🔧 开发工具推荐

### IDE

1. **VS Code**（推荐）
   - 插件：Flutter、Dart
   - 轻量级、快速启动
   - 调试方便

2. **Android Studio**
   - 功能完整
   - 内置Android SDK
   - 适合复杂项目

3. **IntelliJ IDEA**
   - 插件：Flutter、Dart
   - 强大的代码分析

### 调试工具

1. **Flutter Inspector**
   - 检查widget树
   - 调试布局问题

2. **DevTools**
   - 性能分析
   - 网络请求查看

3. **adb**
   - Android设备调试
   - 日志查看

---

## 📚 学习资源

### Flutter 官方文档
- 官方文档：https://flutter.dev/docs
- API文档：https://api.flutter.dev
- Codelabs：https://flutter.dev/docs/codelabs

### 中文资源
- Flutter中文网：https://flutter.cn
- Flutter社区：https://flutterchina.club
- 微信小程序：Flutter情报局

### 视频教程
- 官方YouTube：Flutter
- B站：很多优质Flutter教程

---

## 🆘 获取帮助

### 运行 flutter doctor

```powershell
# 查看详细诊断信息
flutter doctor -v

# 只显示问题
flutter doctor -v | Select-String "✗"
```

### 查看日志

**Android：**
```powershell
adb logcat | Select-String "flutter"
```

**应用内：**
```dart
// 在代码中添加日志
import 'dart:developer' as developer;

developer.log('日志信息', name: 'MyApp');
```

---

## ✅ 检查清单

在继续之前，确认以下都已完成：

- [ ] Flutter SDK 已下载并解压
- [ ] Flutter/bin 已添加到 PATH
- [ ] 已打开新的PowerShell窗口
- [ ] `flutter --version` 能正常显示版本
- [ ] `flutter doctor` 显示 ✓
- [ ] 项目目录已打开
- [ ] `flutter pub get` 已成功执行

---

## 🎉 下一步

安装和配置完成后，你可以：

1. **运行应用**
   ```powershell
   flutter run
   ```

2. **探索代码**
   - 阅读 `lib/main.dart` 了解应用结构
   - 查看 `lib/shared/widgets/` 了解组件库
   - 查看 `lib/pages/` 了解各个角色页面

3. **开始开发**
   - 添加新功能
   - 对接后端API
   - 实现数据持久化

---

## 📞 快速联系

如遇到问题：

1. 查看本文档的"常见问题排查"部分
2. 运行 `flutter doctor -v` 查看详细错误
3. 查看 Flutter 官方文档
4. 在项目中创建 Issue 反馈

---

**祝你开发愉快！** 🚀

---

*最后更新：2026-04-19*  
*项目版本：v1.0.0*  
*文档版本：v1.0*
