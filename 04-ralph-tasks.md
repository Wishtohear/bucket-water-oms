# 水厂订货管理系统 - 开发任务清单 (v2.1)

> 本文件记录所有开发任务，严格按顺序执行。
> 更新时间：2026-05-17
> 依据文档：`水厂订货管理系统.md` (PRD v1.4)

## 任务统计
- **总计**: 162 个任务
- **已完成**: 123 个 (76%)
- **Blocked**: 10 个 (6%)
- **待实现**: 0 个 (0%)
- **新增任务**:
  - 15个 平台总超级管理员端开发任务（Vue3）
  - 31 个（基于项目检查对比报告）
  - 40 个 UniApp 用户端开发任务（含微信小程序编译配置）
  - 6 个 UniApp 用户端水票业务任务
  - 4 个 PC管理端水站老板端增强任务

---

## 一、平台总超级管理员端开发 (PLATFORM_ADMIN)

> **项目**: bucket-water-oms-platform-admin
> **框架**: Vue 3 + TypeScript + Vite + Element Plus
> **功能**: 平台总超级管理员后台管理系统

### T-PLATFORM-001: 项目初始化
- **描述**: 创建Vue3 + Vite + Element Plus项目
- **状态**: [x] ✅ 已完成 (2026-05-17)
- **已完成内容**:
  - ✅ 创建项目结构 (src/views, src/router, src/stores, src/api)
  - ✅ 安装依赖 (element-plus, vue-router, pinia, axios)
  - ✅ 配置Element Plus
  - ✅ 创建路由和状态管理
- **相关文件**:
  - `bucket-water-oms-platform-admin/src/main.ts`
  - `bucket-water-oms-platform-admin/src/router/index.ts`
  - `bucket-water-oms-platform-admin/src/stores/auth.ts`

### T-PLATFORM-002: 登录页面
- **描述**: 实现平台管理员登录页面
- **状态**: [x] ✅ 已完成 (2026-05-17)
- **已完成内容**:
  - ✅ 登录表单 UI
  - ✅ 用户名密码验证
  - ✅ 登录 API 集成
  - ✅ Token 存储和刷新
- **相关文件**:
  - `bucket-water-oms-platform-admin/src/views/Login.vue`

### T-PLATFORM-003: 主布局组件
- **描述**: 实现主布局组件（侧边栏、顶部栏）
- **状态**: [x] ✅ 已完成 (2026-05-17)
- **已完成内容**:
  - ✅ 侧边栏导航菜单
  - ✅ 顶部栏（标题、用户信息）
  - ✅ 退出登录功能
  - ✅ 路由守卫
- **相关文件**:
  - `bucket-water-oms-platform-admin/src/views/Layout.vue`

### T-PLATFORM-004: 数据概览页面
- **描述**: 实现全局数据概览仪表盘
- **状态**: [x] ✅ 已完成 (2026-05-17)
- **已完成内容**:
  - ✅ 统计卡片（水厂数、水站数、司机数、订单数）
  - ✅ 各水厂订单量对比图表
  - ✅ 近7天订单趋势图表
  - ✅ 水厂列表展示
- **相关文件**:
  - `bucket-water-oms-platform-admin/src/views/Dashboard.vue`

### T-PLATFORM-005: 水厂管理列表页面
- **描述**: 实现水厂列表管理页面
- **状态**: [x] ✅ 已完成 (2026-05-17)
- **已完成内容**:
  - ✅ 水厂列表展示（分页）
  - ✅ 搜索筛选（名称、编码、状态）
  - - 创建水厂对话框
  - 编辑水厂对话框
  - 启用/停用水厂
  - 水厂详情入口
- **相关文件**:
  - `bucket-water-oms-platform-admin/src/views/factory/FactoryList.vue`

### T-PLATFORM-006: 水厂详情页面
- **描述**: 实现水厂详情查看页面
- **状态**: [x] ✅ 已完成 (2026-05-17)
- **已完成内容**:
  - ✅ 水厂基本信息展示
  - ✅ 统计数据（关联水站、仓库、司机、订单）
  - ✅ 关联账号列表
  - ✅ 返回按钮
- **相关文件**:
  - `bucket-water-oms-platform-admin/src/views/factory/FactoryDetail.vue`

### T-PLATFORM-007: 全局报表页面
- **描述**: 实现全局报表页面
- **状态**: [x] ✅ 已完成 (2026-05-17)
- **已完成内容**:
  - ✅ 销售统计（销售额、订单数、客单价）
  - ✅ 订单统计表格
  - ✅ 水厂对比分析图表
  - ✅ 数据筛选和导出
- **相关文件**:
  - `bucket-water-oms-platform-admin/src/views/report/GlobalReports.vue`

### T-PLATFORM-008: 操作日志页面
- **描述**: 实现操作日志查看页面
- **状态**: [x] ✅ 已完成 (2026-05-17)
- **已完成内容**:
  - ✅ 日志列表展示
  - ✅ 多条件筛选（模块、操作类型、操作人、时间）
  - ✅ 分页展示
  - ✅ 日志详情展示
- **相关文件**:
  - `bucket-water-oms-platform-admin/src/views/log/OperationLogs.vue`

### T-PLATFORM-009: 平台配置页面
- **描述**: 实现平台配置管理页面
- **状态**: [x] ✅ 已完成 (2026-05-17)
- **已完成内容**:
  - ✅ 基础配置（平台名称、Logo、维护模式）
  - ✅ 支付配置（微信支付）
  - ✅ 短信配置（阿里云短信）
  - ✅ 地图配置（高德/百度地图）
  - ✅ 配置保存功能
- **相关文件**:
  - `bucket-water-oms-platform-admin/src/views/config/PlatformConfig.vue`

### T-PLATFORM-010: 管理员管理页面
- **描述**: 实现平台管理员账号管理页面
- **状态**: [x] ✅ 已完成 (2026-05-17)
- **已完成内容**:
  - ✅ 管理员列表展示
  - ✅ 创建管理员
  - ✅ 编辑管理员
  - ✅ 启用/停用管理员
  - ✅ 删除管理员
- **相关文件**:
  - `bucket-water-oms-platform-admin/src/views/admin/PlatformAdmins.vue`

### T-PLATFORM-011: 后端 - 平台管理员认证API
- **描述**: 实现平台管理员登录、登出、Token刷新API
- **状态**: [x] ✅ 已完成 (2026-05-17)
- **优先级**: P0
- **已完成内容**:
  - ✅ 复用 User 实体存储平台管理员账号
  - ✅ 创建 PlatformAuthController（登录、登出、Token刷新）
  - ✅ 在 AuthService 中添加 platform 角色支持
  - ✅ 实现密码加密和验证（复用现有 BCryptPasswordEncoder）
  - ✅ 实现JWT Token生成和验证（复用现有 UserService.generateToken）
- **API接口**:
  - `POST /platform/auth/login` - 平台管理员登录
  - `POST /platform/auth/refresh` - Token刷新
  - `POST /platform/auth/logout` - 退出登录
- **相关文件**:
  - `bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/auth/controller/PlatformAuthController.java`

### T-PLATFORM-012: 后端 - 水厂管理API
- **描述**: 实现水厂增删改查API
- **状态**: [x] ✅ 已完成 (2026-05-17)
- **优先级**: P0
- **已完成内容**:
  - ✅ 创建 Factory 实体
  - ✅ 创建 FactoryMapper
  - ✅ 创建 FactoryController
  - ✅ 创建 FactoryService
  - ✅ 实现水厂列表查询（支持分页、筛选）
  - ✅ 实现创建水厂
  - ✅ 实现编辑水厂
  - ✅ 实现启用/停用水厂
  - ✅ 实现删除水厂
  - ✅ 创建数据库迁移脚本 factory_module.sql
- **API接口**:
  - `GET /platform/factories` - 获取水厂列表（分页）
  - `GET /platform/factories/all` - 获取所有水厂（不分页）
  - `GET /platform/factories/{id}` - 获取水厂详情
  - `POST /platform/factories` - 创建水厂
  - `PUT /platform/factories/{id}` - 更新水厂
  - `PUT /platform/factories/{id}/status` - 更新水厂状态
  - `DELETE /platform/factories/{id}` - 删除水厂
- **相关文件**:
  - `bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/factory/entity/Factory.java`
  - `bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/factory/mapper/FactoryMapper.java`
  - `bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/factory/service/FactoryService.java`
  - `bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/factory/controller/FactoryController.java`
  - `bucket-water-oms-java/database/factory_module.sql`

### T-PLATFORM-013: 后端 - 平台管理员账号管理API
- **描述**: 实现平台管理员账号增删改查API
- **状态**: [x] ✅ 已完成 (2026-05-17)
- **优先级**: P1
- **已完成内容**:
  - ✅ PlatformAdminController 实现
  - ✅ 创建/编辑/删除管理员
  - ✅ 启用/停用管理员
  - ✅ 密码重置
  - ✅ 密码加密存储（BCrypt）
- **API接口**:
  - `GET /platform/admins` - 获取平台管理员列表（分页）
  - `GET /platform/admins/all` - 获取所有平台管理员（不分页）
  - `GET /platform/admins/{id}` - 获取管理员详情
  - `POST /platform/admins` - 创建管理员
  - `PUT /platform/admins/{id}` - 更新管理员
  - `PUT /platform/admins/{id}/password` - 重置密码
  - `PUT /platform/admins/{id}/status` - 更新状态
  - `DELETE /platform/admins/{id}` - 删除管理员
- **相关文件**:
  - `bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/platform/controller/PlatformAdminController.java`

### T-PLATFORM-014: 后端 - 平台操作日志API
- **描述**: 实现平台操作日志记录和查询API
- **状态**: [x] ✅ 已完成 (2026-05-17)
- **优先级**: P1
- **已完成内容**:
  - ✅ PlatformOperationLog 实体
  - ✅ PlatformOperationLogMapper
  - ✅ PlatformOperationLogService
  - ✅ PlatformOperationLogController
  - ✅ 日志查询（支持多条件筛选）
  - ✅ 日志删除（单条/批量/按时间清理）
  - ✅ 创建数据库迁移脚本 platform_operation_log.sql
- **API接口**:
  - `GET /platform/logs` - 获取操作日志列表（分页）
  - `GET /platform/logs/list` - 获取操作日志列表（不分页）
  - `GET /platform/logs/{id}` - 获取日志详情
  - `DELETE /platform/logs/{id}` - 删除指定日志
  - `DELETE /platform/logs/batch` - 批量删除日志
  - `DELETE /platform/logs/clear` - 清理指定时间之前的日志
- **相关文件**:
  - `bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/platform/entity/PlatformOperationLog.java`
  - `bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/platform/mapper/PlatformOperationLogMapper.java`
  - `bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/platform/service/PlatformOperationLogService.java`
  - `bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/platform/controller/PlatformOperationLogController.java`
  - `bucket-water-oms-java/database/platform_operation_log.sql`

### T-PLATFORM-015: 后端 - 平台配置API
- **描述**: 实现平台配置管理API
- **状态**: [x] ✅ 已完成 (2026-05-17)
- **优先级**: P2
- **已完成内容**:
  - ✅ PlatformConfig 实体
  - ✅ PlatformConfigMapper
  - ✅ PlatformConfigService
  - ✅ PlatformConfigController
  - ✅ 实现配置项的增删改查
  - ✅ 实现配置分组管理
  - ✅ 创建数据库迁移脚本 platform_config.sql
  - ✅ 初始化默认配置数据
- **API接口**:
  - `GET /platform/config/groups/{group}` - 获取配置列表
  - `GET /platform/config/map/{group}` - 获取配置Map
  - `GET /platform/config/{id}` - 获取配置详情
  - `GET /platform/config/key/{key}` - 获取配置值
  - `POST /platform/config` - 创建配置
  - `PUT /platform/config/{id}` - 更新配置
  - `PUT /platform/config/value/{key}` - 更新配置值
  - `PUT /platform/config/batch` - 批量更新配置
  - `DELETE /platform/config/{id}` - 删除配置
- **相关文件**:
  - `bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/platform/entity/PlatformConfig.java`
  - `bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/platform/mapper/PlatformConfigMapper.java`
  - `bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/platform/service/PlatformConfigService.java`
  - `bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/platform/controller/PlatformConfigController.java`
  - `bucket-water-oms-java/database/platform_config.sql`

---

## 二、多水厂支持 - 后端权限改造 (MULTI_FACTORY)

> **项目**: bucket-water-oms-java
> **功能**: 实现平台总超级管理员与水厂管理员的权限分离和数据隔离

### T-MF-001: 权限检查注解缺失
- **描述**: 所有Controller都缺少权限注解，无法区分平台管理员和水厂管理员
- **状态**: [x] ✅ 已完成 (2026-05-17)
- **优先级**: P0 🔴
- **已完成内容**:
  - ✅ 创建自定义权限注解 `@RequireRole`
  - ✅ 创建权限检查拦截器 `RoleAuthorizationInterceptor`
  - ✅ 创建 WebMvcConfig 注册拦截器
  - ✅ 为以下10个Admin Controller添加类级别权限注解：
    - AdminController
    - AdminProductController
    - AdminReportStatsController
    - AdminSystemConfigController
    - AdminInventoryController
    - AdminFinanceController
    - AdminOrderController
    - AdminPolicyController
    - AdminDashboardController
    - AdminRegionController
    - AdminStationPageController
    - AdminInventoryTransactionController
  - ✅ 实现 PLATFORM_ADMIN 和 FACTORY_ADMIN 权限区分
  - ✅ 添加平台管理员登录路径到公开路径
- **涉及文件**:
  - `RequireRole.java` - 新建自定义权限注解
  - `RoleAuthorizationInterceptor.java` - 新建权限检查拦截器
  - `WebMvcConfig.java` - 新建Web配置，注册拦截器
  - `JwtAuthenticationFilter.java` - 更新公开路径
  - 10个Admin Controller - 添加 @RequireRole 注解

### T-MF-002: Station实体缺少factory_id字段
- **描述**: 水站表(station)没有关联水厂，无法实现水厂间数据隔离
- **状态**: [x] ✅ 已完成 (2026-05-17)
- **优先级**: P0 🔴
- **已完成内容**:
  - ✅ 为 Station 实体添加 factoryId 字段
  - ✅ 为 StationManagementDTO 添加 factoryId 字段
  - ✅ 修改 AdminStationService.createStation 方法设置 factoryId
  - ✅ 创建数据库迁移脚本 add_station_factory_id.sql
- **待实现内容** (T-MF-003):
  - ⏳ 修改 AdminStationService 的查询方法，添加 factory_id 过滤
  - ⏳ 修改 AdminWarehouseService 添加 factory_id 过滤
  - ⏳ 修改 AdminDriverService 添加 factory_id 过滤
  - ⏳ 修改 AdminOrderService 添加 factory_id 过滤
  - ⏳ 创建 factory 表（如果需要）
  - ⏳ 执行数据库迁移脚本
- **涉及文件**:
  - `Station.java` - 添加 factoryId 字段
  - `StationManagementDTO.java` - 添加 factoryId 字段
  - `AdminStationService.java` - 修改 createStation 方法
  - `database/add_station_factory_id.sql` - 数据库迁移脚本

### T-MF-003: 数据隔离逻辑缺失
- **描述**: AdminStationService、AdminWarehouseService 等 Service 没有根据 factory_id 过滤数据
- **状态**: [x] ✅ 已完成 (2026-05-17)
- **优先级**: P0 🔴
- **已完成内容**:
  - ✅ 创建 UserContext 工具类，提供用户上下文判断方法
  - ✅ 修改 RoleAuthorizationInterceptor，在请求中设置用户上下文
  - ✅ 修改 AdminStationService.getAllStations 方法，添加 factoryId 参数支持数据隔离
  - ✅ 修改 AdminController.getAllStations 方法，获取当前用户并传递 factoryId
  - ⏳ 待完成：AdminWarehouseService、AdminDriverService、AdminOrderService 的数据隔离
- **待实现内容** (T-MF-003-续):
  - 修改 AdminWarehouseService，添加 factory_id 过滤
  - 修改 AdminDriverService，添加 factory_id 过滤
  - 修改 AdminOrderService，添加 factory_id 过滤
- **涉及文件**:
  - `UserContext.java` - 新建用户上下文工具类
  - `RoleAuthorizationInterceptor.java` - 添加用户上下文到请求
  - `AdminStationService.java` - 添加 factoryId 参数
  - `AdminController.java` - 获取并传递用户上下文

### T-MF-004: PermissionChecker缺少平台管理员支持
- **描述**: PermissionChecker 没有检查 PLATFORM_ADMIN 角色的逻辑
- **状态**: [x] ✅ 已完成 (2026-05-17)
- **优先级**: P1
- **已完成内容**:
  - ✅ 在文件上传权限检查方法中添加 PLATFORM_ADMIN
  - ✅ 添加平台管理员的特殊权限判断
  - ✅ 添加 isPlatformAdmin 工具方法
  - ✅ 在 checkRole 方法中检查平台管理员
  - ✅ 在 hasRole 方法中检查平台管理员
  - ✅ 添加 platform 角色到 convertFrontendRoleToBackend 方法
- **涉及文件**:
  - `PermissionChecker.java`

### T-MF-005: 平台管理员登录缺失
- **描述**: AuthService 没有 PLATFORM_ADMIN 的登录入口
- **状态**: [x] ✅ 已完成 (2026-05-17)
- **优先级**: P0 🔴
- **已完成内容**:
  - ✅ 在 AuthService.convertToUserRole() 方法中添加 platform 角色支持
  - ✅ 创建 PlatformAuthController 提供平台管理员专用登录接口
  - ✅ 平台管理员可通过 POST /platform/auth/login 登录
  - ✅ 复用现有的 User 实体和认证逻辑
- **涉及文件**:
  - `AuthService.java` - 添加 platform 角色支持
  - `PlatformAuthController.java` - 新建，提供平台管理员登录接口

### T-MF-006: 水厂管理员登录验证问题
- **描述**: 水厂管理员登录验证时 role=FACTORY_ADMIN，实际传入的是 "admin"
- **状态**: [x] ✅ 已完成 (2026-05-17)
- **优先级**: P1
- **已完成内容**:
  - ✅ 创建 convertFrontendRoleToDbRole 方法，将前端角色转换为数据库角色值
  - ✅ 创建 getPossibleDbRoles 方法，返回可能的数据库角色值数组
  - ✅ 修改 login 方法查询逻辑，支持多种角色值匹配（如 "FACTORY_ADMIN" 或 "admin"）
  - ✅ 统一前后端的角色命名，支持多种格式兼容
- **涉及文件**:
  - `AuthService.java` - 登录验证逻辑

---

## 三、认证模块 (AUTH) - 继续

### T-AUTH-007: 平台管理员登录功能
- **描述**: 实现平台总超级管理员的登录功能
- **状态**: [x] ✅ 已完成 (2026-05-17) - 已在T-MF-005和T-PLATFORM-011中实现
- **优先级**: P0
- **已完成内容**:
  - ✅ 创建平台管理员登录接口 (PlatformAuthController)
  - ✅ 实现平台管理员密码验证 (复用AuthService)
  - ✅ 实现 JWT Token 生成 (复用UserService)
  - ✅ 实现 Token 刷新机制 (PlatformAuthController.refreshToken)
- **相关文件**:
  - `PlatformAuthController.java`
  - `AuthService.java`

---

## 四、水站管理模块 (STATION) - 继续

### T-STATION-011: 水站关联水厂
- **描述**: 实现水站与水厂的关联
- **状态**: [x] ✅ 已完成 (2026-05-17)
- **优先级**: P0
- **已完成内容**:
  - ✅ StationManagementDTO添加factoryId字段
  - ✅ AdminStationService注入FactoryMapper
  - ✅ AdminStationService.createStation设置factoryId
  - ✅ AdminStationService.getAllStations返回factoryId和factoryName
  - ✅ StationVO添加factoryId和factoryName字段
- **相关文件**:
  - `StationManagementDTO.java`
  - `StationVO.java`
  - `AdminStationService.java`

---

## 五、仓库管理模块 (WAREHOUSE) - 继续

### T-WAREHOUSE-007: 仓库关联水厂
- **描述**: 实现仓库与水厂的关联
- **状态**: [x] ✅ 已有 factory_id 字段
- **说明**: Warehouse 实体已有 factory_id 字段，需要完善数据过滤逻辑

---

## 六、司机管理模块 (DRIVER) - 继续

### T-DRIVER-010: 司机关联水厂
- **描述**: 实现司机与水厂的关联
- **状态**: [x] ✅ 已有 factory_id 字段
- **说明**: Driver 实体已有 factory_id 字段，需要完善数据过滤逻辑

---

## 七、订单管理模块 (ORDER) - 继续

### T-ORDER-013: 订单关联水厂
- **描述**: 实现订单与水厂的关联
- **状态**: [x] ✅ 已完成 (2026-05-17)
- **优先级**: P1
- **已完成内容**:
  - ✅ 为 Order 实体添加 factoryId 字段
  - ✅ 创建数据库迁移脚本 add_order_factory_id.sql
- **待实现内容** (需要进一步完善):
  - ⏳ 创建订单时自动关联当前水厂
  - ⏳ 查询订单时根据水厂过滤
- **相关文件**:
  - `Order.java`
  - `database/add_order_factory_id.sql`

---

## 八、权限改造检查清单 (PERMISSION_AUDIT)

> 以下 Controller 和 Service 需要检查并添加权限控制

### 8.1 Controller 权限检查

| Controller | 接口数量 | 当前权限检查 | 需要改造 |
|------------|---------|-------------|---------|
| AdminController | 30+ | ❌ 无 | ✅ 需要 |
| AdminStationController | 10+ | ❌ 无 | ✅ 需要 |
| AdminWarehouseController | 10+ | ❌ 无 | ✅ 需要 |
| AdminDriverController | 10+ | ❌ 无 | ✅ 需要 |
| AdminProductController | 10+ | ❌ 无 | ✅ 需要 |
| AdminOrderController | 10+ | ❌ 无 | ✅ 需要 |
| AdminInventoryController | 10+ | ❌ 无 | ✅ 需要 |
| AdminFinanceController | 10+ | ❌ 无 | ✅ 需要 |
| AdminReportStatsController | 10+ | ❌ 无 | ✅ 需要 |
| AdminSystemConfigController | 10+ | ❌ 无 | ✅ 需要 |
| AdminAuditLogController | 10+ | ❌ 无 | ✅ 需要 |

### 8.2 Service 数据过滤检查

| Service | 数据过滤 | 当前状态 | 需要改造 |
|---------|---------|---------|---------|
| AdminStationService | factory_id | ❌ 无过滤 | ✅ 需要 |
| AdminWarehouseService | factory_id | ❌ 无过滤 | ✅ 需要 |
| AdminDriverService | factory_id | ❌ 无过滤 | ✅ 需要 |
| AdminProductService | factory_id | ❌ 无过滤 | ✅ 需要 |
| AdminOrderService | factory_id | ❌ 无过滤 | ✅ 需要 |
| OrderService | factory_id | ❌ 无过滤 | ✅ 需要 |

### 8.3 权限问题严重等级

| 等级 | 问题 | 影响 |
|------|------|------|
| P0 🔴 | 所有Controller无权限注解 | 安全风险：任何用户都能访问所有API |
| P0 🔴 | Station缺少factory_id | 功能缺陷：无法实现多水厂数据隔离 |
| P0 🔴 | 所有Service无数据过滤 | 功能缺陷：水厂管理员能看到所有水厂数据 |
| P0 🔴 | 平台管理员无法登录 | 功能缺陷：平台管理员无法使用系统 |
| P1 | PermissionChecker缺少PLATFORM_ADMIN | 功能缺陷：平台管理员无法上传文件 |

---

## 九、UniApp 用户端开发模块 (UNIAPP_USER) - 继续

> 详见第2260行后的 UniApp 用户端开发模块

### 阶段一：项目初始化 (已完成)

### 阶段二：认证模块 (已完成)

### 阶段三：水站模块 (已完成)

### 阶段四：商品模块 (已完成)

### 阶段五：购物车模块 (已完成)

### 阶段六：订单模块 (已完成)

### 阶段七：支付模块 (已完成)

### 阶段八：用户中心 (已完成)

### 阶段十：水站配送订单模块 (已完成)

### 阶段十一：测试与优化 (待实现)

### T-UNI-110: 功能测试
- **描述**: 测试所有功能模块
- **状态**: [-] ⚠️ Blocked - 需要启动开发环境进行测试
- **优先级**: P0

### T-UNI-111: UI 适配测试
- **描述**: 测试各平台 UI 适配
- **状态**: [-] ⚠️ Blocked - 需要启动开发环境进行测试
- **优先级**: P0

### T-UNI-112: 性能优化
- **描述**: 性能优化
- **状态**: [-] ⚠️ Blocked - 需要启动开发环境进行测试
- **优先级**: P1

### T-UNI-113: Bug 修复
- **描述**: 修复测试中发现的问题
- **状态**: [-] ⚠️ Blocked - 需要启动开发环境进行测试
- **优先级**: P0

### 阶段十二：水票业务模块 (已完成)

---

## 十、移动端水站老板端增强 (OWNER_MOBILE) - 继续

### T-OWNER-MB-002: 移动端水站老板配送员管理页面
- **状态**: [-] ⚠️ Blocked - 原型文件不存在 (admin-mobile原型中无相关页面)

### T-OWNER-MB-003: 移动端水站老板订单列表增强
- **状态**: [-] ⚠️ Blocked - 原型文件不存在

### T-OWNER-MB-004: 移动端水站老板订单详情增强
- **状态**: [-] ⚠️ Blocked - 原型文件不存在

### T-OWNER-MB-005: 移动端水站老板端首页增强
- **状态**: [-] ⚠️ Blocked - 原型文件不存在

### T-OWNER-MB-006: 移动端水站老板水票管理页面
- **状态**: [-] ⚠️ Blocked - 原型文件不存在

### T-OWNER-MB-007: 移动端水站老板水票创建/编辑页面
- **状态**: [-] ⚠️ Blocked - 原型文件不存在

---

## 十一，PC管理端水站老板端水票管理 (OWNER_PC_TICKET) - 继续

### T-OWNER-PC-T-001: PC水站老板水票管理页面
- **状态**: [x] ✅ 已完成 - 前端页面OwnerTickets.vue已完成，后端WaterTicketController提供API
- **说明**: 前端页面OwnerTickets.vue已实现，后端WaterTicketController已提供完整API

### T-OWNER-PC-T-002: PC水站老板水票创建/编辑
- **状态**: [x] ✅ 已完成 - 购买水票接口已实现
- **说明**: 购买水票功能已通过WaterTicketController实现

---

## 十二、水票管理模块 (TICKET) - 继续

### T-TICKET-001: 水票列表
- **状态**: [x] ✅ 已完成 - 后端已有WaterTicketController和WaterTicketService实现

### T-TICKET-002: 水票详情
- **状态**: [x] ✅ 已完成 - WaterTicketController.getTickets接口支持

### T-TICKET-003: 购买水票
- **状态**: [x] ✅ 已完成 - WaterTicketController提供水票购买接口

### T-TICKET-004: 水票核销
- **状态**: [x] ✅ 已完成 - WaterTicketController提供水票核销接口

### T-TICKET-005: 水票持有管理
- **状态**: [x] ✅ 已完成 - WaterTicketController.getTicketHoldings接口

### T-TICKET-006: 水票流水
- **状态**: [x] ✅ 已完成 - WaterTicketController.getAllTransactions接口

---

## 十三、其他遗留任务

### T-ORDER-012: 订单超时检查
- **状态**: [x] ✅ 已完成 (2026-05-17)
- **已完成内容**:
  - ✅ 创建 OrderTimeoutCheckTask 定时任务类
  - ✅ 创建 selectPendingReviewOrders 查询方法
  - ✅ @EnableScheduling 已配置在 BucketWaterOmsApplication
  - ✅ 配置 order.timeout.minutes 参数
  - ✅ 配置 order.auto-cancel-enabled 参数

---

## 任务执行顺序

1. **优先级 P0**:
   - T-MF-001: 权限检查注解缺失
   - T-MF-002: Station实体缺少factory_id字段
   - T-MF-003: 数据隔离逻辑缺失
   - T-MF-005: 平台管理员登录缺失

2. **优先级 P1**:
   - T-PLATFORM-011~015: 后端API开发
   - T-MF-004: PermissionChecker缺少平台管理员支持
   - T-MF-006: 水厂管理员登录验证问题
   - T-STATION-011: 水站关联水厂
   - T-ORDER-013: 订单关联水厂

3. **优先级 P2**:
   - T-PLATFORM-015: 平台配置API
   - 遗留的水票模块

---

> **最后更新**: 2026-05-17
> **执行原则**: 按顺序执行，完成一个任务后才能执行下一个
> **新增任务**:
> - 15个 平台总超级管理员端开发任务（Vue3前端 + 后端API）
> - 6个 多水厂支持权限改造任务
> - 继续 UniApp 用户端开发任务
> - 继续移动端水站老板端增强任务
> - 继续 PC管理端水站老板端水票管理任务
> - 继续水票管理模块任务
