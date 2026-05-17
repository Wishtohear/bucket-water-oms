# 用户订水平台

基于 UniApp 的用户端订水平台，支持微信小程序和 H5。

## 技术栈

- UniApp + Vue 3 + TypeScript
- Pinia 状态管理
- uView UI

## 开发说明

### 安装依赖

```bash
npm install
```

### 运行项目

```bash
# H5 开发模式
npm run dev:h5

# 微信小程序开发模式
npm run dev:mp-weixin
```

### 构建项目

```bash
# 构建 H5
npm run build:h5

# 构建微信小程序
npm run build:mp-weixin
```

## 目录结构

```
src/
├── pages/              # 页面
├── components/         # 组件
├── stores/            # Pinia 状态管理
├── services/          # API 服务
├── utils/             # 工具函数
├── types/             # TypeScript 类型定义
└── styles/            # 全局样式
```

## 功能模块

1. 认证模块 - 登录、注册、找回密码
2. 水站模块 - 水站列表、详情、搜索
3. 商品模块 - 商品列表、详情
4. 购物车模块 - 购物车管理
5. 订单模块 - 下单、订单管理
6. 支付模块 - 微信支付
7. 地址管理 - 收货地址管理
8. 用户中心 - 个人信息、设置

## 注意事项

1. 微信小程序需要在 manifest.json 中配置 AppID
2. 使用前请配置后端 API 地址
3. 微信支付需要在微信公众平台申请
