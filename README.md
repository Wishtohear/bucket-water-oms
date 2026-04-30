# 水厂订货管理系统 (Bucket Water OMS)

> **🚀 本项目由 AI 驱动开发，结合 Trae IDE 的 Ralph 开发流程实现**
>
> 项目开发过程中使用了多种 AI 助手能力，包括代码生成、问题诊断、架构设计和文档撰写等，并遵循 Ralph 开发流程的规范和最佳实践。

## 📋 项目概述

水厂订货管理系统是一个实现**水站线下单 → 仓库备货派单 → 司机配送签收 → 空桶回收 → 仓库核对**的完整业务闭环管理系统。所有操作均可通过 PC 端和移动端完成，替代传统电话订货和手工水卡记录方式。

### 系统角色

| 角色 | 说明 |
|------|------|
| **水厂管理员** | 系统管理、定价策略、报表中心 |
| **水站老板/店员** | 订单管理、库存查看、对账管理 |
| **仓库管理员** | 接单派单、回仓核对、库存管理 |
| **司机** | 配送任务、签收管理、回桶录入 |

### 业务流程

```
┌─────────────────────────────────────────────────────────────────────┐
│                           业务闭环流程                               │
└─────────────────────────────────────────────────────────────────────┘

[水站端] 查看库存 → 提交订单 → （审查前可修改/取消）
     ↓
[仓库端] 接单审查 → 【库存不足：拒单退回水站】 / 【库存充足：备货】 → 手动派单给司机
     ↓
[司机端] 接单 → 地图路线规划 → 配送导航 → 到达签收（拍照+核对数量）
     ↓
[仓库端] 司机回仓 → 核对空桶实收 → 差异追责
```

---

## 🏗️ 项目架构

### 技术栈

#### 后端 (Java)

| 技术 | 版本 | 说明 |
|------|------|------|
| Spring Boot | 3.2.5 | 后端框架 |
| Java | 17 | 编程语言 |
| MyBatis Plus | 3.5.6 | ORM框架 |
| PostgreSQL | 14+ | 数据库 |
| Redis | 6+ | 缓存 |
| JWT | 0.12.6 | 身份认证 |

#### PC 管理端 (Vue.js)

| 技术 | 版本 | 说明 |
|------|------|------|
| Vue.js | 3.x | 前端框架 |
| Vite | 5.x | 构建工具 |
| TypeScript | 5.x | 编程语言 |
| Element Plus | 2.x | UI组件库 |
| Pinia | 2.x | 状态管理 |

#### 移动端 (Flutter)

| 技术 | 版本 | 说明 |
|------|------|------|
| Flutter | 3.24.0 | 跨平台框架 |
| Dart | 3.x | 编程语言 |
| Provider | - | 状态管理 |
| GoRouter | - | 路由管理 |

### 项目结构

```
bucket-water-oms/
├── bucket-water-oms-java/        # Spring Boot 后端服务
│   ├── src/main/java/
│   │   └── com/bucketwater/oms/
│   │       ├── common/          # 公共模块（枚举、异常、响应）
│   │       ├── config/          # 配置类
│   │       └── module/           # 业务模块
│   │           ├── admin/        # 管理端模块
│   │           ├── auth/         # 认证模块
│   │           ├── order/        # 订单模块
│   │           ├── station/      # 水站模块
│   │           ├── warehouse/     # 仓库模块
│   │           ├── driver/       # 司机模块
│   │           ├── product/      # 产品模块
│   │           ├── payment/      # 支付模块
│   │           └── ...
│   ├── database/                 # 数据库脚本
│   └── pom.xml
│
├── bucket-water-oms-admin/       # PC 端管理后台 (Vue.js)
│   ├── src/
│   │   ├── api/                 # API 接口定义
│   │   ├── components/           # 公共组件
│   │   ├── stores/              # 状态管理
│   │   ├── views/               # 页面组件
│   │   └── router/              # 路由配置
│   └── package.json
│
├── bucket-water-oms-admin-mobile/ # 移动端应用 (Flutter)
│   ├── lib/
│   │   ├── core/                # 核心配置
│   │   ├── models/              # 数据模型
│   │   ├── pages/               # 页面
│   │   ├── services/            # API 服务
│   │   └── shared/              # 共享组件
│   ├── android/                  # Android 平台配置
│   ├── ios/                     # iOS 平台配置
│   └── pubspec.yaml
│
└── bucket_water_oms_harmony/     # 鸿蒙端应用 (可选)
```

---

## ✨ 核心功能

### 📦 订单管理

- 订单创建、修改、取消
- 订单状态流转：`待审查 → 已接单 → 已派单 → 配送中 → 已完成`
- 拒单处理（库存不足等原因）
- 多商品订单支持
- 水站独立定价

### 💰 财务管理

- 预存金管理
- 信用额度管理
- 月结对账
- 应收款管理

### 🏭 仓库管理

- 订单接单/拒单
- 备货管理
- 司机派单（智能推荐）
- 司机回仓核对
- 空桶出入库管理

### 🚚 司机管理

- 配送任务接收
- GPS 位置同步
- 地图路线规划
- 配送签收（多方式：签字/验证码/APP确认）
- 中途回仓申请
- 对账单确认

### 📊 报表中心

- 水站进货报表
- 司机配送报表
- 空桶汇总报表
- 财务对账报表
- Excel 导出功能

---

## 🚀 快速开始

### 环境要求

| 组件 | 要求 |
|------|------|
| JDK | 17+ |
| Maven | 3.6+ |
| Node.js | 18+ |
| PostgreSQL | 14+ |
| Redis | 6+ |
| Flutter SDK | 3.24.0+ |

### 1. 启动后端服务

```bash
cd bucket-water-oms-java

# 编译项目
mvn clean compile

# 运行项目
mvn spring-boot:run

# 或打包运行
mvn clean package -DskipTests
java -jar target/bucket-water-oms-*.jar
```

后端启动后访问：
- API 文档：http://localhost:8080/swagger-ui.html
- 接口地址：http://localhost:8080

### 2. 启动 PC 管理端

```bash
cd bucket-water-oms-admin

# 安装依赖
npm install

# 开发模式
npm run dev

# 生产构建
npm run build
```

### 3. 启动移动端

```bash
cd bucket-water-oms-admin-mobile

# 安装依赖
flutter pub get

# 运行应用
flutter run

# 构建 APK
flutter build apk --release
```

---

## 📁 模块详解

### 后端模块 (bucket-water-oms-java)

| 模块 | 说明 | 主要类 |
|------|------|--------|
| `admin` | 管理端接口 | AdminController, AdminStationService |
| `auth` | 用户认证 | AuthController, AuthService, JwtAuthenticationFilter |
| `order` | 订单管理 | OrderController, OrderService |
| `station` | 水站管理 | StationController, StationService |
| `warehouse` | 仓库管理 | WarehouseController, WarehouseService |
| `driver` | 司机管理 | DriverController, DriverService |
| `product` | 产品管理 | ProductController, ProductService |
| `payment` | 支付服务 | PaymentController, WechatPayService |
| `bucket` | 空桶管理 | BucketController, BucketService |
| `statement` | 对账管理 | StatementController, StatementService |
| `aftersales` | 售后管理 | AfterSalesController, AfterSalesService |
| `report` | 报表统计 | ReportController, ReportService |
| `notification` | 消息通知 | NotificationController, NotificationService |
| `sms` | 短信服务 | SmsController, SmsService |
| `print` | 打印服务 | PrintController, PrintService |
| `map` | 地图服务 | MapController, MapService |
| `file` | 文件服务 | FileController, FileService |
| `ticket` | 水票管理 | WaterTicketController, WaterTicketService |
| `audit` | 审计日志 | AuditLogAspect |

### PC 端页面 (bucket-water-oms-admin)

| 目录 | 说明 | 页面 |
|------|------|------|
| `admin` | 管理后台 | Dashboard, Settings, AuditLogs |
| `owner` | 水站管理 | OwnerDashboard, OwnerCreateOrder, OwnerStatements |
| `warehouse` | 仓库管理 | WarehouseOrders, WarehouseInventory |
| `driver` | 司机管理 | DriverTasks, DriverStatements |

### 移动端页面 (bucket-water-oms-admin-mobile)

| 目录 | 说明 | 页面 |
|------|------|------|
| `owner` | 水站老板端 | 首页、订单、对账、个人中心 |
| `driver` | 司机端 | 任务中心、空桶管理、对账单 |
| `warehouse` | 仓库端 | 入库、出库、库存盘点 |
| `admin` | 管理员端 | 仪表盘、订单管理、统计报表 |

---

## 🔧 开发规范

### 代码规范

#### Java 后端

- 使用 Google Java Style
- 使用 Lombok 简化代码
- 使用 MyBatis Plus 进行数据库操作
- 分层清晰：Controller → Service → Mapper → Entity

```java
// 示例：标准分层结构
@RestController
@RequestMapping("/api/orders")
public class OrderController {
    private final OrderService orderService;
    
    public OrderController(OrderService orderService) {
        this.orderService = orderService;
    }
}
```

#### Vue.js 前端

- 遵循 Vue 3 Composition API 风格
- 使用 TypeScript 增强类型安全
- 组件按功能模块组织

#### Flutter 移动端

- 遵循 Flutter/Dart 最佳实践
- 使用 Provider 进行状态管理
- 页面组件与业务逻辑分离

### Git 提交规范

```
feat: 新功能
fix: 修复 bug
docs: 文档更新
style: 代码格式调整
refactor: 重构
perf: 性能优化
test: 测试相关
chore: 构建/工具相关
```

---

## 📊 数据库设计

### 核心表结构

```
┌─────────────────────────────────────────────────────────────┐
│                        核心业务表                            │
├─────────────────────────────────────────────────────────────┤
│ user              │ 用户账号表（通过 role 区分角色）          │
│ station           │ 水站表                                   │
│ station_account   │ 水站账户表                               │
│ orders           │ 订单表                                   │
│ order_item       │ 订单明细表                               │
│ product          │ 商品表                                   │
│ product_inventory│ 库存表                                   │
│ warehouse        │ 仓库表                                   │
│ driver           │ 司机表                                   │
│ bucket_transaction│ 空桶流水表                               │
│ monthly_statement│ 对账单表                                 │
└─────────────────────────────────────────────────────────────┘
```

详见：[ER图.md](bucket-water-oms-java/ER图.md)

---

## 🔐 安全机制

### 认证授权

- JWT Token 认证
- Token 刷新机制
- 角色权限控制
- 敏感操作二次确认

### 数据安全

- 密码 BCrypt 加密存储
- SQL 注入防护（MyBatis Plus）
- XSS 防护
- 审计日志记录

---

## 📈 开发经验总结

### AI 辅助开发亮点

1. **需求分析与方案设计**
   - AI 协助分析业务需求
   - 自动生成技术方案
   - 提供最佳实践建议

2. **代码生成与优化**
   - 快速生成基础代码框架
   - 智能补全业务逻辑
   - 自动检测代码质量问题

3. **问题诊断与修复**
   - 快速定位问题根因
   - 提供多种解决方案
   - 预测潜在风险

4. **文档生成与维护**
   - 自动生成 API 文档
   - 维护开发规范
   - 记录经验教训

### Ralph 开发流程

项目采用 Ralph 开发流程进行管理，包括：

- **需求预分析**：深入理解业务需求
- **架构设计**：生成生产级架构设计
- **任务分解**：原子化、可验证的开发任务
- **测试计划**：完整的测试用例设计
- **状态追踪**：实时同步开发进度

详见：[AGENTS.md](AGENTS.md)

---

## 📚 文档资源

| 文档 | 说明 |
|------|------|
| [README.md](README.md) | 项目总览（本文档） |
| [AGENTS.md](AGENTS.md) | 开发经验记录 |
| [ER图.md](bucket-water-oms-java/ER图.md) | 数据库设计图 |
| [接口定义文档.md](bucket-water-oms-java/接口定义文档.md) | API 接口定义 |
| [水厂订货管理系统.md](bucket-water-oms-java/水厂订货管理系统.md) | 产品需求文档 |
| [bucket-water-oms-java/README.md](bucket-water-oms-java/README.md) | 后端开发指南 |
| [bucket-water-oms-admin/README.md](bucket-water-oms-admin/README.md) | PC端开发指南 |
| [bucket-water-oms-admin-mobile/README.md](bucket-water-oms-admin-mobile/README.md) | 移动端开发指南 |

---

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

### 分支管理

```
main          # 主分支，稳定版本
├── develop   # 开发分支
│   ├── feature/*   # 功能分支
│   ├── fix/*       # 修复分支
│   └── refactor/*  # 重构分支
```

### 开发流程

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/xxx`)
3. 提交更改 (`git commit -m 'feat: xxx'`)
4. 推送到分支 (`git push origin feature/xxx`)
5. 创建 Pull Request

---

## 📞 支持与反馈

- 📖 查看项目中的 `.md` 文件
- 🐛 问题反馈：GitHub Issues
- 💡 功能建议：GitHub Issues

---

## 📄 许可证

本项目仅供学习参考使用。

---

## 🙏 致谢

- **AI 助手**：提供代码生成、问题诊断、架构设计等能力
- **Trae IDE**：提供优秀的开发环境和 Ralph 开发流程支持
- **[Spring Boot](https://github.com/spring-projects/spring-boot)**：提供优秀的后端框架
- **[Vue.js](https://github.com/vuejs/vue)**：提供优雅的前端框架
- **[Flutter](https://github.com/flutter/flutter)**：提供跨平台移动开发框架
- **[Element Plus](https://github.com/element-plus/element-plus)**：提供丰富的 UI 组件库
- **[MyBatis Plus](https://github.com/baomidou/mybatis-plus)**：提供便捷的 ORM 框架
- **[PostgreSQL](https://github.com/postgres/postgres)**：提供可靠的关系型数据库
- **[Redis](https://github.com/redis/redis)**：提供高性能的缓存服务
- **所有开源贡献者**

---

- **项目版本**: v1.0.0
- **最后更新**: 2026-04-30
- **开发团队**: [桂林微云](https://www.glwyhd.com/) (AI + Trae Ralph)
- **项目负责人**: Wishtohear

---


**🚀 由 AI 驱动开发，结合 Trae Ralph 实现**

- **项目状态**: 测试阶段
- **项目描述**: 项目还是测试阶段持续更新中
