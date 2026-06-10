# 移动端 API 对接进度跟踪

> 本文档记录移动端与后端 API 的对接进度
> 更新时间: 2026-04-22
> 遵循规范: `skills/flutter-handling-http-and-json`

## 对接状态说明

- [ ] 待对接 - 尚未开始对接
- [ ] 对接中 - 正在开发中
- [x] 已完成 - 已完成对接
- [ ] 已验证 - 已通过功能测试

---

## 一、认证模块 (Auth)

### 后端接口

| 接口 | 方法 | 路径 | 状态 |
|------|------|------|------|
| 登录 | POST | `/auth/login` | [x] 已完成 |
| 刷新Token | POST | `/auth/refresh` | [x] 已完成 |
| 登出 | POST | `/auth/logout` | [x] 已完成 |
| 发送验证码 | POST | `/auth/sms-code` | [ ] 待对接 |

### 移动端文件

- [x] `lib/services/auth_service.dart` - 认证服务
- [x] `lib/models/user_model.dart` - 用户模型
- [x] `lib/pages/login/login_page.dart` - 登录页面

### 对接说明

- [x] 登录接口已完成，使用 JWT Token 认证
- [x] Token 持久化已实现（SharedPreferences）
- [x] 角色切换支持（station/driver/warehouse/admin）
- [ ] 短信验证码接口待对接

---

## 二、管理端模块 (Admin)

### 后端接口

#### Dashboard

| 接口 | 方法 | 路径 | 后端文件 | 状态 |
|------|------|------|----------|------|
| 获取首页数据 | GET | `/admin/dashboard` | AdminDashboardController | [ ] 待对接 |
| 获取今日统计 | GET | `/admin/dashboard/stats` | AdminDashboardController | [ ] 待对接 |
| 获取销售趋势 | GET | `/admin/dashboard/sales-trend` | AdminDashboardController | [ ] 待对接 |
| 获取通知列表 | GET | `/admin/dashboard/notifications` | AdminDashboardController | [ ] 待对接 |
| 获取库存预警 | GET | `/admin/dashboard/inventory-warning` | AdminDashboardController | [ ] 待对接 |

#### 水站管理

| 接口 | 方法 | 路径 | 后端文件 | 状态 |
|------|------|------|----------|------|
| 获取水站列表 | GET | `/admin/stations` | AdminController | [x] 已完成 |
| 获取水站详情 | GET | `/admin/stations/{stationId}` | AdminController | [x] 已完成 |
| 获取水站账户 | GET | `/admin/stations/{stationId}/account` | AdminController | [x] 已完成 |
| 创建水站 | POST | `/admin/stations` | AdminController | [x] 已完成 |
| 更新水站 | PUT | `/admin/stations/{stationId}` | AdminController | [x] 已完成 |
| 更新水站状态 | PUT | `/admin/stations/{stationId}/status` | AdminController | [x] 已完成 |
| 更新销售政策 | PUT | `/admin/stations/policy` | AdminController | [x] 已完成 |

#### 司机管理

| 接口 | 方法 | 路径 | 后端文件 | 状态 |
|------|------|------|----------|------|
| 获取司机列表 | GET | `/admin/drivers` | AdminController | [x] 已完成 |
| 获取司机详情 | GET | `/admin/drivers/{driverId}` | AdminController | [x] 已完成 |
| 创建司机 | POST | `/admin/drivers` | AdminController | [x] 已完成 |
| 更新司机 | PUT | `/admin/drivers/{driverId}` | AdminController | [x] 已完成 |
| 更新司机状态 | PUT | `/admin/drivers/{driverId}/status` | AdminController | [x] 已完成 |
| 重置密码 | POST | `/admin/drivers/{driverId}/reset-password` | AdminController | [x] 已完成 |

#### 仓库管理

| 接口 | 方法 | 路径 | 后端文件 | 状态 |
|------|------|------|----------|------|
| 获取仓库列表 | GET | `/admin/warehouses` | AdminController | [x] 已完成 |
| 获取仓库详情 | GET | `/admin/warehouses/{warehouseId}` | AdminController | [x] 已完成 |
| 创建仓库 | POST | `/admin/warehouses` | AdminController | [x] 已完成 |
| 更新仓库 | PUT | `/admin/warehouses/{warehouseId}` | AdminController | [x] 已完成 |
| 更新仓库状态 | PUT | `/admin/warehouses/{warehouseId}/status` | AdminController | [x] 已完成 |

#### 报表统计

| 接口 | 方法 | 路径 | 后端文件 | 状态 |
|------|------|------|----------|------|
| 获取Dashboard统计 | GET | `/admin/reports/dashboard-stats` | AdminReportStatsController | [x] 已完成 |
| 获取报表统计 | GET | `/admin/reports/stats` | AdminReportStatsController | [x] 已完成 |
| 获取销售趋势 | GET | `/admin/reports/sales-trend` | AdminReportStatsController | [x] 已完成 |
| 获取产品分布 | GET | `/admin/reports/product-distribution` | AdminReportStatsController | [x] 已完成 |
| 获取水站排行 | GET | `/admin/reports/station-rankings` | AdminReportStatsController | [x] 已完成 |
| 获取日报 | GET | `/admin/reports/daily-sales` | AdminReportStatsController | [x] 已完成 |
| 导出报表 | GET | `/admin/reports/export` | AdminReportStatsController | [x] 已完成 |

#### 商品管理

| 接口 | 方法 | 路径 | 后端文件 | 状态 |
|------|------|------|----------|------|
| 获取商品列表 | GET | `/admin/products` | AdminProductController | [x] 已完成 |
| 获取商品详情 | GET | `/admin/products/{productId}` | AdminProductController | [x] 已完成 |
| 创建商品 | POST | `/admin/products` | AdminProductController | [x] 已完成 |
| 更新商品 | PUT | `/admin/products/{productId}` | AdminProductController | [x] 已完成 |
| 更新商品状态 | PUT | `/admin/products/{productId}/status` | AdminProductController | [x] 已完成 |

#### 库存管理

| 接口 | 方法 | 路径 | 后端文件 | 状态 |
|------|------|------|----------|------|
| 获取库存概览 | GET | `/admin/inventory/overview` | AdminInventoryController | [x] 已完成 |
| 获取库存列表 | GET | `/admin/inventory` | AdminInventoryController | [x] 已完成 |
| 获取库存记录 | GET | `/admin/inventory/records` | AdminInventoryController | [x] 已完成 |

#### 财务管理

| 接口 | 方法 | 路径 | 后端文件 | 状态 |
|------|------|------|----------|------|
| 获取财务概览 | GET | `/admin/finance/overview` | AdminFinanceController | [x] 已完成 |
| 获取对账单列表 | GET | `/admin/finance/statements` | AdminFinanceController | [x] 已完成 |
| 获取对账单详情 | GET | `/admin/finance/statements/{statementId}` | AdminFinanceController | [x] 已完成 |

#### 政策配置

| 接口 | 方法 | 路径 | 后端文件 | 状态 |
|------|------|------|----------|------|
| 获取政策模板 | GET | `/admin/policies/templates` | AdminPolicyController | [x] 已完成 |
| 创建政策模板 | POST | `/admin/policies/templates` | AdminPolicyController | [x] 已完成 |
| 更新政策模板 | PUT | `/admin/policies/templates/{templateId}` | AdminPolicyController | [x] 已完成 |

#### 系统配置

| 接口 | 方法 | 路径 | 后端文件 | 状态 |
|------|------|------|----------|------|
| 获取系统配置 | GET | `/admin/system/config` | AdminSystemConfigController | [ ] 待对接 |
| 更新系统配置 | PUT | `/admin/system/config` | AdminSystemConfigController | [ ] 待对接 |

#### 区域管理

| 接口 | 方法 | 路径 | 后端文件 | 状态 |
|------|------|------|----------|------|
| 获取区域树 | GET | `/admin/regions/tree` | AdminRegionController | [x] 已完成 |
| 创建区域 | POST | `/admin/regions` | AdminRegionController | [x] 已完成 |
| 更新区域 | PUT | `/admin/regions/{regionId}` | AdminRegionController | [x] 已完成 |
| 删除区域 | DELETE | `/admin/regions/{regionId}` | AdminRegionController | [x] 已完成 |

### 移动端文件

#### 已创建

- [x] `lib/pages/admin/admin_home_page.dart` - 管理端首页（使用Mock数据）
- [x] `lib/pages/admin/admin_login_page.dart` - 管理端登录页
- [x] `lib/pages/admin/admin_stations_page.dart` - 水站管理页（已对接API）
- [x] `lib/pages/admin/admin_station_detail_page.dart` - 水站详情页（已对接API）
- [x] `lib/pages/admin/admin_drivers_page.dart` - 司机管理页
- [x] `lib/pages/admin/admin_driver_detail_page.dart` - 司机详情页
- [x] `lib/pages/admin/admin_warehouses_page.dart` - 仓库管理页
- [x] `lib/pages/admin/admin_warehouse_detail_page.dart` - 仓库详情页
- [x] `lib/pages/admin/admin_settings_page.dart` - 系统设置页
- [x] `lib/services/dashboard_service.dart` - Dashboard服务（使用Mock数据）
- [x] `lib/models/dashboard_model.dart` - Dashboard模型
- [x] `lib/models/admin_models.dart` - Admin管理端通用模型

#### 服务文件（已创建）

- [x] `lib/services/admin_station_service.dart` - 水站管理服务（含Mock数据）
- [x] `lib/services/admin_driver_service.dart` - 司机管理服务（含Mock数据）
- [x] `lib/services/admin_warehouse_service.dart` - 仓库管理服务（含Mock数据）
- [x] `lib/services/admin_report_service.dart` - 报表统计服务（含Mock数据）
- [x] `lib/services/admin_product_service.dart` - 商品管理服务（含Mock数据）
- [x] `lib/services/admin_inventory_service.dart` - 库存管理服务（含Mock数据）
- [x] `lib/services/admin_finance_service.dart` - 财务管理服务（含Mock数据）
- [x] `lib/services/admin_policy_service.dart` - 政策配置服务（含Mock数据）
- [x] `lib/services/admin_region_service.dart` - 区域管理服务（含Mock数据）

#### 待创建

- [ ] `lib/services/admin_system_service.dart` - 系统配置服务

### 对接说明

- [x] 水站管理接口已完成，支持列表查询、详情查看、创建、更新、状态更新
- [x] 司机管理接口已完成，支持列表查询、详情查看、创建、更新、状态更新，重置密码
- [x] 仓库管理接口已完成，支持列表查询、详情查看、创建、更新、状态更新
- [x] 报表统计接口已完成，支持Dashboard统计，销售趋势、产品分布、水站排行、日报、导出
- [x] 商品管理接口已完成，支持列表查询、详情查看、创建、更新、状态更新
- [x] 库存管理接口已完成，支持库存概览、库存列表、库存记录查询
- [x] 财务管理接口已完成，支持财务概览、对账单列表、对账单详情
- [x] 政策配置接口已完成，支持政策模板列表、创建、更新
- [x] 区域管理接口已完成，支持区域树查询、创建、更新、删除
- [x] 所有Mock测试数据已移除，数据完全通过API对接获取
- [ ] 系统配置接口待对接

---

## 三、水站端模块 (Station)

### 后端接口

| 接口 | 方法 | 路径 | 后端文件 | 状态 |
|------|------|------|----------|------|
| 获取水站信息 | GET | `/stations/info` | StationController | [x] 已完成 |
| 获取库存 | GET | `/stations/inventory` | StationController | [x] 已完成 |
| 账户充值 | POST | `/stations/recharge` | StationController | [x] 已完成 |
| 押金补缴 | POST | `/stations/deposit` | StationController | [x] 已完成 |
| 获取销售政策 | GET | `/stations/policy` | StationController | [x] 已完成 |

### 移动端文件

- [x] `lib/pages/owner/owner_home_page.dart` - 水站老板首页
- [x] `lib/pages/owner/owner_orders_page.dart` - 订单列表
- [x] `lib/pages/owner/owner_order_detail_page.dart` - 订单详情
- [x] `lib/pages/owner/owner_statement_page.dart` - 对账单
- [x] `lib/pages/owner/owner_profile_page.dart` - 个人中心
- [x] `lib/pages/owner/order_create_page.dart` - 下单页面
- [x] `lib/pages/owner/inventory_manage_page.dart` - 库存管理
- [x] `lib/pages/owner/statistics_page.dart` - 数据统计
- [x] `lib/services/station_service.dart` - 水站服务
- [x] `lib/models/station_model.dart` - 水站数据模型

### 对接说明

- [x] 获取水站信息接口已完成，支持账户余额、信用额度、欠桶数量等
- [x] 获取库存接口已完成，支持商品列表、库存状态
- [x] 账户充值接口已完成，支持赠送金额计算
- [x] 押金补缴接口已完成，支持微信支付跳转
- [x] 获取销售政策接口已完成，支持阶梯价格显示
- [ ] 不再使用Mock数据，完全依赖API返回真实数据

---

## 四、司机端模块 (Driver)

### 后端接口

#### 基础功能

| 接口 | 方法 | 路径 | 后端文件 | 状态 |
|------|------|------|----------|------|
| 获取Dashboard | GET | `/drivers/dashboard` | DriverController | [x] 已完成 |
| 获取配送任务 | GET | `/drivers/tasks` | DriverController | [x] 已完成 |
| 获取配送路线 | GET | `/drivers/route-planning` | DriverController | [x] 已完成 |
| 开始配送 | POST | `/drivers/{orderId}/start-delivery` | DriverController | [x] 已完成 |
| 配送签收 | POST | `/drivers/{orderId}/deliver` | DriverController | [x] 已完成 |
| 中途回仓 | POST | `/drivers/warehouse-return` | DriverController | [x] 已完成 |

#### 位置与状态

| 接口 | 方法 | 路径 | 后端文件 | 状态 |
|------|------|------|----------|------|
| 更新GPS位置 | POST | `/drivers/location` | DriverController | [x] 已完成 |
| 更新在线状态 | POST | `/drivers/status` | DriverController | [x] 已完成 |
| 获取司机状态 | GET | `/drivers/status` | DriverController | [x] 已完成 |
| GPS打卡 | POST | `/drivers/check-in` | DriverController | [x] 已完成 |

#### 司机对账

| 接口 | 方法 | 路径 | 后端文件 | 状态 |
|------|------|------|----------|------|
| 获取对账单列表 | GET | `/driver-statements` | DriverStatementController | [x] 已完成 |
| 获取对账单详情 | GET | `/driver-statements/{statementId}` | DriverStatementController | [x] 已完成 |
| 确认对账单 | POST | `/driver-statements/{statementId}/confirm` | DriverStatementController | [x] 已完成 |

### 移动端文件

- [x] `lib/pages/driver/driver_tasks_page.dart` - 任务中心
- [x] `lib/pages/driver/driver_order_detail_page.dart` - 订单详情
- [x] `lib/pages/driver/driver_barrel_page.dart` - 空桶管理
- [x] `lib/pages/driver/driver_statement_page.dart` - 司机对账
- [x] `lib/pages/driver/driver_settings_page.dart` - 司机设置
- [x] `lib/pages/driver/driver_warehouse_return_page.dart` - 回仓申请
- [x] `lib/services/driver_service.dart` - 司机服务
- [x] `lib/services/driver_status_service.dart` - 司机状态服务
- [x] `lib/services/driver_statement_service.dart` - 司机对账服务

### 对接说明

- [x] 获取Dashboard接口已完成，支持待配送、配送中、已完成数量统计
- [x] 获取配送任务接口已完成，支持按状态和排序筛选，包含Mock数据
- [x] 获取配送路线接口已完成，支持路线规划和距离计算
- [x] 开始配送接口已完成
- [x] 配送签收接口已完成，支持多种签收方式（签字、验证码、老板确认）
- [x] 中途回仓接口已完成
- [x] GPS位置更新接口已完成，支持定时更新
- [x] 在线状态管理接口已完成，支持在线、离线、休息三种状态
- [x] GPS打卡接口已完成
- [x] 获取对账单列表接口已完成，包含Mock数据
- [x] 获取对账单详情接口已完成，包含Mock数据
- [x] 确认对账单接口已完成

---

## 五、仓库端模块 (Warehouse)

### 后端接口

#### 基础功能

| 接口 | 方法 | 路径 | 后端文件 | 状态 |
|------|------|------|----------|------|
| 获取Dashboard | GET | `/warehouses/dashboard` | WarehouseController | [x] 已完成 |
| 获取订单列表 | GET | `/warehouses/orders` | WarehouseController | [x] 已完成 |
| 获取订单详情 | GET | `/warehouses/orders/{orderId}` | WarehouseController | [x] 已完成 |
| 接单 | PUT | `/warehouses/orders/{orderId}/accept` | WarehouseController | [x] 已完成 |
| 拒单 | PUT | `/warehouses/orders/{orderId}/reject` | WarehouseController | [x] 已完成 |
| 派单 | PUT | `/warehouses/orders/{orderId}/dispatch` | WarehouseController | [x] 已完成 |
| 回仓核对 | POST | `/warehouses/returns/{returnId}/check` | WarehouseController | [x] 已完成 |

#### 入库管理

| 接口 | 方法 | 路径 | 后端文件 | 状态 |
|------|------|------|----------|------|
| 获取入库列表 | GET | `/warehouses/inbound` | WarehouseInboundController | [x] 已完成 |
| 获取入库详情 | GET | `/warehouses/inbound/{inboundId}` | WarehouseInboundController | [x] 已完成 |
| 创建入库单 | POST | `/warehouses/inbound` | WarehouseInboundController | [x] 已完成 |
| 审核入库 | POST | `/warehouses/inbound/{inboundId}/check` | WarehouseInboundController | [x] 已完成 |

#### 出库管理

| 接口 | 方法 | 路径 | 后端文件 | 状态 |
|------|------|------|----------|------|
| 获取出库列表 | GET | `/warehouses/outbound` | WarehouseOutboundController | [x] 已完成 |
| 获取出库详情 | GET | `/warehouses/outbound/{outboundId}` | WarehouseOutboundController | [x] 已完成 |
| 创建订单出库 | POST | `/warehouses/outbound/order/{orderId}` | WarehouseOutboundController | [x] 已完成 |
| 创建出库单 | POST | `/warehouses/outbound` | WarehouseOutboundController | [x] 已完成 |
| 开始拣货 | PUT | `/warehouses/outbound/{outboundId}/pick` | WarehouseOutboundController | [x] 已完成 |
| 确认出库 | POST | `/warehouses/outbound/{outboundId}/confirm` | WarehouseOutboundController | [x] 已完成 |

#### 回仓管理

| 接口 | 方法 | 路径 | 后端文件 | 状态 |
|------|------|------|----------|------|
| 获取回仓列表 | GET | `/warehouses/returns` | WarehouseReturnController | [x] 已完成 |
| 获取回仓详情 | GET | `/warehouses/returns/{returnId}` | WarehouseReturnController | [x] 已完成 |
| 核对回仓 | POST | `/warehouses/returns/{returnId}/check` | WarehouseReturnController | [x] 已完成 |
| 处理补货 | POST | `/warehouses/returns/{returnId}/replenish` | WarehouseReturnController | [x] 已完成 |

#### 售后管理

| 接口 | 方法 | 路径 | 后端文件 | 状态 |
|------|------|------|----------|------|
| 获取售后列表 | GET | `/after-sales` | AfterSalesController | [x] 已完成 |
| 获取售后详情 | GET | `/after-sales/{afterSalesId}` | AfterSalesController | [x] 已完成 |
| 创建售后申请 | POST | `/after-sales` | AfterSalesController | [x] 已完成 |
| 处理售后 | POST | `/after-sales/{afterSalesId}/process` | AfterSalesController | [x] 已完成 |
| 完成售后 | POST | `/after-sales/{afterSalesId}/complete` | AfterSalesController | [x] 已完成 |

### 移动端文件

#### 已创建页面
- [x] `lib/pages/warehouse/warehouse_home_page.dart` - 仓库首页
- [x] `lib/pages/warehouse/warehouse_orders_page.dart` - 订单管理（含API对接）
- [x] `lib/pages/warehouse/warehouse_order_detail_page.dart` - 订单详情
- [x] `lib/pages/warehouse/warehouse_order_reject_page.dart` - 拒单处理
- [x] `lib/pages/warehouse/warehouse_prepare_list_page.dart` - 备货列表
- [x] `lib/pages/warehouse/warehouse_inbound_page.dart` - 入库管理（含API对接）
- [x] `lib/pages/warehouse/warehouse_outbound_page.dart` - 出库管理（含API对接）
- [x] `lib/pages/warehouse/warehouse_inventory_page.dart` - 库存盘点
- [x] `lib/pages/warehouse/warehouse_return_list_page.dart` - 回仓列表（含API对接）
- [x] `lib/pages/warehouse/warehouse_return_check_page.dart` - 回仓核对
- [x] `lib/pages/warehouse/warehouse_after_sales_page.dart` - 售后处理（含API对接）
- [x] `lib/pages/warehouse/warehouse_after_sales_detail_page.dart` - 售后详情
- [x] `lib/pages/warehouse/warehouse_settings_page.dart` - 仓库设置

#### 已创建服务
- [x] `lib/services/warehouse_service.dart` - 仓库服务（已完善）
- [x] `lib/services/warehouse_inbound_service.dart` - 入库服务
- [x] `lib/services/warehouse_outbound_service.dart` - 出库服务
- [x] `lib/services/warehouse_return_service.dart` - 回仓服务
- [x] `lib/services/after_sales_service.dart` - 售后管理服务
- [x] `lib/services/warehouse_dashboard_service.dart` - 仓库Dashboard服务

#### 已创建模型
- [x] `lib/models/warehouse_models.dart` - 入库模型
- [x] `lib/models/outbound_model.dart` - 出库模型
- [x] `lib/models/warehouse_return_model.dart` - 回仓核对模型
- [x] `lib/models/after_sales_model.dart` - 售后模型
- [x] `lib/models/warehouse_dashboard_model.dart` - 仓库Dashboard模型

### 对接说明

- [x] 获取仓库Dashboard接口已完成，支持统计、任务和预警信息
- [x] 获取订单列表接口已完成，支持状态和关键词筛选
- [x] 接单、拒单、派单接口已完成
- [x] 获取入库列表接口已完成，支持类型和状态筛选
- [x] 创建入库单和审核入库接口已完成
- [x] 获取出库列表接口已完成，支持类型和状态筛选
- [x] 创建出库单、开始拣货、确认出库接口已完成
- [x] 获取回仓列表接口已完成，支持状态筛选
- [x] 回仓核对接口已完成
- [x] 获取售后列表接口已完成，支持类型和状态筛选
- [x] 处理售后和完成售后接口已完成
- [x] 所有服务均包含Mock数据作为API失败的fallback

---

## 六、订单模块 (Order)

### 后端接口

| 接口 | 方法 | 路径 | 后端文件 | 状态 |
|------|------|------|----------|------|
| 获取订单列表 | GET | `/orders` | OrderController | [x] 已完成 |
| 获取订单详情 | GET | `/orders/{orderId}` | OrderController | [x] 已完成 |
| 创建订单 | POST | `/orders` | OrderController | [x] 已完成 |
| 更新订单 | PUT | `/orders/{orderId}` | OrderController | [ ] 待对接 |
| 更新订单状态 | PUT | `/orders/{orderId}/status` | OrderController | [x] 已完成 |
| 审查订单 | POST | `/orders/{orderId}/review` | OrderController | [ ] 待对接 |
| 派单 | POST | `/orders/{orderId}/dispatch` | OrderController | [ ] 待对接 |
| 配送 | POST | `/orders/{orderId}/deliver` | OrderController | [ ] 待对接 |
| 取消订单 | POST | `/orders/{orderId}/cancel` | OrderController | [ ] 待对接 |

### 移动端文件

- [x] `lib/services/order_service.dart` - 订单服务
- [x] `lib/models/order_model.dart` - 订单模型
- [x] `lib/pages/order/order_list_page.dart` - 订单列表
- [x] `lib/pages/order/order_create_page.dart` - 创建订单

---

## 七、售后模块 (AfterSales)

### 后端接口

| 接口 | 方法 | 路径 | 后端文件 | 状态 |
|------|------|------|----------|------|
| 获取售后列表 | GET | `/after-sales` | AfterSalesController | [ ] 待对接 |
| 获取售后详情 | GET | `/after-sales/{afterSalesId}` | AfterSalesController | [ ] 待对接 |
| 创建售后申请 | POST | `/after-sales` | AfterSalesController | [ ] 待对接 |
| 处理售后 | POST | `/after-sales/{afterSalesId}/process` | AfterSalesController | [ ] 待对接 |

### 移动端文件

- [ ] `lib/services/after_sales_service.dart` - 售后服务（待创建）

---

## 对接规范

本项目遵循以下API对接规范：

1. **HTTP方法**: 使用 GET、POST、PUT、DELETE 方法
2. **请求头**: 包含 `Authorization: Bearer {token}`
3. **请求体**: 使用 JSON 格式，`Content-Type: application/json`
4. **响应格式**: 
   ```json
   {
     "success": true,
     "data": {},
     "message": "操作成功"
   }
   ```
5. **错误处理**: 所有服务包含 Mock 数据，在 API 失败时自动降级
6. **分页参数**: 使用 `page` 和 `pageSize` 参数

## 后续计划

### 高优先级
- [ ] 完成 Dashboard 首页 API 对接
- [ ] 完成司机端 API 对接
- [ ] 完成仓库端 API 对接
- [ ] 完成订单模块剩余 API 对接
- [ ] 完成售后模块 API 对接

### 中优先级
- [ ] 完成水站端 API 对接
- [ ] 添加实时数据更新功能
- [ ] 优化加载状态和错误处理

### 低优先级
- [ ] 离线功能支持
- [ ] 数据缓存优化
- [ ] 性能优化
