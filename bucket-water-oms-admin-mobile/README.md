# 水厂订货管理系统 - 移动端App

基于Flutter的多端移动应用，采用Clean Architecture架构，支持水站老板、司机、仓库管理员三种角色。

## 🚀 快速启动

### 第一步：安装 Flutter SDK

**重要**：首次使用需要先安装Flutter SDK！

#### 推荐方式：使用自动化脚本

1. **打开 PowerShell（管理员）**
   - 右键点击开始菜单 → 选择 "Windows PowerShell (管理员)"

2. **运行安装脚本**
   ```powershell
   cd "c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile"
   .\install_flutter.ps1
   ```

3. **按照提示完成安装**
   - 脚本会自动下载、解压、配置Flutter SDK
   - 预计耗时：5-10分钟

#### 备选方式：手动安装

1. **下载Flutter SDK**
   - 访问：https://flutter.dev/docs/get-started/install/windows
   - 或直接下载：https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.0-stable.zip

2. **解压并配置环境变量**
   - 解压到：`C:\Users\你的用户名\AppData\Local\Flutter`
   - 添加到PATH：`C:\Users\你的用户名\AppData\Local\Flutter\bin`

3. **验证安装**
   ```powershell
   flutter doctor
   flutter --version
   ```

详细说明请查看：[STARTUP.md](./STARTUP.md) 或 [SETUP_INSTRUCTIONS.md](./SETUP_INSTRUCTIONS.md)

### 第二步：运行项目

Flutter SDK安装完成后，在**新的PowerShell窗口**中运行：

```powershell
# 进入项目目录
cd "c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile"

# 安装依赖
flutter pub get

# 运行应用
flutter run
```

---

## 📁 项目结构

```
lib/
├── main.dart                              # 应用入口
├── core/
│   └── theme/                            # 主题系统
│       ├── app_colors.dart               # 颜色定义
│       ├── app_text_styles.dart         # 文字样式
│       └── app_theme.dart               # 主题配置
├── shared/
│   ├── widgets/                          # 基础UI组件
│   │   ├── app_app_bar.dart            # 应用栏
│   │   ├── app_tab_bar.dart            # 标签栏
│   │   ├── app_card.dart               # 卡片容器
│   │   ├── app_button.dart             # 按钮组件
│   │   ├── app_text_field.dart         # 输入框
│   │   └── app_bottom_bar.dart          # 底部导航栏
│   └── components/                       # 业务组件
│       ├── status_badge.dart           # 状态徽章
│       ├── stat_card.dart              # 统计卡片
│       ├── quick_action_button.dart     # 快捷操作按钮
│       └── product_card.dart            # 商品卡片
└── pages/
    ├── login/                            # 登录模块
    │   └── login_page.dart             # 登录页
    ├── owner/                            # 水站老板端
    │   ├── owner_home_page.dart        # 首页仪表盘
    │   ├── owner_orders_page.dart      # 订单管理
    │   ├── owner_statement_page.dart    # 对账单
    │   └── owner_profile_page.dart      # 个人中心
    ├── driver/                           # 司机端
    │   └── driver_tasks_page.dart       # 任务中心 + 空桶管理
    └── warehouse/                        # 仓库端
        └── warehouse_home_page.dart      # 首页 + 入库/出库/库存
```

---

## 🎨 技术栈

- **框架**: Flutter 3.24.0
- **状态管理**: Provider
- **路由**: Navigator (GoRouter)
- **网络图片**: cached_network_image
- **本地存储**: shared_preferences
- **国际化**: intl

---

## 📱 角色功能说明

### 🌟 水站老板端

**核心功能：**
- 📊 **首页仪表盘**
  - 账户余额和信用额度展示
  - 欠桶预警提醒
  - 快捷操作入口（8个）
  - 实时库存列表
  - 对账提醒通知

- 📦 **订单管理**
  - 订单状态跟踪（待接单→配送中→已完成）
  - 配送进度实时查看
  - 历史订单查询

- 💰 **对账单**
  - 月度账单概览
  - 期初/进货/回款统计
  - 账单确认功能

- 👤 **个人中心**
  - 用户信息展示
  - 账户余额/水票
  - 菜单导航
  - 退出登录

### 🚚 司机端

**核心功能：**
- 📋 **任务中心**
  - 今日任务统计
  - 智能路线规划入口
  - 待配送任务列表
  - 任务详情和配送确认

- 🛢️ **空桶管理**
  - 押金桶统计
  - 欠桶预警（距离阈值）
  - 补缴押金入口
  - 往来记录查看

### 🏭 仓库端

**核心功能：**
- 📈 **首页概览**
  - 今日出入库统计
  - 库存预警显示
  - 最近任务列表

- 📥 **入库管理**
  - 采购入库单处理
  - 入库状态跟踪
  - 确认入库功能

- 📤 **出库管理**
  - 订单出库单管理
  - 拣货处理
  - 出库状态跟踪

- 📊 **库存盘点**
  - 库存汇总展示
  - 实时库存明细
  - 库位信息
  - 预警提示

---

## 🎨 设计规范

### 颜色系统

- **主色**: #1890FF (蓝色) - 品牌色
- **成功色**: #52C41A (绿色) - 成功状态
- **警告色**: #FAAD14 (橙色) - 警告提示
- **错误色**: #FF4D4F (红色) - 错误/紧急
- **信息色**: #722ED1 (紫色) - 仓库端专用

### 文字颜色

- **主文字**: #262626 - 标题和重要信息
- **次要文字**: #8C8C8C - 说明文字
- **占位符**: #BFBFBF - 提示文字

### 圆角规范

- **8px**: 按钮、标签、小图标
- **12px**: 输入框、列表项
- **16px**: 卡片容器
- **20-24px**: 主要卡片、Banner

### 阴影系统

- **轻阴影**: `0 2px 8px rgba(0,0,0,0.04)` - 卡片
- **中等阴影**: `0 4px 12px rgba(0,0,0,0.08)` - 弹窗
- **强阴影**: `0 8px 24px rgba(0,0,0,0.12)` - 浮动元素

---

## 🔧 开发命令

```powershell
# 安装依赖
flutter pub get

# 运行应用
flutter run

# 查看可用设备
flutter devices

# 清理构建
flutter clean

# 重新安装依赖
flutter clean && flutter pub get

# 构建Release APK
flutter build apk --release

# 构建Debug APK
flutter build apk --debug

# 运行静态分析
flutter analyze

# 格式化代码
dart format .
```

---

## 📚 文档资源

1. **README.md** - 项目简介（本文件）
2. **STARTUP.md** - 详细启动指南
3. **SETUP_INSTRUCTIONS.md** - Flutter安装说明
4. **QUICKSTART.md** - 快速启动参考
5. **AGENTS.md** - 开发规范和API接口
6. **CHANGELOG.md** - 更新日志
7. **PROJECT_SUMMARY.md** - 项目总结
8. **水厂订货管理系统.md** - 产品需求文档（PRD）

---

## 🐛 常见问题

### Q1: Flutter SDK 安装失败？

查看详细指南：[SETUP_INSTRUCTIONS.md](./SETUP_INSTRUCTIONS.md)

### Q2: flutter命令找不到？

确保：
1. Flutter SDK已添加到PATH
2. 关闭并重新打开PowerShell窗口
3. 运行 `flutter --version` 验证

### Q3: 依赖安装失败？

```powershell
flutter clean
flutter pub get
```

### Q4: Android设备未检测到？

```powershell
flutter doctor
flutter doctor --android-licenses
```

### Q5: 如何在Web上运行？

```powershell
flutter run -d chrome
```

---

## 📋 开发进度

### 已完成 ✅

- [x] Flutter项目结构搭建
- [x] 主题系统开发
- [x] 共享组件库
- [x] 登录模块
- [x] 水站老板端完整UI
- [x] 司机端核心功能
- [x] 仓库端主要功能

### 进行中 🔄

- [ ] 后端API集成
- [ ] 数据持久化

### 待开发 ⏳

- [ ] 订单创建流程
- [ ] 地图导航集成
- [ ] 离线功能
- [ ] 蓝牙打印

---

## 🎯 项目亮点

1. **多角色设计** - 三套独立UI，角色权限分明
2. **高度组件化** - 11个可复用组件，加速开发
3. **统一设计语言** - 完整的颜色、圆角、阴影规范
4. **清晰架构** - Clean Architecture，分层清晰
5. **文档完善** - 8份文档支持开发

---

## 🤝 贡献指南

欢迎提交Issue和Pull Request！

### 分支管理
- `main` - 主分支，稳定版本
- `develop` - 开发分支
- `feature/*` - 功能分支

### 提交规范
```
feat: 新功能
fix: 修复bug
docs: 文档更新
style: 代码格式
refactor: 重构
test: 测试
chore: 构建/工具
```

---

## 📞 支持

- 📖 文档：查看项目中的 .md 文件
- 🐛 问题反馈：GitHub Issues
- 💡 功能建议：GitHub Issues

---

## 📄 许可证

本项目仅供学习参考使用。

---

## 🙏 致谢

- Flutter团队
- Material Design
- 所有开源贡献者

---

**项目版本**: v1.0.0  
**最后更新**: 2026-04-19  
**开发团队**: AI助手

---

## 🎉 快速开始

```powershell
# 1. 安装Flutter SDK（首次）
.\install_flutter.ps1

# 2. 安装项目依赖
flutter pub get

# 3. 运行应用
flutter run

# 4. 选择角色登录
# - 水站老板端
# - 司机配送端
# - 仓库管理端
```

**祝你开发愉快！** 🚀
