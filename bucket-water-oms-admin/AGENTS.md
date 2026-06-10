# 开发记录与注意事项

## 项目概述
水厂订货管理系统 - 管理员后台（Vue3 + Vite + TypeScript + Tailwind CSS）

## 开发时间
- 开始时间：2026-04-19
- 完成时间：2026-04-19

## 技术栈
- **前端框架**: Vue 3 (Composition API)
- **构建工具**: Vite 5
- **类型系统**: TypeScript
- **样式框架**: Tailwind CSS
- **图标库**: Iconify (@iconify/vue)
- **状态管理**: Pinia
- **路由**: Vue Router 4

## 项目结构
```
src/
├── components/          # 公共组件
│   ├── Layout.vue      # 页面布局组件
│   ├── Sidebar.vue     # 侧边栏导航
│   └── Header.vue      # 顶部头部
├── views/              # 页面视图
│   ├── Login.vue       # 登录页
│   ├── Dashboard.vue   # 首页/数据概览
│   ├── Stations.vue    # 水站管理
│   ├── StationDetail.vue # 水站详情
│   ├── Products.vue    # 产品管理
│   ├── Drivers.vue     # 司机管理
│   ├── DriverDetail.vue # 司机详情
│   ├── Policies.vue    # 销售政策
│   ├── Warehouses.vue  # 仓库管理
│   ├── WarehouseDetail.vue # 仓库详情
│   ├── Orders.vue      # 订单管理
│   ├── Inventory.vue   # 库存管理
│   ├── Finance.vue     # 财务管理
│   ├── Reports.vue     # 报表统计
│   └── Settings.vue    # 系统配置
├── router/             # 路由配置
│   └── index.ts
├── stores/              # Pinia 状态管理
│   └── auth.ts
├── App.vue             # 根组件
└── main.ts             # 应用入口
```

## 已完成功能

### 1. 登录页面 (Login)
- ✅ 响应式布局
- ✅ 表单验证
- ✅ 登录状态管理
- ✅ 记住登录状态
- ✅ 错误提示

### 2. 布局组件
- ✅ 固定侧边栏导航
- ✅ 顶部 Header（包含通知、用户信息）
- ✅ Header 插槽支持（支持页面特定的操作按钮）
- ✅ 路由切换

### 3. 首页/数据概览 (Dashboard)
- ✅ 统计卡片（销售额、订单数、活跃水站、库存预警）
- ✅ 销售趋势图表区域
- ✅ 快捷操作入口
- ✅ 重要通知列表

### 4. 水站管理 (Stations)
- ✅ 搜索筛选功能
- ✅ 水站列表表格
- ✅ 状态标签（正常运营/欠费停供/已注销）
- ✅ 分页功能
- ✅ 操作按钮（编辑/订单/政策）
- ✅ **新增水站弹窗（完整表单）**
  - 水站基本信息（水站名称、编号自动生成、地址）
  - 联系人信息（联系人、电话）
  - 所属区域和水站类型选择
  - 初始预存金和信用额度设置
  - 备注说明
  - 表单验证和数据提交

### 4. 仓库管理 (Warehouses)
- ✅ 仓库列表展示
- ✅ 搜索筛选功能
- ✅ 添加新仓库（弹窗表单）
- ✅ 编辑仓库信息
- ✅ 仓库详情查看
- ✅ 启用/停用仓库
- ✅ 仓库类型区分（总仓/分仓）
- ✅ 分页功能

### 5. 销售政策 (Policies)
- ✅ 政策模板卡片展示
- ✅ 产品定价列表
- ✅ 政策类型标签（默认/VIP/促销）
- ✅ 添加新政策（弹窗表单）
- ✅ 编辑政策信息
- ✅ 删除政策（确认弹窗）
- ✅ 复制政策
- ✅ 启用/停用政策
- ✅ 操作菜单

### 6. 库存管理 (Inventory)
- ✅ 仓库选择标签
- ✅ 库存统计卡片
- ✅ 出入库记录表格
- ✅ 业务类型标签
- ✅ 入库登记弹窗（完整表单）
- ✅ 库存盘点弹窗（完整表单）

### 7. 产品管理 (Products) - 新增
- ✅ 产品分类标签（桶装水/瓶装水/饮水设备/其他）
- ✅ 产品统计卡片（数量、库存、预警）
- ✅ 产品列表表格（编号、名称、规格、价格、库存、状态）
- ✅ 新增产品弹窗（完整表单）
  - 产品名称、分类、规格
  - 出厂价、指导价区间
  - 计量单位、安全库存
  - 产品描述、图片上传
  - 启用/下架状态
- ✅ 编辑产品信息
- ✅ 上架/下架产品
- ✅ 删除产品（确认弹窗）
- ✅ 搜索和筛选功能

### 8. 司机管理 (Drivers) - 新增
- ✅ 司机统计卡片（在线/离线/配送中/今日完成）
- ✅ 搜索筛选功能（姓名/电话、状态、区域）
- ✅ 司机列表表格（信息、联系方式、区域、任务、状态）
- ✅ 新增司机弹窗（完整表单）
  - 姓名、工号、电话、身份证
  - 负责区域、车辆信息
  - 配送仓库、账号信息
  - 备注说明
- ✅ 编辑司机信息
- ✅ 查看配送记录
- ✅ 重置密码
- ✅ 启用/停用账号

### 9. 报表统计 (Reports) - 增强
- ✅ 报表类型切换（日报/周报/月报/季报）
- ✅ **销售统计** - 销售趋势、产品销量构成、水站订货排行、销售日报表
- ✅ **水站进货报表** - 按月份统计每个水站各产品进货量、金额
  - 水站列表（名称、区域、桶装水、瓶装水、其他、总额）
  - 合计行统计
  - 导出Excel功能
- ✅ **司机配送报表** - 按月份统计每个司机配送单数、桶数、里程
  - 配送统计卡片（单数、桶数、里程、准时率）
  - 司机配送明细表格
  - 导出Excel功能
- ✅ **空桶汇总报表** - 各水站欠桶数量、各仓库空桶库存、在途空桶
  - 空桶统计卡片（欠桶总数、仓库库存、在途）
  - 水站欠桶明细表格
  - 仓库空桶库存表格
  - 在途空桶表格
  - 导出功能

### 10. 系统配置 (Settings) - 增强
- ✅ 基本设置（系统名称、Logo、联系方式）
- ✅ 对账设置（固定对账日、通知方式）
- ✅ 库存设置（预警阈值、自动补货）
- ✅ 通知设置（订单状态、库存预警、欠桶预警开关）
- ✅ **管理员管理** - 新增Tab页
  - 管理员账号卡片展示
  - 添加管理员弹窗（姓名、手机、账号、密码、角色、权限配置）
  - 编辑管理员信息
  - 启用/停用账号
  - 重置密码
- ✅ **审计日志** - 新增Tab页
  - 日志列表表格（时间、操作员、操作类型、内容、IP）
  - 操作类型筛选（新增/修改/删除/登录/导出）
  - 导出日志功能
- ✅ **地域配置** - 新增Tab页
  - 覆盖区域管理表格（区域名称、编码、上级区域、层级、状态）
  - 添加区域弹窗（区域名称、编码、上级区域、排序、备注）
  - 编辑区域信息
  - 启用/停用区域
  - 删除区域（带确认）
  - 层级标识（省/直辖市、市/区、县/街道）

### 11. 库存管理 (Inventory) - 增强
- ✅ 仓库选择标签
- ✅ 库存统计卡片
- ✅ 出入库记录表格
- ✅ 业务类型标签
- ✅ **入库登记弹窗（完整表单）**
  - 入库类型选择（生产入库/退货入库/调拨入库/其他入库）
  - 产品名称和数量选择
  - 关联水站/车间
  - 入库仓库选择
  - 备注说明
  - 表单验证和数据提交
- ✅ **库存盘点弹窗（完整表单）**
  - 盘点仓库选择
  - 盘点信息展示（仓库、时间、盘点人）
  - 库存核对表格（系统库存vs实际库存）
  - 差异计算和颜色标识
  - 备注说明
  - 盘点总结
  - 盘点结果提交

### 11. 财务管理 (Finance)
- ✅ 财务统计卡片
- ✅ 应收款明细表格
- ✅ 预存金余额明细表格
- ✅ 状态标签
- ✅ **导出报表弹窗（完整表单）**
  - 报表类型选择（应收款/预存金/结算/综合报表）
  - 日期范围选择（开始日期和结束日期）
  - 筛选条件（水站名称/账期类型/结算状态）
  - 导出格式选择（Excel/PDF/CSV）
  - 包含明细数据选项
  - 报表导出功能

### 12. 水站详情 (StationDetail) - 新增二级页面
- ✅ 基本信息卡片（水站名称、编号、状态、联系人、电话、地址）
- ✅ 账户与财务卡片（预存金余额、信用额度、押金桶数、欠桶数量）
- ✅ 欠桶预警提示（当欠桶超过阈值时显示红色预警）
- ✅ 销售政策配置（账期类型、预存金要求、欠桶阈值、每桶押金金额）
- ✅ 独立定价列表（各商品的水站独立单价）
- ✅ 运营数据统计（本月订单数、进货桶数、进货金额、回桶数量）
- ✅ 最近订单列表（订单号、金额、状态、时间）
- ✅ 店员账号列表（姓名、电话、角色、状态）
- ✅ 编辑水站信息弹窗
- ✅ 返回水站管理列表功能

### 13. 司机详情 (DriverDetail) - 新增二级页面
- ✅ 基本信息卡片（头像、姓名、工号、联系电话、紧急联系人、车牌号、车辆类型）
- ✅ 实时状态（当前位置、GPS状态、当前任务、车上空桶）
- ✅ 今日汇总（完成配送、送水桶数、行驶里程、工作时长）
- ✅ 配送业绩统计（本月完成、配送桶数、好评率、配送里程）
- ✅ 本月配送效率趋势图表
- ✅ 最近配送任务表格（订单号、水站、配送时间、桶数、状态）
- ✅ 空桶往来（车上空桶、回收/送出统计）
- ✅ 快捷操作（联系司机、查看位置、设为休息）
- ✅ 编辑司机信息弹窗
- ✅ 重置密码功能
- ✅ 返回司机管理列表功能

### 14. 仓库详情 (WarehouseDetail) - 新增二级页面
- ✅ 基本信息卡片（仓库名称、编号、状态、管理员、电话、地址、面积、覆盖区域）
- ✅ 库存概览（成品水库存、空桶库存、今日入库、今日出库）
- ✅ 分仓库库存明细（各商品库存及预警提示）
- ✅ 待处理订单列表（订单号、水站、下单时间、桶数、状态）
- ✅ 今日运营数据（待接单、备货中、配送中、已完成）
- ✅ 仓库人员列表（姓名、角色、在线状态）
- ✅ 配送司机列表（姓名、当前任务、状态）
- ✅ 快捷操作（订单管理、入库登记、库存盘点、打印备货单）
- ✅ 编辑仓库信息弹窗
- ✅ 入库登记弹窗（入库类型选择、商品、数量、单价、备注）
- ✅ 返回仓库管理列表功能

### 15. 订单管理 (Orders) - 新增页面
- ✅ 订单搜索筛选（订单号/水站名称、订单状态、仓库、日期范围）
- ✅ 订单列表表格（订单号、水站、仓库、金额、桶数、状态、时间）
- ✅ 状态标签（待审查/已接单/已派单/配送中/已完成/已取消/已拒单）
- ✅ 订单详情弹窗（完整订单信息、商品明细、签收信息）
- ✅ 订单操作菜单（查看详情、取消订单、打印订单）
- ✅ 分页功能
- ✅ 导出订单功能
- ✅ 支持按水站筛选订单

## 设计风格

### 颜色系统
- **主色调**: #1890FF (蓝色)
- **背景色**: #f0f2f5 (浅灰)
- **成功色**: #52C41A (绿色)
- **警告色**: #FAAD14 (橙色)
- **错误色**: #FF4D4F (红色)

### 组件规范
- 卡片圆角: `rounded-2xl` / `rounded-3xl`
- 按钮圆角: `rounded-xl` / `rounded-lg`
- 输入框圆角: `rounded-xl`
- 卡片阴影: `shadow-sm border border-gray-50`

### 字体
- 字体族: `'PingFang SC', 'Microsoft YaHei', sans-serif`

### 弹窗设计模式
所有新增功能均采用统一的弹窗设计模式：
- 固定定位全屏遮罩层（bg-black bg-opacity-50）
- 居中白色卡片（bg-white rounded-2xl）
- 弹窗头部：标题 + 关闭按钮
- 弹窗内容：表单区域，支持多种表单项
  - 单选按钮组（用于选择类型）
  - 下拉选择框
  - 输入框（文本、数字、日期）
  - 文本域（多行文本）
  - 复选框
- 弹窗底部：取消和确认按钮
- 支持表单验证和数据提交
- 点击遮罩层可关闭弹窗

## 注意事项

### 1. 路由守卫
```typescript
// 在 router/index.ts 中已配置路由守卫
// 未登录用户自动跳转到登录页
// 已登录用户访问登录页自动跳转到首页
```

### 2. API 代理配置
```typescript
// vite.config.ts 中已配置 API 代理
// 开发环境: /api/* -> http://localhost:3000
// 后端接口对接时需修改目标地址
```

### 3. Mock 数据
- 当前所有页面使用静态 Mock 数据
- 后端 API 对接后需修改 stores 中的数据获取逻辑

### 4. 状态管理
- 使用 Pinia 进行状态管理
- auth store 管理登录状态和用户信息
- regionStore 管理地域配置数据
- 可根据需要添加新的 store（如 stationStore, inventoryStore 等）

## 运行项目

### 安装依赖
```bash
npm install
```

### 开发模式
```bash
npm run dev
```
访问 http://localhost:5173

### 类型检查
```bash
npm run lint
```

### 生产构建
```bash
npm run build
```

## API 模块结构与使用

本项目已完成 API 对接，API 地址配置为: http://192.168.31.72:8080/api

### API 目录结构
```
src/api/
├── index.ts              # 统一导出
├── request.ts            # Axios 实例和拦截器
├── auth.ts               # 认证模块（登录、Token刷新）
├── stations.ts           # 水站管理
├── warehouses.ts         # 仓库管理
├── drivers.ts            # 司机管理
├── products.ts           # 产品管理
├── policies.ts           # 销售政策
├── inventory.ts          # 库存管理
├── finance.ts           # 财务管理
├── system.ts            # 系统配置
├── reports.ts           # 报表统计
├── export.ts            # 导出功能
└── region.ts            # 地域管理
```

### API 模块说明

#### 认证模块 (auth.ts)
- `login(data)` - 用户登录，支持水站/司机/仓库/管理员登录
- `refreshToken(authorization)` - 刷新Token
- `sendSmsCode(phone)` - 发送短信验证码

#### 水站管理 (stations.ts)
- `getAll(params?)` - 获取水站列表（支持状态筛选）
- `create(data)` - 创建水站账号
- `update(id, data)` - 更新水站信息
- `delete(id)` - 删除水站
- `getPolicies(stationId)` - 获取水站政策
- `assignPolicy(stationId, policyId)` - 分配政策

#### 仓库管理 (warehouses.ts)
- `getAll(params?)` - 获取仓库列表
- `create(data)` - 创建仓库账号
- `update(id, data)` - 更新仓库信息
- `delete(id)` - 删除仓库
- `getInventory(warehouseId)` - 获取仓库库存

#### 司机管理 (drivers.ts)
- `getAll(params?)` - 获取司机列表
- `create(data)` - 创建司机账号
- `update(id, data)` - 更新司机信息
- `delete(id)` - 删除司机
- `getStatements(driverId, params?)` - 获取对账单
- `generateStatement(driverId)` - 生成对账单

#### 产品管理 (products.ts)
- `getAll(params?)` - 获取产品列表
- `getById(id)` - 获取产品详情
- `create(data)` - 创建产品
- `update(id, data)` - 更新产品
- `delete(id)` - 删除产品

#### 销售政策 (policies.ts)
- `getTemplates()` - 获取政策模板列表
- `getTemplateById(id)` - 获取政策模板详情
- `createTemplate(data)` - 创建政策模板
- `updateTemplate(id, data)` - 更新政策模板
- `deleteTemplate(id)` - 删除政策模板
- `copyTemplate(id)` - 复制政策模板
- `enableTemplate(id)` - 启用政策
- `disableTemplate(id)` - 禁用政策

#### 库存管理 (inventory.ts)
- `recordInbound(data)` - 入库登记
- `recordOutbound(data)` - 出库登记
- `getInventoryList(params)` - 获取库存记录列表
- `getInventorySummary(warehouseId?)` - 获取库存汇总

#### 财务管理 (finance.ts)
- `getStatements(params?)` - 获取对账单列表
- `getStatementById(id)` - 获取对账单详情
- `confirmStatement(id)` - 确认对账单
- `handleDispute(id, resolution)` - 处理争议
- `getReceivables(params?)` - 获取应收款明细
- `getPredeposits(params?)` - 获取预存金明细
- `getSummary()` - 获取财务汇总数据

#### 系统配置 (system.ts)
- `getConfigs()` - 获取系统配置列表
- `updateConfig(id, value)` - 更新配置值
- `getAdmins()` - 获取管理员列表
- `createAdmin(data)` - 添加管理员
- `updateAdmin(id, data)` - 更新管理员
- `deleteAdmin(id)` - 删除管理员
- `resetAdminPassword(id)` - 重置管理员密码

#### 报表统计 (reports.ts)
- `getDashboardStats()` - 获取仪表盘统计数据
- `getSalesTrend(params?)` - 获取销售趋势
- `getProductSales(params?)` - 获取产品销售统计
- `getStationRanking(params?)` - 获取水站排名
- `getDailySales(params?)` - 获取日报表
- `getBucketSummary(params?)` - 获取空桶汇总

#### 导出功能 (export.ts)
- `exportReceivables(data)` - 导出应收款报表
- `exportPredeposits(data)` - 导出预存金报表
- `exportStatements(data)` - 导出对账单
- `exportComprehensiveReport(data)` - 导出综合报表

#### 地域管理 (region.ts)
- `getAll(params?)` - 获取地域列表（支持状态、层级筛选）
- `getTree()` - 获取地域树形结构
- `getById(id)` - 获取地域详情
- `getByCode(code)` - 根据编码获取地域
- `getChildren(parentCode)` - 获取子地域
- `getProvinces()` - 获取省份列表
- `getCities(provinceCode)` - 获取城市列表
- `getDistricts(cityCode)` - 获取区县列表
- `create(data)` - 创建地域
- `update(id, data)` - 更新地域信息
- `delete(id)` - 删除地域
- `enable(id)` - 启用地域
- `disable(id)` - 禁用地域
- `updateSort(id, sort)` - 更新排序
- `batchUpdate(data)` - 批量更新地域

### 使用示例

```typescript
// 在组件中导入API模块
import { stationsApi, authApi } from '@/api'

// 登录示例
const handleLogin = async () => {
  try {
    const res = await authApi.login({
      username: 'admin',
      password: '123456',
      userType: 'ADMIN'
    })
    localStorage.setItem('token', res.token)
  } catch (error) {
    console.error('登录失败:', error)
  }
}

// 获取水站列表示例
const loadStations = async () => {
  try {
    const res = await stationsApi.getAll({ status: 'ACTIVE' })
    console.log('水站列表:', res.data)
  } catch (error) {
    console.error('获取失败:', error)
  }
}
```

### 环境配置

API 地址在以下位置配置：
- **开发环境**: `.env` 文件中的 `VITE_API_BASE_URL`
- **Vite 代理**: `vite.config.ts` 中的 `server.proxy` 配置

## 后端对接指南

### 1. API 基础地址
编辑 `vite.config.ts`:
```typescript
server: {
  proxy: {
    '/api': {
      target: 'http://your-backend-url:port',
      changeOrigin: true
    }
  }
}
```

### 2. 创建 API 模块
在 `src/api/` 目录下创建 API 模块：
```typescript
// src/api/station.ts
import axios from 'axios'

export const getStations = (params: any) => {
  return axios.get('/api/stations', { params })
}

export const createStation = (data: any) => {
  return axios.post('/api/stations', data)
}
```

### 3. 修改 Store 中的数据获取逻辑
在 `src/stores/` 目录下修改对应的 store：
```typescript
// 示例：修改 stations store
import { defineStore } from 'pinia'
import { ref } from 'vue'
import { getStations } from '@/api/station'

export const useStationStore = defineStore('station', () => {
  const stations = ref([])
  const loading = ref(false)

  const fetchStations = async () => {
    loading.value = true
    try {
      const res = await getStations()
      stations.value = res.data
    } finally {
      loading.value = false
    }
  }

  return { stations, loading, fetchStations }
})
```

## 开发建议

### 1. 代码规范
- 使用 Composition API
- 组件采用 PascalCase 命名
- 函数采用 camelCase 命名
- 样式使用 Tailwind CSS 工具类

### 2. TypeScript 类型定义
- 为所有数据模型定义 TypeScript 接口
- 使用 `ref<T>()` 和 `computed<T>()` 确保类型安全

### 3. 组件拆分
- 将可复用的 UI 部分抽取为组件
- 保持组件职责单一
- 使用 Props 和 Emit 进行组件通信

### 4. 性能优化
- 使用 `defineAsyncComponent` 懒加载路由组件
- 合理使用 `computed` 缓存计算结果
- 使用 `v-memo` 优化大列表渲染

## 常见问题

### Q: 如何添加新页面？
1. 在 `src/views/` 创建新页面组件
2. 在 `src/router/index.ts` 中添加路由配置
3. 在 `src/components/Sidebar.vue` 中添加导航链接

### Q: 如何添加新的状态管理？
1. 在 `src/stores/` 创建新的 store 文件
2. 使用 `defineStore` 定义 store
3. 在需要使用的组件中导入并使用

### Q: 如何修改主题色？
编辑 `tailwind.config.js`:
```javascript
theme: {
  extend: {
    colors: {
      primary: '#your-color-code',
    },
  },
},
```

## API 调试通知系统

为方便定位问题，所有 API 请求结果都会以弹窗形式显示。

### 功能特性
- ✅ **成功提示**: 显示绿色成功消息，包含请求方法和地址
- ✅ **错误提示**: 显示红色错误消息，包含详细错误信息
- ✅ **详细信息**: 支持展开查看完整响应数据和堆栈信息
- ✅ **自动关闭**: 成功提示 3 秒自动关闭，错误提示 8 秒自动关闭
- ✅ **调试模式**: 可通过修改 `DEBUG_MODE` 开关控制是否显示提示

### 组件位置
- 通知组件: `src/components/Toast.vue`
- 工具函数: `src/composables/useToast.ts`

### 使用方法

#### 1. 手动调用通知
```typescript
// 导入 toast 工具
import { toast } from '@/composables/useToast'
// 或者从 @/api 导入
import { toast } from '@/api'

// 显示不同类型的通知
toast.success('操作成功！')
toast.error('请求失败！')
toast.warning('警告信息')
toast.info('提示信息')

// 自定义通知
toast.show({
  type: 'error',
  title: '自定义标题',
  message: '这是消息内容',
  details: '这是详细信息，可以是JSON或错误堆栈',
  duration: 10000,
  showDetails: true
})
```

#### 2. 响应拦截器配置
在 `src/utils/request.ts` 中已配置自动通知：
- 所有成功的 API 请求会显示绿色成功提示
- 所有失败的 API 请求会显示红色错误提示
- 提示包含请求方法、URL、响应数据等详细信息

#### 3. 调试模式控制
修改 `src/utils/request.ts` 文件顶部的 `DEBUG_MODE` 常量：
```typescript
const DEBUG_MODE = true   // 开启调试模式（显示所有提示）
const DEBUG_MODE = false  // 关闭调试模式（只显示简短错误提示）
```

### 通知显示内容

#### 成功提示
- 图标: ✅ 绿色勾选图标
- 标题: `{METHOD} {URL} 成功`（如: `GET /api/admin/regions 成功`）
- 消息: 响应中的 message 字段或默认文本
- 详情: 响应码、数据预览（最多显示500字符）

#### 错误提示
- 图标: ❌ 红色错误图标
- 标题: `❌ {METHOD} {URL}`（如: `❌ GET /api/admin/regions`）
- 消息: 错误描述（从响应或错误码推断）
- 详情:
  - 错误详情信息
  - HTTP 状态码
  - 请求方法
  - 请求完整地址
  - 完整响应数据（JSON格式）

### 适用场景
- 🎯 **前后端联调**: 快速定位接口问题
- 🐛 **Bug 排查**: 查看请求参数和响应数据
- 📊 **数据调试**: 检查 API 返回的数据格式
- 🔍 **网络问题**: 判断是前端问题还是后端问题

### 注意事项
- ⚠️ **生产环境**: 建议关闭 `DEBUG_MODE`，避免频繁弹窗影响用户体验
- ⚠️ **敏感数据**: 错误详情可能包含服务器内部信息，生产环境需谨慎
- 💡 **控制台日志**: 提示信息会同时输出到浏览器控制台，方便截图和复制

### 修复的问题

#### 2026-04-22: 修复 Stations.vue 中未使用的变量和函数
**问题描述**:
- TypeScript 严格模式报错：检测到未使用的变量 `closePolicyDialog`、`showPolicyDialog`、`selectedStationForPolicy`、`editPolicy`
- 这些变量和函数在代码中定义但没有对应的模板实现

**问题根因**:
- 存在调用 `editPolicy` 的按钮，但没有实现对应的对话框模板
- 未完成的政策管理功能导致代码不完整

**修复方案**:
1. 移除未使用的变量：
   - `showPolicyDialog`
   - `selectedStationForPolicy`
2. 移除未使用的函数：
   - `editPolicy`
   - `_closePolicyDialog`
3. 移除模板中调用 `editPolicy` 的按钮

**教训**:
- 在添加新功能时，应确保模板和逻辑代码同步实现
- 未完成的功能应使用注释标记或 TODO，而不是保留未使用的代码
- TypeScript 严格模式有助于发现不完整的代码实现
- 定期运行类型检查可以及早发现潜在问题

## 后端开发文档

地域管理模块的后端开发指南已整理完成，详见：
- [地域管理API开发指南](REGION_API_DEV_GUIDE.md)

该文档包含：
- 数据库表结构设计
- Java实体类、DTO、Mapper定义
- Service层完整业务逻辑
- Controller层RESTful接口
- 业务规则和错误码定义
- 关联业务使用示例

## 后续开发计划

### Phase 2 (MVP 完成后)
- [x] 实现完整的 API 对接
- [ ] 添加表单验证（VeeValidate）
- [ ] 实现数据导出功能（Excel/PDF）
- [ ] 添加图表库（ECharts）
- [ ] 实现通知系统

### Phase 3
- [ ] 添加数据可视化大屏
- [ ] 实现高级查询和筛选
- [ ] 添加操作日志记录
- [ ] 实现权限管理细化

## 仓库端功能完善 (2026-04-24)

### 完成的工作

#### 前端页面实现

**1. 修复订单详情页 (WarehouseOrderDetail.vue)**
- ✅ 移除硬编码Mock数据
- ✅ 接入真实API获取订单详情
- ✅ 使用 `warehouseApi.getOrderById()` 获取数据
- ✅ 添加加载状态和错误处理
- ✅ 完善状态管理和操作按钮

**2. 新增备货中列表页面 (WarehousePrepareList.vue)**
- ✅ 备货进度显示（已完成/总数量）
- ✅ Tab切换：待接单、备货中、已派单、全部
- ✅ 状态筛选：全部、备货中、待派单、已派单
- ✅ 打印备货单按钮
- ✅ 选择司机派单入口
- ✅ 实时等待时间显示
- ✅ 已派单订单显示司机信息

**3. 新增派单司机选择页面 (WarehouseDispatchSelect.vue)**
- ✅ 订单信息摘要展示
- ✅ 推荐司机标记（蓝色边框）
- ✅ 司机信息：头像、姓名、工号、评分、总订单数
- ✅ 当前位置显示（仓库内或距离）
- ✅ 当前任务数和今日完成数
- ✅ 派单确认对话框
- ✅ 繁忙司机（任务数>=4）不可选

**4. 新增拒单详情页 (WarehouseOrderReject.vue)**
- ✅ 拒单原因选择（库存不足/配送人员不足/地址错误/其他）
- ✅ 库存不足明细显示（短缺数量）
- ✅ 补充说明输入框
- ✅ 通知预览（拒单后发送的水站通知内容）
- ✅ 确认拒单按钮
- ✅ 取消返回订单详情

**5. 新增空桶入库页面 (WarehouseBucketInbound.vue)**
- ✅ Tab分类：司机回桶、清洗入库、调拨入库
- ✅ 入库列表展示
- ✅ 入库详情弹窗
- ✅ 确认入库按钮
- ✅ 打印入库单按钮
- ✅ 状态标签（待核验、已入库、已拒绝）
- ✅ 来源标识（配送回收、清洗完成、仓库调拨）

**6. 新增空桶出库页面 (WarehouseBucketOutbound.vue)**
- ✅ Tab分类：司机领用、调拨出库、损耗出库
- ✅ 库存概览展示（渐变背景卡片）
- ✅ 出库申请列表
- ✅ 确认出库/完成出库按钮
- ✅ 拒绝出库按钮
- ✅ 打印出库单按钮
- ✅ 今日出库统计
- ✅ 库存预警提示

**7. 新增回仓列表页面 (WarehouseReturnList.vue)**
- ✅ Tab分类：待核对、已核对、差异记录
- ✅ 回仓申请列表
- ✅ 司机上报回收空桶数量
- ✅ 欠桶数量显示
- ✅ 申请补货信息
- ✅ 核对空桶按钮
- ✅ 核对详情弹窗（实际回收数量输入、差异说明）
- ✅ 打印回仓单按钮
- ✅ 等待时间显示

#### 后端API实现

**1. 订单详情API**
- ✅ GET /api/orders/{orderId} - 获取订单详情
- ✅ 在 OrderService 中完善 getOrderDetail 方法

**2. 备货订单列表API**
- ✅ GET /api/warehouses/orders/preparing - 获取备货订单列表
- ✅ 支持状态筛选：preparing/prepared/dispatched
- ✅ 返回订单详情、商品明细、备货进度

**3. 推荐司机API**
- ✅ GET /api/warehouses/drivers/recommend - 获取推荐司机列表（基础版）
- ✅ GET /api/warehouses/drivers/recommend/details - 获取推荐司机详情列表
- ✅ 推荐算法：距离40% + 任务数30% + 在线状态20% + 评分10%

**4. 拒单API增强**
- ✅ POST /api/orders/{orderId}/reject - 仓库拒单
- ✅ 支持拒单原因和库存不足明细记录

**5. 订单派单API**
- ✅ POST /api/orders/{orderId}/dispatch - 仓库派单（已有）

**6. 空桶入库API**
- ✅ GET /api/warehouses/bucket-inbound - 获取入库列表
- ✅ POST /api/warehouses/bucket-inbound - 创建入库单
- ✅ POST /api/warehouses/bucket-inbound/{id}/confirm - 确认入库
- ✅ POST /api/warehouses/bucket-inbound/{id}/reject - 拒绝入库

**7. 空桶出库API**
- ✅ GET /api/warehouses/bucket-outbound - 获取出库列表
- ✅ POST /api/warehouses/bucket-outbound - 创建出库单
- ✅ POST /api/warehouses/bucket-outbound/{id}/confirm - 确认出库
- ✅ POST /api/warehouses/bucket-outbound/{id}/reject - 拒绝出库

**8. 回仓列表API**
- ✅ GET /api/warehouses/returns - 获取司机回仓申请列表（已有）

### 新增文件清单

#### 前端文件
- `src/views/warehouse/WarehousePrepareList.vue` - 备货中列表
- `src/views/warehouse/WarehouseDispatchSelect.vue` - 派单司机选择
- `src/views/warehouse/WarehouseOrderReject.vue` - 拒单详情
- `src/views/warehouse/WarehouseBucketInbound.vue` - 空桶入库
- `src/views/warehouse/WarehouseBucketOutbound.vue` - 空桶出库
- `src/views/warehouse/WarehouseReturnList.vue` - 回仓列表

#### 后端文件
- `database/bucket_inventory_module.sql` - 空桶出入库表结构
- `module/bucket/entity/BucketInbound.java` - 空桶入库实体
- `module/bucket/entity/BucketOutbound.java` - 空桶出库实体
- `module/bucket/controller/BucketInboundController.java` - 入库控制器
- `module/bucket/controller/BucketOutboundController.java` - 出库控制器
- `module/bucket/service/BucketInboundService.java` - 入库服务
- `module/bucket/service/BucketOutboundService.java` - 出库服务
- `module/bucket/mapper/BucketInboundMapper.java` - 入库Mapper
- `module/bucket/mapper/BucketOutboundMapper.java` - 出库Mapper
- `module/bucket/dto/BucketInboundDTO.java` - 入库DTO
- `module/bucket/dto/BucketOutboundDTO.java` - 出库DTO
- `module/bucket/dto/CreateBucketInboundRequest.java` - 创建入库请求
- `module/bucket/dto/CreateBucketOutboundRequest.java` - 创建出库请求
- `module/bucket/dto/ConfirmBucketInboundRequest.java` - 确认入库请求
- `module/bucket/dto/ConfirmBucketOutboundRequest.java` - 确认出库请求
- `module/warehouse/dto/PreparingOrderDTO.java` - 备货订单DTO
- `module/warehouse/dto/RecommendedDriverDTO.java` - 推荐司机DTO
- `module/order/dto/RejectOrderRequest.java` - 拒单请求

### 数据库脚本

创建了 `database/bucket_inventory_module.sql`，包含：
- `bucket_inbound` 表 - 空桶入库表
- `bucket_outbound` 表 - 空桶出库表
- 完整的字段定义和索引

### 设计风格

所有页面严格遵循以下设计规范：
- **颜色系统**：主色 #1890FF, 成功 #52C41A, 警告 #FAAD14, 错误 #FF4D4F
- **卡片圆角**：rounded-2xl/rounded-3xl
- **按钮圆角**：rounded-xl/rounded-lg
- **字体**：'PingFang SC', 'Microsoft YaHei', sans-serif

### 技术实现
- Vue 3 Composition API（`<script setup>` 语法）
- TypeScript 类型定义
- Iconify 图标库
- Tailwind CSS 响应式样式
- 完整的错误处理和用户提示
- 加载状态指示器

### 使用说明

1. 在数据库中执行 SQL 脚本创建表：
```powershell
psql -h 192.168.31.251 -p 5432 -U wateroms -d wateroms -f "c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-java\database\bucket_inventory_module.sql"
```

2. 启动后端服务

3. 启动前端开发服务器：
```bash
npm run dev
```

4. 使用仓库管理员账号登录系统

5. 访问仓库端页面：
- 首页：`/warehouse/dashboard`
- 订单管理：`/warehouse/orders`
- 备货中：`/warehouse/prepare-list`
- 派单选择：`/warehouse/dispatch-select/:id`
- 拒单处理：`/warehouse/orders/:id/reject`
- 回仓核对：`/warehouse/return-check`
- 回仓列表：`/warehouse/return-list`
- 售后处理：`/warehouse/after-sales`
- 库存管理：`/warehouse/inventory`
- 空桶入库：`/warehouse/bucket-inbound`
- 空桶出库：`/warehouse/bucket-outbound`
- 入库管理：`/warehouse/inbound`
- 出库管理：`/warehouse/outbound`
- 司机管理：`/warehouse/drivers`
- 个人设置：`/warehouse/settings`

### TypeScript编译错误修复 (2026-04-24)

在完成仓库端功能开发后，执行 `npm run lint` 发现 48 个 TypeScript 编译错误，已全部修复。

#### 修复的问题类型

**1. 类型不匹配问题**
- API 返回的 DTO 类型与前端定义不一致
- 属性名称不匹配（如 `afterSalesNo` -> `ticketNo`）
- 缺少必需的属性或包含多余的属性

**2. 未使用的变量和导入**
- 函数参数声明但未使用（如 `handlePrint(item)` 中的 `item`）
- 导入但未使用的模块（如 `computed`、`useRouter`）
- 未使用的函数定义

**3. 空值检查缺失**
- 对象可能为 null/undefined
- 数组项可能为 null

**4. 属性类型不匹配**
- 属性名称拼写错误或不一致
- 接口定义与实际使用场景不匹配

#### 修复的文件清单

| 文件 | 修复数量 | 主要问题 |
|------|---------|---------|
| WarehouseAfterSales.vue | 2 | 类型不匹配、缺少action字段 |
| WarehouseAfterSalesDetail.vue | 11 | API响应属性不存在 |
| WarehouseBucketInbound.vue | 1 | 未使用参数 |
| WarehouseBucketOutbound.vue | 1 | 未使用参数 |
| WarehouseDashboard.vue | 2 | 缺少属性、未使用导入 |
| WarehouseDispatchSelect.vue | 3 | 未使用参数、属性不存在 |
| WarehouseDrivers.vue | 1 | 缺少可选属性 |
| WarehouseInbound.vue | 1 | 缺少details属性 |
| WarehouseOrderDetail.vue | 2 | 类型导入、未使用变量 |
| WarehouseOrders.vue | 5 | 类型不匹配、空值检查 |
| WarehouseOutbound.vue | 2 | 未使用函数、缺少属性 |
| WarehousePrepareList.vue | 1 | 未使用参数 |
| WarehouseReturnCheckDetail.vue | 9 | API响应属性不存在 |
| WarehouseReturnList.vue | 3 | 未使用导入和函数 |
| WarehouseSettings.vue | 4 | API方法不存在 |
| **总计** | **48** | |

#### 修复策略

1. **API 类型对齐**
   - 确保前端接口定义与后端 DTO 完全一致
   - 使用 TypeScript 可选属性 `?` 处理可能不存在的字段
   - 必要时添加类型断言或类型守卫

2. **清理未使用代码**
   - 移除未使用的导入（`computed`, `useRouter`等）
   - 将未使用的函数参数重命名为 `_param` 格式
   - 删除完全未使用的函数（如 `getTypeText`）

3. **增强空值检查**
   - 添加可选链操作符 `?.` 
   - 使用 nullish coalescing `??` 提供默认值
   - 添加明确的类型守卫

4. **接口定义优化**
   - 将硬编码的接口改为使用统一的 DTO 类型
   - 确保接口定义与 API 响应格式一致
   - 添加必要的可选属性

#### 验证结果

修复后运行 `npm run lint` 通过，无任何 TypeScript 编译错误。

#### 经验教训

1. **前后端类型同步**
   - 在开发过程中应保持前后端类型定义同步
   - 建议使用 Swagger/OpenAPI 自动生成前端类型
   - 或使用 TypeScript 共享包管理类型定义

2. **类型检查应尽早执行**
   - 在开发过程中定期运行 `npm run lint`
   - 避免累积大量类型错误
   - 严格的 TypeScript 配置有助于及早发现问题

3. **API 响应处理**
   - 始终假设 API 响应可能包含额外字段或缺少某些字段
   - 使用可选链和空值合并操作符提高代码健壮性
   - 为可能为 null 的值提供合理的默认值

4. **代码清理**
   - 添加新功能时同步清理未使用的代码
   - 使用 TypeScript 严格模式检测未使用的变量
   - 保持代码简洁，避免技术债务累积

## 水站老板端功能完善 (2026-04-24)

### 概述

对水站老板端进行了全面检查，对比开发文档（`水厂订货管理系统.md`）和原型文件（`origin/`），发现并实现了多个缺失的功能。

### 检查结果汇总

#### 功能模块完成度

| 模块 | 完成度 | 说明 |
|------|--------|------|
| 首页仪表盘 | 90% | 已实现数据统计、快捷功能、商品列表 |
| 订货流程 | 85% | 已实现下单页面、购物车、订单确认 |
| 订单管理 | 95% | 已实现列表、详情、修改、取消 |
| 对账单 | 80% | 需完善后端API对接 |
| 空桶往来 | 85% | 需完善后端API对接 |
| 账户充值 | 90% | 已实现充值页面 |
| 售后管理 | 80% | 已实现前后端对接 |
| 收货确认 | 85% | 已实现验证码和扫码确认 |
| 水票管理 | 75% | 已实现前端页面，待后端API对接 |

### 完成的工作

#### 前端页面实现

**1. 创建下单确认页面 (OwnerCreateOrder.vue)**
- ✅ 收货信息卡片（可编辑地址）
- ✅ 支付方式选择（月结/预存金/信用额度）
- ✅ 商品清单（数量调整、删除、添加商品弹窗）
- ✅ 空桶回收信息展示
- ✅ 费用明细计算
- ✅ 账户信息提示（额度检查）
- ✅ 欠桶预警提示
- ✅ 订单备注输入
- ✅ 底部操作栏（库存检查、提交订单）
- ✅ 确认下单弹窗

**路由配置**:
- 路径: `/station/create-order`
- 权限角色: `STATION_OWNER`

**页面跳转来源**:
- `OwnerDashboard.vue` - 快捷功能"一键下单"
- `OwnerOrders.vue` - "新建订单"按钮
- `OwnerOrderDetail.vue` - "再来一单"按钮

**2. 完善充值页面 (OwnerRecharge.vue)**
- ✅ 账户信息卡片（渐变蓝色背景）
- ✅ 充值金额选择（预设5档 + 自定义输入）
- ✅ 优惠信息提示（绿色渐变背景，满赠规则）
- ✅ 充值明细（充值金额、赠送金额、实际支付）
- ✅ 支付方式选择（微信支付/银行卡）
- ✅ 服务协议勾选
- ✅ 底部固定支付按钮
- ✅ 支付成功弹窗

**路由配置**:
- 路径: `/station/recharge`
- 权限角色: `STATION_OWNER`

**页面跳转来源**:
- `OwnerDashboard.vue` - 充值快捷入口
- `OwnerStatements.vue` - 充值链接

**3. 创建售后管理页面 (OwnerAfterSales.vue)**
- ✅ 售后申请功能
  - 关联订单选择（下拉选择）
  - 售后类型（补货/退款/退货）
  - 商品选择（从订单中选择）
  - 数量填写、原因说明
  - 图片上传（最多3张）
- ✅ 售后列表
  - Tab切换（全部/待处理/处理中/已完成/已拒绝）
  - 列表项显示（售后单号、类型、商品、状态、时间）
  - 分页功能
- ✅ 售后详情弹窗
  - 售后信息卡片
  - 关联订单信息（可点击跳转）
  - 商品明细、图片附件、处理结果

**路由配置**:
- 路径: `/station/after-sales`
- 权限角色: `STATION_OWNER`

**4. 创建收货确认页面 (OwnerReceiveConfirm.vue)**
- ✅ 订单信息展示（订单号、司机信息、商品清单）
- ✅ 验证码确认（6位验证码输入、60秒倒计时）
- ✅ 扫码确认（相机扫码功能）
- ✅ 联系司机功能
- ✅ 确认成功/失败弹窗
- ✅ 加载状态和错误处理

**路由配置**:
- 路径: `/station/receive-confirm/:orderId`
- 权限角色: `STATION_OWNER`

**5. 创建水票管理页面 (OwnerTickets.vue)**
- ✅ 水票概览卡片（渐变紫色背景）
  - 水票总数、可用数量、已使用数量
- ✅ 水票持有明细列表
  - 水票名称、面值、购买日期
  - 已使用/剩余数量、状态标签
- ✅ 使用记录
  - Tab切换（全部/使用中/已用完）
  - 时间筛选（近一周/一月/三月）
  - 分页功能
- ✅ 购买水票弹窗
  - 水票类型选择、数量调整
  - 价格计算、支付方式
  - 购买成功提示

**路由配置**:
- 路径: `/station/tickets`
- 权限角色: `STATION_OWNER`

#### 后端API实现

**1. 订单API增强**
- ✅ `POST /api/orders` - 创建订单
  - 验证水站账户和欠桶数量
  - 检查仓库库存
  - 获取水站专属价格
  - 验证账户余额/信用额度
  - 创建订单并发送通知

- ✅ `GET /api/orders/{orderId}` - 获取订单详情
- ✅ `PUT /api/orders/{orderId}` - 修改订单（所有字段必填）
- ✅ `PUT /api/orders/{orderId}/optional` - 修改订单（可选字段）
- ✅ `POST /api/orders/{orderId}/cancel` - 取消订单

**2. 售后API完整实现**
- ✅ `GET /api/after-sales` - 获取售后列表（水站端）
- ✅ `GET /api/after-sales/{id}` - 获取售后详情（水站端）
- ✅ `POST /api/after-sales` - 创建售后申请（水站端）
- ✅ `POST /api/after-sales/{id}/cancel` - 取消售后申请（水站端）
- ✅ `GET /api/after-sales/warehouse` - 获取售后列表（仓库端）
- ✅ `POST /api/after-sales/{id}/process` - 处理售后（仓库端）

**3. 收货确认API**
- ✅ `POST /api/stations/order/{orderId}/confirm` - 扫码确认收货
- ✅ `POST /api/stations/order/{orderId}/verify-code` - 验证码确认收货

**新增文件清单**

#### 前端文件
- `src/views/owner/OwnerCreateOrder.vue` - 下单确认页面
- `src/views/owner/OwnerRecharge.vue` - 充值页面
- `src/views/owner/OwnerAfterSales.vue` - 售后管理页面
- `src/views/owner/OwnerReceiveConfirm.vue` - 收货确认页面
- `src/views/owner/OwnerTickets.vue` - 水票管理页面

#### 后端文件
- `module/order/controller/OrderController.java` - 订单控制器增强
- `module/order/service/OrderService.java` - 订单服务增强
- `module/order/dto/UpdateOrderRequest.java` - 订单修改请求DTO
- `module/aftersales/controller/AfterSalesController.java` - 售后控制器
- `module/aftersales/service/AfterSalesService.java` - 售后服务
- `module/aftersales/entity/AfterSales.java` - 售后实体
- `module/aftersales/entity/AfterSalesItem.java` - 售后商品实体
- `module/aftersales/entity/AfterSalesImage.java` - 售后图片实体
- `module/aftersales/mapper/AfterSalesItemMapper.java` - 售后商品Mapper
- `module/aftersales/mapper/AfterSalesImageMapper.java` - 售后图片Mapper
- `module/aftersales/dto/AfterSalesDTO.java` - 售后列表DTO
- `module/aftersales/dto/AfterSalesDetailDTO.java` - 售后详情DTO
- `module/aftersales/dto/AfterSalesItemDTO.java` - 售后商品DTO
- `module/aftersales/dto/CreateAfterSalesRequestV2.java` - 创建售后请求
- `module/aftersales/dto/CreateAfterSalesResponse.java` - 创建售后响应

#### 数据库脚本
- `database/after_sales_module.sql` - 售后管理表结构
  - `after_sales` - 售后主表
  - `after_sales_item` - 售后商品明细表
  - `after_sales_image` - 售后图片表

### 页面访问路径

水站老板端页面访问路径：

| 页面 | 路径 | 说明 |
|------|------|------|
| 首页仪表盘 | `/station/dashboard` | 快捷功能入口 |
| 订单列表 | `/station/orders` | 查看和管理订单 |
| 订单详情 | `/station/orders/:id` | 订单详细信息 |
| 下单确认 | `/station/create-order` | 创建新订单 |
| 对账单 | `/station/statements` | 财务对账 |
| 空桶往来 | `/station/buckets` | 空桶管理 |
| 账户充值 | `/station/recharge` | 充值预存金 |
| 售后管理 | `/station/after-sales` | 售后申请和查看 |
| 收货确认 | `/station/receive-confirm/:orderId` | 确认收货 |
| 水票管理 | `/station/tickets` | 水票购买和使用 |
| 客户管理 | `/station/customers` | 客户信息管理 |
| 个人设置 | `/station/settings` | 账户设置 |

### 设计规范

所有页面严格遵循以下设计规范：

- **颜色系统**：
  - 主色: #1890FF (蓝色)
  - 成功: #52C41A (绿色)
  - 警告: #FAAD14 (橙色)
  - 错误: #FF4D4F (红色)
  - 紫色: #8B5CF6 (水票使用)

- **卡片圆角**: rounded-2xl / rounded-3xl
- **按钮圆角**: rounded-xl / rounded-lg
- **字体**: 'PingFang SC', 'Microsoft YaHei', sans-serif
- **图标**: Iconify 图标库

### 数据库部署

执行以下SQL脚本创建售后管理相关表：

```powershell
psql -h 192.168.31.251 -p 5432 -U wateroms -d wateroms -f "c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-java\database\after_sales_module.sql"
```

### 编译验证

所有代码已通过编译验证：
- 前端: `npm run build` ✅
- 后端: `mvn clean compile -DskipTests` ✅

### 经验教训

1. **功能完整性检查**
   - 在开发新功能前，应先对比PRD文档和原型文件
   - 使用检查清单确保所有功能点都被覆盖
   - 前后端并行开发时，需保持接口定义同步

2. **页面跳转链路**
   - 确保所有跳转入口都有对应的目标页面
   - 在OwnerOrders.vue和OwnerDashboard.vue中已添加跳转逻辑
   - 路由配置需与跳转路径保持一致

3. **API接口完整性**
   - 前端页面依赖后端API，需确保接口已实现
   - 使用Mock数据降级方案，确保页面开发不阻塞
   - 添加完整的错误处理和用户提示

4. **代码规范一致性**
   - 新页面严格遵循现有代码风格
   - 使用统一的Tailwind CSS类名和颜色系统
   - Vue 3 Composition API（`<script setup>` 语法）

## 联系方式
如有问题，请查阅 PRD 文档或联系开发团队。
