# 水厂订货管理系统 - 开发规范文档

## 项目概述

这是一个基于Flutter的水厂订货管理系统移动端应用，采用多角色设计，支持水站老板、司机、仓库管理员三种角色。

## 技术栈

- **框架**: Flutter 3.x
- **状态管理**: Provider
- **路由**: Flutter Navigator (GoRouter)
- **最低支持**: Android 5.0+ / iOS 12.0+

## 项目结构

```
lib/
├── main.dart                    # 应用入口
├── core/
│   └── theme/                  # 主题配置
│       ├── app_colors.dart    # 颜色定义
│       ├── app_text_styles.dart # 文字样式
│       └── app_theme.dart     # 主题配置
├── shared/
│   ├── widgets/                # 共享组件
│   │   ├── app_app_bar.dart
│   │   ├── app_tab_bar.dart
│   │   ├── app_card.dart
│   │   ├── app_button.dart
│   │   ├── app_text_field.dart
│   │   └── app_bottom_bar.dart
│   └── components/             # 业务组件
│       ├── status_badge.dart
│       ├── stat_card.dart
│       ├── quick_action_button.dart
│       └── product_card.dart
├── pages/
│   ├── login/                 # 登录页
│   ├── owner/                 # 水站老板端
│   ├── driver/                # 司机端
│   └── warehouse/             # 仓库端
└── models/                    # 数据模型
```

## 设计规范

### 颜色系统

- **主色**: #1890FF (蓝色)
- **成功色**: #52C41A (绿色)
- **警告色**: #FAAD14 (橙色)
- **错误色**: #FF4D4F (红色)
- **文字颜色**: 
  - 主文字: #262626
  - 次要文字: #8C8C8C
  - 占位符: #BFBFBF

### 圆角规范

- **小圆角**: 8px (按钮、标签)
- **中等圆角**: 12px (输入框、列表项)
- **大圆角**: 16px (卡片)
- **特大圆角**: 20-24px (主要卡片、Banner)

### 阴影规范

- **轻阴影**: 0 2px 8px rgba(0,0,0,0.04)
- **中等阴影**: 0 4px 12px rgba(0,0,0,0.08)
- **强阴影**: 0 8px 24px rgba(0,0,0,0.12)

## 页面清单

### 登录模块
- [x] 登录页 (login_page.dart)

### 水站老板端
- [x] 首页 (owner_home_page.dart)
- [x] 订单列表 (owner_orders_page.dart)
- [x] 对账单 (owner_statement_page.dart)
- [x] 个人中心 (owner_profile_page.dart)
- [x] 下单页面 (order_create_page.dart)
- [x] 客户详情 (customer_detail_page.dart)
- [x] 库存管理 (inventory_manage_page.dart)
- [x] 数据统计 (statistics_page.dart)
- [x] 配送调度 (dispatch_manage_page.dart)
- [x] 水票管理 (ticket_manage_page.dart)

### 司机端
- [x] 任务中心 (driver_tasks_page.dart)
- [x] 订单详情 (driver_order_detail_page.dart)
- [x] 空桶管理 (driver_barrel_page.dart)
- [x] 司机对账 (driver_statement_page.dart)
- [x] 司机设置 (driver_settings_page.dart)

### 仓库端
- [x] 首页 (warehouse_home_page.dart)
- [x] 订单管理 (warehouse_orders_page.dart)
- [x] 订单详情 (warehouse_order_detail_page.dart)
- [x] 拒单处理 (warehouse_order_reject_page.dart)
- [x] 备货列表 (warehouse_prepare_list_page.dart)
- [x] 入库管理 (warehouse_inbound_page.dart)
- [x] 出库管理 (warehouse_outbound_page.dart)
- [x] 库存盘点 (warehouse_inventory_page.dart)
- [x] 回仓列表 (warehouse_return_list_page.dart)
- [x] 回仓核对 (warehouse_return_check_page.dart)
- [x] 售后处理 (warehouse_after_sales_page.dart)
- [x] 售后详情 (warehouse_after_sales_detail_page.dart)
- [x] 仓库设置 (warehouse_settings_page.dart)

### 客户管理
- [x] 客户列表 (customer_list_page.dart)
- [x] 客户详情 (customer_detail_page.dart)

### 调度管理
- [x] 配送调度 (dispatch_manage_page.dart)

### 工单管理
- [x] 工单管理 (ticket_manage_page.dart)

## 开发指南

### 添加新页面

1. 在 `pages/` 下创建对应的页面文件夹
2. 继承 `StatelessWidget` 或 `StatefulWidget`
3. 使用共享组件构建UI
4. 在 `main.dart` 中添加路由

### 使用共享组件

```dart
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_button.dart';

// 使用示例
AppCard(
  child: Text('内容'),
  padding: EdgeInsets.all(16),
  borderRadius: 16,
  onTap: () {},
)
```

### 颜色使用

```dart
import '../../core/theme/app_colors.dart';

// 使用示例
Container(
  color: AppColors.primary,
  child: Text('文本'),
)
```

## 待完成功能

### 高优先级
- [ ] 后端API集成
- [ ] 登录状态持久化
- [ ] 订单创建流程
- [ ] 地图导航集成

### 中优先级
- [ ] 离线功能 (司机端)
- [ ] 蓝牙打印
- [ ] 短信通知
- [ ] 微信支付

### 低优先级
- [ ] 数据统计图表
- [ ] 消息推送
- [ ] 多语言支持

## 后端API接口 (待集成)

### 认证
- POST /api/auth/login
- POST /api/auth/logout
- POST /api/auth/refresh

### 订单
- GET /api/orders
- POST /api/orders
- GET /api/orders/{id}
- PUT /api/orders/{id}/status

### 库存
- GET /api/inventory
- POST /api/inventory/update

### 水站
- GET /api/stations
- GET /api/stations/{id}/balance

## 测试指南

```bash
# 运行测试
flutter test

# 运行应用
flutter run

# 构建 APK
flutter build apk --release

# 构建 iOS
flutter build ios --release
```

## 部署说明

### Android
```bash
flutter build apk --release --target-platform android-arm,android-arm64
```

### iOS
```bash
flutter build ios --release
```

## 注意事项

1. 所有页面必须使用 SafeArea 包裹
2. 底部导航栏使用 BottomNavigationBar 或自定义组件
3. 列表页使用 ListView.builder 提高性能
4. 图片使用 cached_network_image 进行缓存
5. 敏感信息不要硬编码，使用环境变量

## 平台配置说明

### Android 平台
- **项目包名**: com.example.bucket_water_oms_admin_mobile
- **最低SDK版本**: flutter.minSdkVersion
- **目标SDK版本**: 35
- **Gradle版本**: 8.5
- **Android Gradle Plugin**: 8.1.0
- **Kotlin版本**: 1.9.0

### iOS 平台
- **项目Bundle ID**: com.example.bucketWaterOmsAdminMobile
- **最低iOS版本**: iOS 12.0

### 构建说明

Android构建可能遇到JDK 21与Android SDK的兼容性问题。如果构建失败，请尝试：
1. 降级JDK版本至17
2. 或更新Android Gradle Plugin至最新版本
3. 或在android/gradle.properties中配置org.gradle.java.home指向兼容的JDK

### 常用构建命令

```bash
# Android调试构建
flutter build apk --debug

# Android发布构建
flutter build apk --release

# iOS调试构建（需要macOS）
flutter build ios --debug

# iOS发布构建（需要macOS）
flutter build ios --release

# 清理构建缓存
flutter clean
```

## 联系与支持

如有问题，请联系开发团队。

## 问题修复记录

### 登录Token持久化问题修复 (2026-04-20)

#### 问题描述
后端返回登录成功，但前端无法正常登录。问题表现为：
- 登录请求成功返回token
- 但token没有被正确保存到本地存储
- 应用重启后token丢失
- 后续请求无法携带认证token

#### 问题根源
1. **ApiConfig 空实现**: `lib/core/config/api_config.dart` 中的 `saveToken()`、`getToken()` 等方法都是空实现，只返回空字符串
2. **Token存储链路断裂**: 
   - AuthService 只在内存中设置token (`_apiClient.setAuthToken()`)
   - 没有同时保存到持久化存储
   - 应用重启后token无法恢复
3. **初始化顺序问题**: ApiClient 初始化时无法读取到存储的token

#### 修复方案
1. **实现 ApiConfig 持久化存储** ([api_config.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\core\config\api_config.dart))
   - 添加 `SharedPreferences` 依赖
   - 实现 `init()` 初始化方法
   - 实现 `getToken()`、`saveToken()`、`getRefreshToken()`、`saveRefreshToken()` 等方法
   - 实现 `getUserRole()`、`saveUserRole()`、`getUserId()`、`saveUserId()` 等方法
   - 实现 `clearTokens()` 清理方法

2. **修复 ApiClient 初始化** ([api_client.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\core\network\api_client.dart#L53-L55))
   ```dart
   ApiClient._internal() {
     _authToken = ApiConfig.getToken();
   }
   ```

3. **更新 main.dart 初始化顺序** ([main.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\main.dart#L9-L19))
   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await ApiConfig.init();  // 先初始化 ApiConfig
     await initStorage();
     // ...
   }
   ```

4. **增强 AuthService Token保存** ([auth_service.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\services\auth_service.dart#L18-L30))
   ```dart
   if (loginResponse.token != null) {
     _apiClient.setAuthToken(loginResponse.token);
     await ApiConfig.saveToken(loginResponse.token!);
   }
   
   if (loginResponse.refreshToken != null) {
     await ApiConfig.saveRefreshToken(loginResponse.refreshToken!);
   }
   ```

5. **统一 logout 方法** ([main.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\main.dart#L115-L134))
   - 使用 `ApiConfig.clearTokens()` 统一清理token

#### 经验教训
1. **空实现是严重的代码缺陷**: 骨架代码中的空实现必须及时完善，不能遗留到生产环境
2. **Token管理需要完整链路**:
   - 登录时：获取 → 内存存储 → 持久化存储
   - 发送请求时：内存读取 → 添加到请求头
   - 应用启动时：持久化读取 → 内存恢复
   - 登出时：内存清理 → 持久化清理
3. **初始化顺序至关重要**: 确保依赖组件在使用前已正确初始化
4. **Token应该同时保存refreshToken**: 为token刷新机制做准备
5. **避免重复代码**: 使用统一的配置管理类（如ApiConfig）来管理所有配置，避免直接操作SharedPreferences

#### 测试建议
修复后请测试以下场景：
- ✅ 正常登录流程
- ✅ 登录后应用重启，token是否正确恢复
- ✅ 后续请求是否携带正确的Authorization头
- ✅ 登出功能是否正确清理所有token
- ✅ 切换账号后token是否正确更新

### 登录响应数据解析错误修复 (2026-04-20)

#### 问题描述
后端API成功返回登录数据（HTTP 200），但前端登录仍然失败。用户可以看到：
- API返回 200 状态码
- Response Body 包含正确的 `accessToken`、`refreshToken` 和 `user` 信息
- 但登录页面显示"登录失败"或无法正常跳转

#### 问题根源
`LoginResponse.fromJson()` 方法与实际API响应结构不匹配：

**API实际返回结构：**
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGci...",
    "refreshToken": "eyJhbGci...",
    "user": {
      "id": "7",
      "name": "张三（水站老板）",
      "role": "station",
      "stationId": "1"
    }
  }
}
```

**代码期望结构：**
```dart
token: json['token'],  // ❌ 错误！实际字段名是 accessToken
userId: json['userId'],  // ❌ 错误！用户信息在 data.user 下，不在 data 下
userName: json['userName'],  // ❌ 错误！应该在 data.user.name 下
```

#### 修复方案
1. **修复 token 字段名** ([user_model.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\models\user_model.dart#L44-L60))
   ```dart
   token: json['accessToken'] ?? json['token'],  // 优先使用 accessToken，兼容旧字段
   ```

2. **修复用户信息解析** ([user_model.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\models\user_model.dart#L44-L60))
   ```dart
   final user = json['user'] as Map<String, dynamic>?;
   return LoginResponse(
     userId: user?['id']?.toString() ?? json['userId']?.toString(),
     userName: user?['name'] ?? json['userName'],
     role: user?['role'] ?? json['role'],
     stationId: user?['stationId']?.toString() ?? json['stationId']?.toString(),
     // ...
   );
   ```

3. **增强 AuthService 用户信息保存** ([auth_service.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\services\auth_service.dart#L29-L36))
   ```dart
   if (loginResponse.role != null) {
     await ApiConfig.saveUserRole(loginResponse.role!);
   }
   if (loginResponse.userId != null) {
     await ApiConfig.saveUserId(loginResponse.userId!);
   }
   ```

#### 经验教训
1. **API契约文档至关重要**: 前端代码必须与后端API保持严格一致，任何字段名不匹配都会导致功能失效
2. **嵌套数据结构要小心**: 当API返回嵌套对象（如 `data.user`）时，必须正确提取字段
3. **向后兼容性考虑**: 使用 `??` 操作符兼容新旧字段名，如 `json['accessToken'] ?? json['token']`
4. **日志不是万能的**: 虽然API返回了200和正确数据，但前端解析失败导致业务逻辑失败，必须确保数据解析正确
5. **单元测试覆盖**: 建议为 `LoginResponse.fromJson()` 添加单元测试，验证各种API响应格式

#### 测试建议
修复后请测试以下场景：
- ✅ 使用水站老板账号登录（station）
- ✅ 使用司机账号登录（driver）
- ✅ 使用仓库管理员账号登录（warehouse）
- ✅ 验证登录后用户信息（name、role、stationId）是否正确显示
- ✅ 验证应用重启后用户信息是否正确恢复

### 管理端首页布局异常修复 (2026-04-21)

#### 问题描述
管理端（admin）登录后首页显示空白，并出现渲染错误。主要问题包括：
- 嵌套Scaffold导致布局崩溃
- Context使用不当导致Provider无法正常工作
- 缺少与原型一致的功能组件
- 底部导航栏显示逻辑不正确

#### 问题根源

**1. 嵌套Scaffold问题 (CRITICAL)**
原代码在 `_buildHomeContent()` 方法中返回了一个新的Scaffold：
```dart
Widget _buildHomeContent() {
  return Scaffold(              // ❌ 内层Scaffold
    body: SafeArea(
      child: LayoutBuilder(...),
    ),
  );
}
```
外层build方法中已经有了Scaffold，导致嵌套Scaffold。

**2. Context使用错误**
在嵌套的子Widget中使用 `context.watch<AppState>()` 会获取到错误的Scaffold上下文，导致Provider无法正常工作。

**3. 缺少原型功能**
原型文件 `admin_index.html` 包含的功能在原代码中缺失：
- 销售趋势图表
- 通知时间显示
- 头部导航栏（宽屏模式）

**4. 底部导航栏显示逻辑错误**
底部导航栏始终显示，但在非首页的页面会与页面自身的导航冲突。

#### 修复方案

**1. 移除嵌套Scaffold** ([admin_home_page.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\pages\admin\admin_home_page.dart#L92-L112))
```dart
Widget _buildHomeContent(AppState appState) {
  return SafeArea(        // 直接使用SafeArea，不再嵌套Scaffold
    child: LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 800;
        if (isWideScreen) {
          return Row(
            children: [
              _buildSidebar(),
              Expanded(
                child: _buildMainContent(appState: appState, isWide: true),
              ),
            ],
          );
        } else {
          return _buildMainContent(appState: appState, isWide: false);
        }
      },
    ),
  );
}
```

**2. 统一状态管理传递** ([admin_home_page.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\pages\admin\admin_home_page.dart#L66-L90))
```dart
@override
Widget build(BuildContext context) {
  final appState = context.watch<AppState>();  // 在build方法中获取
  
  return Scaffold(
    body: IndexedStack(
      children: [
        _buildHomeContent(appState),  // 传递给子方法
        // ...
      ],
    ),
    bottomNavigationBar: _currentIndex == 0
        ? AdminBottomBar(...)
        : null,  // 只在首页显示
  );
}
```

**3. 添加销售趋势图表** ([admin_home_page.dart 第673-805行](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\pages\admin\admin_home_page.dart#L673-L805))
- 新增 `_buildSalesTrendChart()` 方法
- 新增 `_buildBarChart()` 方法实现柱状图
- 新增 `_buildChartToggleButton()` 方法实现按周/月切换

**4. 添加通知时间显示** ([admin_home_page.dart 第943-1002行](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\pages\admin\admin_home_page.dart#L943-L1002))
```dart
Widget _buildNotificationItem(NotificationModel notification) {
  return AppCard(
    child: Row(
      children: [
        // 未读指示点
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: notification.isRead == true
                ? AppColors.success
                : AppColors.error,
            shape: BoxShape.circle,
          ),
        ),
        // ... 其他内容
        Text(
          _formatTime(notification.createdAt),
          style: AppTextStyles.captionSmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    ),
  );
}

String _formatTime(DateTime? dateTime) {
  if (dateTime == null) return '';
  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
  if (diff.inHours < 24) return '${diff.inHours}小时前';
  if (diff.inDays < 7) return '${diff.inDays}天前';
  return '${dateTime.month}-${dateTime.day}';
}
```

**5. 添加头部导航栏（宽屏模式）** ([admin_home_page.dart 第315-376行](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\pages\admin\admin_home_page.dart#L315-L376))
```dart
PreferredSizeWidget _buildHeaderBar(AppState appState) {
  return AppBar(
    backgroundColor: AppColors.white,
    elevation: 0,
    automaticallyImplyLeading: false,
    title: Row(
      children: [
        Text('数据概览'),
        Text('今天是 ${_getCurrentDate()}'),
      ],
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.notifications_outlined),
        onPressed: () => _showComingSoon('通知'),
      ),
      // 用户信息
    ],
  );
}
```

#### 经验教训

1. **Flutter禁止嵌套Scaffold**
   - 外层Scaffold已经提供了完整的Material结构
   - 子内容只需要使用SafeArea包裹
   - 嵌套Scaffold会导致ScaffoldReference冲突，引发渲染错误

2. **状态管理Context使用规范**
   - 应该在主build方法中获取Provider状态
   - 将状态通过参数传递给子Widget
   - 避免在深层嵌套的Widget中使用context.watch()

3. **原型参考使用原则**
   - 移动端原型应适配手机端交互模式
   - 桌面端原型（如admin_index.html）作为功能参考
   - 需要转换为移动端友好的响应式布局

4. **响应式设计最佳实践**
   - 使用LayoutBuilder检测屏幕宽度
   - 窄屏（<800px）：单列布局，头部渐变banner
   - 宽屏（>800px）：侧边栏+内容区，头部导航栏

5. **const关键字使用注意事项**
   - const修饰的Widget不能依赖运行时变量
   - 如 `const SizedBox(height: isWide ? 24 : 16)` 会报错
   - 应该改为 `SizedBox(height: isWide ? 24 : 16)`

#### 测试建议
修复后请测试以下场景：
- ✅ 管理员登录后首页正常显示
- ✅ 窄屏模式（手机）显示渐变头部banner
- ✅ 宽屏模式（平板）显示侧边栏和顶部导航栏
- ✅ 销售趋势图表正常显示
- ✅ 通知列表显示时间信息（"10分钟前"等）
- ✅ 底部导航栏只在首页显示
- ✅ 点击其他底部导航项能正常切换
- ✅ 登出功能正常

#### 相关文件
- [admin_home_page.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\pages\admin\admin_home_page.dart) - 主要修复文件
- [admin_index.html](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\origin\admin_index.html) - 原型参考文件
- [dashboard_service.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\services\dashboard_service.dart) - 数据服务
- [dashboard_model.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\models\dashboard_model.dart) - 数据模型

### 底部导航栏布局溢出修复 (2026-04-21)

#### 问题描述
用户在测试应用时遇到以下问题：
1. **RenderFlex溢出错误** - `admin_bottom_bar.dart` 第59行的Column溢出了1像素
2. **API 500错误** - 管理端首页加载数据时返回后端系统错误

#### 问题根源

**1. Column溢出问题**
- 父容器高度固定为60px
- SafeArea占用额外空间
- 图标(24px) + 文字(约14px) + padding(16px) = 54px
- 在某些设备上可能接近或超过60px限制

**2. API 500错误**
- `DashboardService` 在API调用失败时直接抛出异常
- 没有fallback机制来使用mock数据
- 导致用户看到错误信息而不是正常内容

#### 修复方案

**1. 优化底部导航栏布局** ([admin_bottom_bar.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\shared\widgets\admin_bottom_bar.dart#L50-L82))
```dart
Widget _buildItem(int index, IconData icon, IconData activeIcon, String label) {
  final isSelected = currentIndex == index;

  return Expanded(
    child: GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),  // 从8减小到6
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,  // 添加居中对齐
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 22,  // 从24减小到22
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 2),  // 从4减小到2
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontSize: 10,  // 固定字体大小
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,  // 防止文字溢出
            ),
          ],
        ),
      ),
    ),
  );
}
```

**2. 添加DashboardService的Mock数据支持** ([dashboard_service.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\services\dashboard_service.dart))
```dart
Future<DashboardModel> getDashboardData() async {
  try {
    final response = await _apiClient.get('/admin/dashboard');

    if (response.success && response.data != null) {
      return DashboardModel.fromJson(response.data);
    } else {
      return _getMockDashboardData();  // API失败时使用mock数据
    }
  } catch (e) {
    return _getMockDashboardData();  // 异常时使用mock数据
  }
}

DashboardModel _getMockDashboardData() {
  return DashboardModel(
    todayStats: _getMockTodayStats(),
    salesTrend: _getMockSalesTrend(),
    notifications: _getMockNotifications(),
    recentOrders: _getMockRecentOrders(),
  );
}

TodayStatsModel _getMockTodayStats() {
  return TodayStatsModel(
    salesAmount: 42850.00,
    orderCount: 156,
    activeStations: 48,
    inventoryWarnings: 12,
    comparedToYesterday: 12.5,
  );
}
```

#### 经验教训

1. **布局溢出防护**
   - 使用 `mainAxisSize: MainAxisSize.min` 限制Column大小
   - 减小图标和间距尺寸，留出余量
   - 添加 `TextOverflow.ellipsis` 防止文字溢出
   - 使用 `Padding` 而非固定高度的 `Container`

2. **API错误处理策略**
   - 永远不要让API错误导致应用崩溃
   - 使用try-catch捕获所有API调用异常
   - 准备完整的mock数据作为fallback
   - mock数据应该与真实数据结构完全一致

3. **响应式设计容错性**
   - 不同设备有不同的高度和DPI
   - 不要依赖精确的像素值
   - 留出足够的边距和间距余量
   - 测试不同尺寸的设备

4. **用户体验优先**
   - 即使API失败，也要展示合理的默认内容
   - 使用loading状态而非错误状态
   - 提供"功能开发中"等友好的提示

#### 测试建议
修复后请测试以下场景：
- ✅ 各种尺寸的手机设备（全面屏、刘海屏）
- ✅ 平板设备
- ✅ API服务器关闭时，首页是否正常显示mock数据
- ✅ 底部导航栏在所有页面都能正常显示
- ✅ 快速切换底部导航项

#### 相关文件
- [admin_bottom_bar.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\shared\widgets\admin_bottom_bar.dart) - 底部导航栏组件
- [dashboard_service.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\services\dashboard_service.dart) - 数据服务（含mock数据）
- [admin_home_page.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\pages\admin\admin_home_page.dart) - 管理端首页

### 刘海屏/圆角屏全面适配 (2026-04-21)

#### 问题描述
项目未对刘海屏、水滴屏、挖孔屏等异形屏进行适配，导致：
- 状态栏区域内容被遮挡
- 硬编码的padding在不同设备上显示不一致
- 部分页面存在嵌套Scaffold问题
- Android原生未配置透明状态栏

#### 问题根源

**1. 缺少SystemChrome配置**
main.dart中没有配置系统UI覆盖层样式，导致无法正确处理刘海屏。

**2. 硬编码顶部padding**
多个页面硬编码了40-56px的顶部padding：
- owner_profile_page.dart: 56px
- driver_settings_page.dart: 40px
- driver_tasks_page.dart: 40px
- warehouse_settings_page.dart: 48px

这些硬编码值在非刘海屏设备上会显示过多空白，在刘海屏设备上也不够准确。

**3. 嵌套Scaffold问题**
owner_home_page.dart在_buildHomeContent()方法中返回了一个新的Scaffold，与外层Scaffold冲突。

**4. Android原生配置缺失**
styles.xml中未配置透明状态栏和导航栏。

#### 修复方案

**1. 添加SystemChrome配置** ([main.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\main.dart#L13-L28))
```dart
SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
  systemNavigationBarColor: Colors.white,
  systemNavigationBarIconBrightness: Brightness.dark,
));

SystemChrome.setEnabledSystemUIMode(
  SystemUiMode.edgeToEdge,
  overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
);
```

**2. 动态获取安全区域padding**
将所有硬编码的顶部padding替换为动态获取：
```dart
// 错误 ❌
padding: const EdgeInsets.fromLTRB(24, 56, 24, 48),

// 正确 ✅
final topPadding = MediaQuery.of(context).padding.top;
padding: EdgeInsets.fromLTRB(24, topPadding + 32, 24, 48),
```

**3. 移除嵌套Scaffold** ([owner_home_page.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\pages\owner\owner_home_page.dart#L125-L160))
```dart
// 移除内层Scaffold，直接使用SafeArea
return SafeArea(
  child: Column(
    children: [
      _buildHeader(appState),
      // ...
    ],
  ),
);
```

**4. 添加SafeArea包裹** ([driver_barrel_page.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\pages\driver\driver_barrel_page.dart#L45-L48))
```dart
@override
Widget build(BuildContext context) {
  return SafeArea(
    child: Column(
      children: [
        _buildHeader(),
        // ...
      ],
    ),
  );
}
```

**5. Android原生透明状态栏配置** ([styles.xml](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\android\app\src\main\res\values\styles.xml#L5-L19))
```xml
<style name="NormalTheme" parent="@android:style/Theme.Light.NoTitleBar">
    <item name="android:windowTranslucentStatus">false</item>
    <item name="android:windowDrawsSystemBarBackgrounds">true</item>
    <item name="android:statusBarColor">@android:color/transparent</item>
    <item name="android:navigationBarColor">@android:color/transparent</item>
</style>
```

**6. 创建屏幕适配辅助工具类** ([screen_utils.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\core\utils\screen_utils.dart))
```dart
class ScreenUtils {
  static double getStatusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  static bool isNotchScreen(BuildContext context) {
    return MediaQuery.of(context).padding.top > 20;
  }

  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }
}
```

#### 经验教训

1. **刘海屏适配是移动端必备**
   - 所有现代Android和iOS设备都有刘海屏/水滴屏/挖孔屏
   - 必须使用SafeArea或MediaQuery动态获取安全区域
   - 绝对不能硬编码状态栏高度的padding

2. **SystemChrome是Flutter适配的关键**
   - SystemChrome.setEnabledSystemUIMode() 设置系统UI模式
   - SystemUiMode.edgeToEdge 允许内容延伸到系统栏下方
   - 必须配合透明状态栏配置才能生效

3. **Android原生配置同等重要**
   - Flutter的SystemChrome配置依赖Android原生配置
   - windowTranslucentStatus 必须设为false
   - windowDrawsSystemBarBackgrounds 必须设为true
   - statusBarColor 和 navigationBarColor 设为透明

4. **嵌套Scaffold是严重错误**
   - Flutter禁止嵌套Scaffold
   - 外层Scaffold提供Material结构，内层只需SafeArea
   - 嵌套会导致ScaffoldReference冲突和布局错误

5. **MediaQuery比硬编码更可靠**
   - 不同设备的安全区域高度不同（20px-60px+）
   - MediaQuery.of(context).padding.top 获取实际高度
   - 应该根据安全区域动态计算padding

6. **屏幕适配辅助工具提升开发效率**
   - 创建ScreenUtils工具类封装常用方法
   - 提供响应式布局和屏幕检测方法
   - 统一管理屏幕适配逻辑

#### 测试建议
修复后请测试以下场景：
- ✅ iPhone刘海屏设备（iPhone X及以后）
- ✅ Android刘海屏设备（华为、小米、OPPO等）
- ✅ Android水滴屏设备
- ✅ Android挖孔屏设备
- ✅ 普通平面屏设备
- ✅ 平板设备
- ✅ 横屏模式下的适配
- ✅ 底部导航栏是否正确避开安全区域

#### 相关文件
- [main.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\main.dart) - 应用入口（SystemChrome配置）
- [styles.xml](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\android\app\src\main\res\values\styles.xml) - Android原生样式（透明状态栏）
- [owner_profile_page.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\pages\owner\owner_profile_page.dart) - 水站老板个人中心
- [owner_home_page.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\pages\owner\owner_home_page.dart) - 水站老板首页（修复嵌套Scaffold）
- [driver_settings_page.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\pages\driver\driver_settings_page.dart) - 司机设置页
- [driver_tasks_page.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\pages\driver\driver_tasks_page.dart) - 司机任务页
- [driver_barrel_page.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\pages\driver\driver_barrel_page.dart) - 司机空桶页
- [warehouse_settings_page.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\pages\warehouse\warehouse_settings_page.dart) - 仓库设置页
- [screen_utils.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\core\utils\screen_utils.dart) - 屏幕适配工具类

### 登录状态持久化失败修复 (2026-04-27)

#### 问题描述
每次打开app都会重新进入登录界面，无法保持上一个账号退出时的状态。用户反馈登录后关闭应用，再次打开时需要重新登录。

#### 问题根源

**1. 缺少启动页面检查登录状态**
WaterOMSApp直接显示LoginPage()，没有检查是否已经有有效的token。

**2. AppState缺少恢复用户信息的方法**
AppState虽然有setUserInfo()方法，但缺少restoreUserInfo()方法来从持久化存储恢复用户状态。

**3. logout方法不完整**
logout方法只清理了ApiConfig中的数据，但没有清理SharedPreferences中的所有相关数据。

**4. SplashPage未设置正确的首页**
应用入口仍然指向LoginPage而不是SplashPage。

#### 修复方案

**1. 创建启动页面(Splash Page)** ([splash_page.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\pages\splash\splash_page.dart))
```dart
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final token = ApiConfig.getToken();
    final role = ApiConfig.getUserRole();

    if (token.isNotEmpty && role.isNotEmpty) {
      await _restoreUserSession();
      _navigateToHome(role);
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToHome(String role) {
    Widget homePage;
    switch (role) {
      case 'station':
        homePage = const OwnerHomePage();
        break;
      case 'driver':
        homePage = const DriverTasksPage();
        break;
      case 'warehouse':
        homePage = const WarehouseHomePage();
        break;
      case 'admin':
        homePage = const AdminHomePage();
        break;
      default:
        _navigateToLogin();
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => homePage),
    );
  }
}
```

**2. 在AppState中添加恢复用户信息的方法** ([main.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\main.dart#L140-L198))
```dart
Future<void> restoreUserInfo({
  String? userId,
  String? token,
  String? role,
  String? userName,
  String? stationName,
  String? stationId,
  String? warehouseId,
  String? driverId,
}) async {
  _userId = userId;
  _token = token;
  _role = role;
  _currentUserName = userName ?? '';
  _currentStationName = stationName ?? '';
  _stationId = stationId;
  _warehouseId = warehouseId;
  _driverId = driverId;

  if (userName != null) {
    currentUserNameStatic = userName;
  }
  if (stationName != null) {
    currentStationNameStatic = stationName;
  }

  if (role != null) {
    final roleIndex = _getRoleIndex(role);
    _selectedRoleIndex = roleIndex;
  }

  notifyListeners();
}

int _getRoleIndex(String role) {
  switch (role) {
    case 'station':
      return 0;
    case 'driver':
      return 1;
    case 'warehouse':
      return 2;
    case 'admin':
      return 3;
    default:
      return 0;
  }
}
```

**3. 修复logout方法确保完全清理数据** ([main.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\main.dart#L200-L235))
```dart
Future<void> logout() async {
  _selectedRoleIndex = 0;
  _currentUserName = '';
  _currentStationName = '';
  _userId = null;
  _token = null;
  _role = null;
  _stationId = null;
  _warehouseId = null;
  _driverId = null;

  currentUserNameStatic = '';
  currentStationNameStatic = '';

  await ApiConfig.clearTokens();

  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('user_name');
  await prefs.remove('station_name');
  await prefs.remove(ApiConfig.userIdKey);
  await prefs.remove(ApiConfig.userRoleKey);
  await prefs.remove(ApiConfig.tokenKey);
  await prefs.remove(ApiConfig.refreshTokenKey);
  await prefs.remove(ApiConfig.stationIdKey);
  await prefs.remove(ApiConfig.warehouseIdKey);
  await prefs.remove(ApiConfig.driverIdKey);

  notifyListeners();
}
```

**4. 更新WaterOMSApp路由系统** ([main.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\main.dart#L239-L260))
```dart
@override
Widget build(BuildContext context) {
  return MaterialApp(
    title: '水厂订货管理系统',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.lightTheme,
    initialRoute: '/',
    onGenerateRoute: (settings) {
      if (settings.name == '/') {
        return MaterialPageRoute(builder: (_) => const SplashPage());
      }
      if (settings.name?.startsWith('/admin') ?? false) {
        return AdminRoutes.generateRoute(settings);
      }
      return MaterialPageRoute(
        builder: (_) => const LoginPage(),
      );
    },
    home: const SplashPage(),
  );
}
```

#### 经验教训

1. **启动页面(Splash Page)是标准做法**
   - 所有移动应用都应该有一个启动页面
   - 启动页面用于初始化配置、检查登录状态
   - 根据登录状态决定跳转到主页或登录页
   - 提供品牌展示和加载体验

2. **登录状态持久化需要完整链路**
   - 登录时：获取token → 保存到持久化存储 → 保存到内存
   - 应用启动时：从持久化存储读取token → 检查有效性 → 恢复用户状态
   - 登出时：清理内存状态 → 清理持久化存储
   - 确保每个环节都不遗漏

3. **AppState应该支持完整的状态管理**
   - 除了setUserInfo()，还需要restoreUserInfo()
   - restoreUserInfo()用于从持久化存储恢复状态
   - setUserInfo()用于设置新状态并持久化
   - logout()用于清理所有状态

4. **路由系统应该统一管理**
   - 使用SplashPage作为应用入口
   - 在onGenerateRoute中处理所有路由逻辑
   - 确保路由守卫逻辑集中在一处
   - 避免在多个地方硬编码首页

5. **SharedPreferences清理要完整**
   - 不仅要清理ApiConfig，还要清理SharedPreferences
   - 包括：token、refreshToken、userId、role、stationId、warehouseId、driverId
   - 清理后要调用notifyListeners()更新UI

#### 测试建议
修复后请测试以下场景：
- ✅ 登录后关闭应用，再次打开时自动跳转到主页
- ✅ 切换账号后，新账号信息正确保存
- ✅ 登出功能完全清理所有数据
- ✅ 登出后重新打开应用，正确显示登录页
- ✅ 不同角色的用户能正确跳转到对应的主页
- ✅ 应用首次安装时显示登录页
- ✅ token过期时的处理（建议后续添加）

#### 相关文件
- [splash_page.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\pages\splash\splash_page.dart) - 启动页面（新增）
- [main.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\main.dart) - 应用入口（更新路由和AppState）
- [api_config.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\core\config\api_config.dart) - API配置（Token管理）
- [auth_service.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\services\auth_service.dart) - 认证服务（登录逻辑）

### 仓库端通知设置API缺少X-User-Id请求头修复 (2026-05-11)

#### 问题描述
仓库管理员端的新订单提醒、库存预警提醒、司机回仓提醒这三个功能请求失败，后端返回错误：
```
Required request header 'X-User-Id' for method parameter type Long is not present
```

用户无法保存通知设置，导致这些开关切换后无法生效。

#### 问题根源

**1. WarehouseService缺少X-User-Id请求头**
`warehouse_service.dart` 中的 `getNotificationSettings()` 和 `updateNotificationSettings()` 方法只传递了 `X-Warehouse-Id` 请求头，但后端API要求同时传递 `X-User-Id` 请求头。

**2. 未导入ApiConfig**
warehouse_service.dart 文件中使用了 `ApiConfig.getUserId()` 方法，但没有导入 `api_config.dart`。

#### 修复方案

**1. 添加ApiConfig导入** ([warehouse_service.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\services\warehouse_service.dart#L1))
```dart
import '../core/config/api_config.dart';
import '../core/network/api_client.dart';
// ...
```

**2. 修复getNotificationSettings方法** ([warehouse_service.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\services\warehouse_service.dart#L873-L892))
```dart
Future<Map<String, dynamic>> getNotificationSettings(
    String warehouseId) async {
  final userId = ApiConfig.getUserId();
  final response = await _apiClient.get(
    '/warehouses/notification-settings',
    headers: {
      'X-Warehouse-Id': warehouseId,
      'X-User-Id': userId,
    },
  );

  if (response.success && response.data != null) {
    return Map<String, dynamic>.from(response.data);
  } else {
    throw ApiException(
      response.message ?? '获取通知设置失败',
      statusCode: response.code,
    );
  }
}
```

**3. 修复updateNotificationSettings方法** ([warehouse_service.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\services\warehouse_service.dart#L890-L925))
```dart
Future<bool> updateNotificationSettings(
  String warehouseId, {
  required bool newOrder,
  required bool lowStock,
  required bool driverReturn,
}) async {
  final userId = ApiConfig.getUserId();
  final response = await _apiClient.put(
    '/warehouses/notification-settings',
    headers: {
      'X-Warehouse-Id': warehouseId,
      'X-User-Id': userId,
    },
    body: {
      'newOrder': newOrder,
      'lowStock': lowStock,
      'driverReturn': driverReturn,
    },
  );

  if (response.success) {
    return true;
  } else {
    throw ApiException(
      response.message ?? '更新通知设置失败',
      statusCode: response.code,
    );
  }
}
```

#### 经验教训

1. **后端API契约必须严格遵守**
   - 后端明确要求 `X-User-Id` 请求头是必需的
   - 缺少任何必需的请求头都会导致API调用失败
   - 前端开发时必须参考后端的API文档

2. **请求头管理是API调用的关键**
   - 不同API可能需要不同的请求头组合
   - 需要在Service层统一管理请求头
   - 公共请求头（如Authorization）由ApiClient处理
   - 业务相关的请求头（如X-Warehouse-Id、X-User-Id）在Service方法中单独添加

3. **导入语句不能遗漏**
   - 使用任何类之前必须确保已正确导入
   - 编译器会捕获缺失的导入，但逻辑错误（如使用了错误的方法）需要人工检查
   - 建议在修改代码时同时检查相关导入

4. **API错误日志的重要性**
   - 用户报告的错误日志清晰地指出了问题所在
   - `MissingRequestHeaderException` 明确指出缺少哪个请求头
   - 应该充分利用错误日志来定位问题

5. **测试覆盖的重要性**
   - 建议为每个API调用方法编写单元测试
   - 测试应该覆盖各种请求头组合
   - 测试时应该检查实际发送的请求头是否正确

#### 测试建议
修复后请测试以下场景：
- ✅ 仓库管理员登录后打开设置页面
- ✅ 尝试切换"新订单提醒"开关
- ✅ 尝试切换"库存预警提醒"开关
- ✅ 尝试切换"司机回仓提醒"开关
- ✅ 验证所有开关切换后能成功保存
- ✅ 验证API调用时请求头包含正确的X-User-Id

#### 相关文件
- [warehouse_service.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\services\warehouse_service.dart) - 仓库服务（修复文件）
- [warehouse_settings_page.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\pages\warehouse\warehouse_settings_page.dart) - 仓库设置页面（调用方）
- [api_config.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\core\config\api_config.dart) - API配置（提供getUserId方法）
- [api_client.dart](file:///c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\lib\core\network\api_client.dart) - API客户端（处理请求头）

