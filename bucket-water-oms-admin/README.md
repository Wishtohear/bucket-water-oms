# 水厂订货管理系统 - 管理员后台

基于 Vue 3 + Vite + TypeScript + Tailwind CSS 构建的现代化水厂订货管理后台系统，提供完整的水站管理、销售政策、库存管理、财务管理等功能模块。

## 目录

- [快速开始](#快速开始)
- [项目结构](#项目结构)
- [功能模块](#功能模块)
- [设计规范](#设计规范)
- [后端对接](#后端对接)
- [开发规范](#开发规范)
- [技术栈](#技术栈)

## 快速开始

### 环境要求

- Node.js >= 16.0
- npm >= 8.0

### 安装依赖

```bash
npm install
```

### 启动开发服务器

```bash
npm run dev
```

访问 http://localhost:5173

### 生产构建

```bash
npm run build
```

### 类型检查

```bash
npm run lint
```

## 项目结构

```
bucket-water-oms-admin/
├── src/
│   ├── components/          # 公共组件
│   │   ├── Layout.vue       # 页面布局
│   │   ├── Sidebar.vue      # 侧边栏
│   │   └── Header.vue       # 顶部导航
│   ├── views/               # 页面视图
│   │   ├── Login.vue        # 登录页
│   │   ├── Dashboard.vue    # 数据概览
│   │   ├── Stations.vue     # 水站管理
│   │   ├── Warehouses.vue   # 仓库管理
│   │   ├── Policies.vue     # 销售政策
│   │   ├── Inventory.vue    # 库存管理
│   │   ├── Finance.vue      # 财务管理
│   │   ├── Reports.vue      # 报表统计
│   │   └── Settings.vue     # 系统配置
│   ├── router/              # 路由配置
│   ├── stores/              # 状态管理
│   ├── App.vue              # 根组件
│   ├── main.ts              # 入口文件
│   └── style.css            # 全局样式
├── public/                  # 静态资源
├── origin/                  # 原始设计原型
├── package.json             # 项目配置
├── vite.config.ts          # Vite 配置
├── tailwind.config.js      # Tailwind 配置
├── tsconfig.json           # TypeScript 配置
└── AGENTS.md               # 开发记录
```

## 功能模块

### 1. 登录认证

- 账号密码登录
- 记住登录状态
- 路由权限控制
- 错误提示

### 2. 数据概览（首页）

- 核心指标卡片（销售额、订单数、活跃水站、库存预警）
- 销售趋势图表
- 快捷操作入口
- 重要通知列表

### 3. 水站管理

- 水站列表展示
- 多条件搜索筛选
- 水站状态管理（正常运营/欠费停供/已注销）
- 分页功能
- 编辑/查看订单/配置政策

### 4. 仓库管理

- 仓库列表展示
- 搜索筛选功能
- 添加新仓库（弹窗表单）
- 编辑仓库信息
- 仓库详情查看
- 启用/停用仓库
- 仓库类型区分（总仓/分仓）
- 分页功能

### 5. 销售政策

- 政策模板管理
- 产品定价配置
- 政策类型区分（默认/VIP/促销）
- 添加/编辑/删除/复制政策
- 启用/停用政策
- 操作菜单

### 6. 库存管理

- 多仓库切换
- 库存实时监控
- 库存统计卡片
- 出入库记录明细
- 业务类型标签

### 7. 财务管理

- 财务数据概览
- 应收款明细管理
- 预存金余额管理
- 状态标签

### 8. 报表统计

- 月度销售趋势分析
- 产品销量构成分析
- 水站订货排行榜
- 销售明细日报

### 9. 系统配置

- 基本设置
- 对账设置
- 库存设置
- 通知开关设置

## 设计规范

### 色彩系统

- **主色**: #1890FF (蓝色)
- **成功**: #52C41A (绿色)
- **警告**: #FAAD14 (橙色)
- **错误**: #FF4D4F (红色)
- **背景**: #f0f2f5 (浅灰)

### 组件样式

- **卡片**: 白色背景，圆角 16-24px，浅阴影
- **按钮**: 圆角 8-12px，hover 效果
- **输入框**: 圆角 12px，聚焦时蓝色边框
- **表格**: 浅灰色表头，行 hover 效果

### 字体

- 字体族: `'PingFang SC', 'Microsoft YaHei', sans-serif`

## 后端对接

### 1. 配置 API 代理

编辑 `vite.config.ts`:

```typescript
server: {
  proxy: {
    '/api': {
      target: 'http://localhost:3000',
      changeOrigin: true
    }
  }
}
```

### 2. 创建 API 模块

在 `src/api/` 目录创建 API 文件：

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

### 3. 修改 Store

更新 `src/stores/` 中的数据获取逻辑，使用 Pinia 进行状态管理。

### 4. Mock 数据说明

当前所有页面使用静态 Mock 数据，可通过以下方式对接真实 API：

1. 创建 API 模块
2. 修改 Store 中的数据获取逻辑
3. 添加 TypeScript 类型定义

## 开发规范

### 命名规范

- **组件**: PascalCase (如: `StationList.vue`)
- **函数/变量**: camelCase (如: `fetchStations`)
- **常量**: UPPER_SNAKE_CASE (如: `API_BASE_URL`)

### 代码规范

- 使用 Vue 3 Composition API
- 使用 TypeScript 类型定义
- 使用 Tailwind CSS 工具类
- 组件单一职责原则

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

## 技术栈

- **Vue 3** - 渐进式 JavaScript 框架（Composition API）
- **Vite 5** - 新一代前端构建工具
- **TypeScript** - JavaScript 超集
- **Tailwind CSS** - 实用优先的 CSS 框架
- **Pinia** - Vue 状态管理
- **Vue Router 4** - Vue 官方路由
- **Iconify** - 图标库

## 开发记录

详细的开发记录和注意事项请查阅 [AGENTS.md](./AGENTS.md)

## 支持

如有问题或建议，请查阅：

- PRD 文档
- 开发记录 (AGENTS.md)
