# 快速启动指南

## 环境要求

- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio / VS Code
- Android SDK (Android开发)
- Xcode (iOS开发，macOS only)

## 安装步骤

### 1. 检查Flutter环境

```bash
flutter --version
```

如果未安装，请参考：
- Windows: [Flutter Windows安装指南](https://docs.flutter.dev/get-started/install/windows)
- macOS: [Flutter macOS安装指南](https://docs.flutter.dev/get-started/install/macos)
- Linux: [Flutter Linux安装指南](https://docs.flutter.dev/get-started/install/linux)

### 2. 克隆项目

```bash
git clone <项目地址>
cd bucket-water-oms-admin-mobile
```

### 3. 安装依赖

```bash
flutter pub get
```

### 4. 运行应用

#### 开发模式

```bash
# 运行调试版本
flutter run

# 运行指定设备
flutter run -d <device_id>

# 查看可用设备
flutter devices
```

#### 构建发布版本

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (macOS only)
flutter build ios --release
```

## 项目结构说明

```
lib/
├── main.dart                 # 应用入口
├── core/                     # 核心配置
│   └── theme/               # 主题系统
├── shared/                   # 共享资源
│   ├── widgets/            # UI组件
│   └── components/         # 业务组件
├── pages/                   # 页面
│   ├── login/              # 登录
│   ├── owner/             # 水站老板端
│   ├── driver/            # 司机端
│   └── warehouse/         # 仓库端
└── models/                 # 数据模型（待创建）
```

## 功能演示

### 水站老板端

1. 启动应用，选择"水站老板端"
2. 查看首页：
   - 账户余额和信用额度
   - 欠桶预警
   - 快捷操作
   - 实时库存
3. 切换底部导航到"订单"
4. 查看订单状态和配送进度
5. 切换到"财务"查看月度对账单
6. 切换到"我的"查看个人中心

### 司机端

1. 返回登录页，选择"司机配送端"
2. 查看任务中心：
   - 今日任务统计
   - 智能路线规划
   - 待配送任务列表
3. 点击任务进入详情
4. 切换到"空桶"查看押金管理
5. 进行回桶操作

### 仓库端

1. 返回登录页，选择"仓库管理端"
2. 查看首页概览：
   - 今日出入库统计
   - 库存预警
   - 最近任务
3. 切换到"入库"管理采购入库
4. 切换到"出库"管理订单出库
5. 切换到"库存"进行盘点

## 常见问题

### Q: 依赖安装失败？

```bash
# 清理缓存重新安装
flutter clean
flutter pub cache repair
flutter pub get
```

### Q: Android构建失败？

```bash
# 检查Android SDK
flutter doctor -v

# 配置Android SDK路径
export ANDROID_HOME=/path/to/android/sdk
```

### Q: iOS构建失败？

确保已安装Xcode和CocoaPods：

```bash
cd ios
pod install
cd ..
flutter build ios
```

## 开发建议

### 代码规范

1. 使用 `flutter_lints` 规范代码
2. 遵循 Dart 风格指南
3. 使用 `dart format` 格式化代码

```bash
# 格式化代码
dart format .

# 运行静态分析
flutter analyze
```

### 状态管理

当前使用 Provider，建议：
- 简单状态使用 `ChangeNotifier`
- 复杂状态使用 `ChangeNotifierProvider`
- 全局状态使用 `MultiProvider`

### 路由管理

当前使用 Navigator，建议后续集成 `go_router`：
- 声明式路由
- 深层链接支持
- 路由守卫

## 后端对接

### 配置API地址

在 `lib/core/constants/` 创建 `api_constants.dart`：

```dart
class ApiConstants {
  static const String baseUrl = 'https://api.example.com';
  static const String login = '/auth/login';
  static const String orders = '/orders';
  // ...
}
```

### 创建API服务

```dart
class ApiService {
  final Dio _dio;

  ApiService() : _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 30),
  ));
}
```

## 测试

```bash
# 运行所有测试
flutter test

# 运行特定测试
flutter test test/widget_test.dart

# 生成覆盖率报告
flutter test --coverage
```

## 部署

### Google Play

1. 创建签名密钥
2. 配置 `android/app/build.gradle`
3. 构建发布版本
4. 上传到 Play Console

### Apple App Store

1. 创建 App Store Connect 应用
2. 配置 Xcode 项目
3. 构建发布版本
4. 上传到 App Store Connect

## 技术支持

- 文档: [Flutter官方文档](https://docs.flutter.dev/)
- 社区: [Flutter社区](https://flutter.dev/community)
- 问题反馈: [GitHub Issues](https://github.com/example/repo/issues)

## 下一步

1. ✅ 完成基础UI开发
2. ⏳ 集成后端API
3. ⏳ 实现用户认证
4. ⏳ 添加地图功能
5. ⏳ 实现离线模式
6. ⏳ 添加推送通知
7. ⏳ 集成微信支付
8. ⏳ 性能优化

---

**祝你开发愉快！** 🚀
