***

##

# 水厂订货管理系统 - 数据库设计文档

## 一、 ER图（Mermaid语法）

```mermaid
erDiagram
    FACTORY ||--o{ USER : "管辖"
    FACTORY ||--o{ WAREHOUSE : "拥有"
    FACTORY ||--o{ DRIVER : "拥有"
    FACTORY ||--o{ STATION : "拥有"
    FACTORY ||--o{ PRODUCT : "拥有"

    FACTORY {
        uuid id PK
        string name
        string code UK
        string contact
        string phone
        text address
        string status
        timestamp created_at
        timestamp updated_at
    }

    USER ||--o{ ORDER : "下单"
    USER ||--o| WAREHOUSE : "管理"
    USER ||--o{ DRIVER_RETURN : "回仓"
    USER ||--o{ AFTER_SALES : "发起"

    USER {
        uuid id PK
        string phone UK
        string password
        string name
        string role
        uuid factory_id FK "nullable"
        uuid warehouse_id FK "nullable"
        uuid station_id FK "nullable"
        uuid driver_id FK "nullable"
        string status
        timestamp created_at
        timestamp updated_at
    }

    STATION ||--o{ USER : "拥有"
    STATION ||--o| STATION_ACCOUNT : "账户"
    STATION ||--o{ ORDER : "下单"
    STATION ||--o{ BUCKET_TRANSACTION : "流水"
    STATION ||--o{ MONTHLY_STATEMENT : "对账"

    STATION {
        uuid id PK
        uuid factory_id FK
        string name
        string contact
        string phone
        text address
        string status
        timestamp created_at
    }

    STATION_ACCOUNT {
        uuid id PK
        uuid station_id FK UK
        decimal deposit_balance
        decimal credit_limit
        decimal credit_used
        decimal bucket_deposit_per_unit
        int owed_bucket_num
        int owed_threshold
        timestamp updated_at
    }

    WAREHOUSE ||--o{ ORDER : "接单"
    WAREHOUSE ||--o{ DRIVER_RETURN : "核对"
    WAREHOUSE ||--o{ PRODUCT_INVENTORY : "库存"
    WAREHOUSE ||--o{ USER : "管理员"

    WAREHOUSE {
        uuid id PK
        uuid factory_id FK
        string name
        text address
        string contact_phone
        decimal lat
        decimal lng
        string status
        timestamp created_at
    }

    DRIVER ||--o{ ORDER : "配送"
    DRIVER ||--o{ DRIVER_RETURN : "回仓"
    DRIVER ||--o{ USER : "账号"

    DRIVER {
        uuid id PK
        uuid factory_id FK
        string name
        string phone
        string region
        string status
        timestamp created_at
    }

    ORDER ||--o{ ORDER_ITEM : "明细"
    ORDER ||--o{ BUCKET_TRANSACTION : "关联"
    ORDER ||--o{ AFTER_SALES : "售后"
    ORDER }o--|| WAREHOUSE : "接单"
    ORDER }o--|| STATION : "下单"
    ORDER }o--|| DRIVER : "派单"

    ORDER {
        uuid id PK
        string order_no UK
        uuid station_id FK
        uuid warehouse_id FK
        uuid driver_id FK "nullable"
        string status
        decimal total_amount
        string payment_type
        text delivery_address
        string contact_name
        string contact_phone
        string reject_reason "nullable"
        timestamp created_at
        timestamp reviewed_at "nullable"
        timestamp dispatched_at "nullable"
        timestamp delivered_at "nullable"
    }

    ORDER_ITEM {
        uuid id PK
        uuid order_id FK
        uuid product_id FK
        int quantity
        int actual_qty
        decimal unit_price
        decimal subtotal
    }

    PRODUCT ||--o{ ORDER_ITEM : "订购"
    PRODUCT ||--o{ PRODUCT_INVENTORY : "库存"
    PRODUCT ||--o{ AFTER_SALES : "售后"

    PRODUCT {
        uuid id PK
        uuid factory_id FK
        string name
        string category
        string specification
        decimal price
        string status
        timestamp created_at
    }

    PRODUCT_INVENTORY {
        uuid id PK
        uuid warehouse_id FK
        uuid product_id FK
        int quantity
        timestamp updated_at
    }

    BUCKET_TRANSACTION {
        uuid id PK
        uuid station_id FK
        uuid order_id FK "nullable"
        uuid driver_id FK "nullable"
        uuid warehouse_id FK "nullable"
        string type
        int quantity
        int balance
        string remark "nullable"
        timestamp created_at
    }

    DRIVER_RETURN {
        uuid id PK
        uuid driver_id FK
        uuid warehouse_id FK
        string status
        int bucket_returned
        int actual_bucket_qty "nullable"
        int difference "nullable"
        text difference_reason "nullable"
        json replenishment "nullable"
        timestamp created_at
        timestamp checked_at "nullable"
    }

    MONTHLY_STATEMENT {
        uuid id PK
        uuid station_id FK
        string year_month UK
        date start_date
        date end_date
        decimal opening_balance
        decimal total_amount
        decimal payment_received
        decimal closing_balance
        string status
        timestamp generated_at
        timestamp confirmed_at "nullable"
    }

    AFTER_SALES {
        uuid id PK
        uuid order_id FK
        uuid station_id FK
        uuid product_id FK "nullable"
        string type
        text reason
        json photos "nullable"
        string request_type
        int requested_quantity
        string status
        uuid new_order_id FK "nullable"
        text reject_reason "nullable"
        timestamp created_at
        timestamp processed_at "nullable"
    }
```

## 二、 核心表结构说明

### 2.1 用户表 (user)

存储所有角色账号：水厂管理员、仓库管理员、司机、水站老板、店员

- 通过 `role` 字段区分权限
- 司机和仓库管理员关联 `warehouse_id`
- 水站账号关联 `station_id`

| 字段            | 类型        | 说明                                      |
| ------------- | --------- | --------------------------------------- |
| id            | uuid      | 主键                                      |
| phone         | string    | 手机号（唯一）                                 |
| password      | string    | 密码（加密存储）                                |
| name          | string    | 姓名/名称                                   |
| role          | string    | 角色：admin/warehouse/driver/station/staff |
| warehouse\_id | uuid      | 仓库ID（仓库管理员/司机关联）                        |
| station\_id   | uuid      | 水站ID（水站老板/店员关联）                         |
| status        | string    | 状态：active/inactive                      |
| created\_at   | timestamp | 创建时间                                    |
| updated\_at   | timestamp | 更新时间                                    |

### 2.2 水站表 (station)

| 字段          | 类型        | 说明                 |
| ----------- | --------- | ------------------ |
| id          | uuid      | 主键                 |
| name        | string    | 水站名称               |
| contact     | string    | 联系人                |
| phone       | string    | 联系电话               |
| address     | text      | 地址                 |
| status      | string    | 状态：active/inactive |
| created\_at | timestamp | 创建时间               |

### 2.3 水站账户表 (station\_account)

独立表存储水站的财务和空桶押金信息

- 支持预存金、信用额度、账期三种支付方式
- 空桶押金按水站独立设置 (`bucket_deposit_per_unit`)

| 字段                         | 类型        | 说明       |
| -------------------------- | --------- | -------- |
| id                         | uuid      | 主键       |
| station\_id                | uuid      | 水站ID（唯一） |
| deposit\_balance           | decimal   | 预存金余额    |
| credit\_limit              | decimal   | 信用额度     |
| credit\_used               | decimal   | 已用信用额度   |
| bucket\_deposit\_per\_unit | decimal   | 每桶押金金额   |
| owed\_bucket\_num          | int       | 当前欠桶数量   |
| owed\_threshold            | int       | 欠桶阈值     |
| updated\_at                | timestamp | 更新时间     |

### 2.4 仓库表 (warehouse)

| 字段             | 类型        | 说明                 |
| -------------- | --------- | ------------------ |
| id             | uuid      | 主键                 |
| name           | string    | 仓库名称               |
| address        | text      | 地址                 |
| contact\_phone | string    | 联系电话               |
| lat            | decimal   | 纬度                 |
| lng            | decimal   | 经度                 |
| status         | string    | 状态：active/inactive |
| created\_at    | timestamp | 创建时间               |

### 2.5 司机表 (driver)

| 字段          | 类型        | 说明                 |
| ----------- | --------- | ------------------ |
| id          | uuid      | 主键                 |
| name        | string    | 姓名                 |
| phone       | string    | 联系电话               |
| region      | string    | 负责区域               |
| status      | string    | 状态：active/inactive |
| created\_at | timestamp | 创建时间               |

### 2.6 订单表 (order)

核心业务流程表，记录从下单到完成的完整状态流转

- 支持拒单 (`status=rejected`) 及原因记录
- 时间戳记录各节点：创建→接单→派单→完成

| 字段                | 类型        | 说明                                                                             |
| ----------------- | --------- | ------------------------------------------------------------------------------ |
| id                | uuid      | 主键                                                                             |
| order\_no         | string    | 订单号（唯一）                                                                        |
| station\_id       | uuid      | 水站ID                                                                           |
| warehouse\_id     | uuid      | 接单仓库ID                                                                         |
| driver\_id        | uuid      | 派单司机ID（可为空）                                                                    |
| status            | string    | 状态：pending\_review/reviewed/dispatched/delivering/completed/cancelled/rejected |
| total\_amount     | decimal   | 订单总金额                                                                          |
| payment\_type     | string    | 支付方式：prepaid/monthly/credit                                                    |
| delivery\_address | text      | 配送地址                                                                           |
| contact\_name     | string    | 联系人                                                                            |
| contact\_phone    | string    | 联系电话                                                                           |
| reject\_reason    | string    | 拒单原因（可为空）                                                                      |
| created\_at       | timestamp | 创建时间                                                                           |
| reviewed\_at      | timestamp | 审查时间                                                                           |
| dispatched\_at    | timestamp | 派单时间                                                                           |
| delivered\_at     | timestamp | 完成时间                                                                           |

### 2.7 订单商品明细表 (order\_item)

- 记录订购数量和实际配送数量 (`actual_qty`)
- 存储水站独立定价（下单时的实际价格）

| 字段          | 类型      | 说明         |
| ----------- | ------- | ---------- |
| id          | uuid    | 主键         |
| order\_id   | uuid    | 订单ID       |
| product\_id | uuid    | 商品ID       |
| quantity    | int     | 订购数量       |
| actual\_qty | int     | 实际配送数量     |
| unit\_price | decimal | 单价（水站独立定价） |
| subtotal    | decimal | 小计金额       |

### 2.8 商品表 (product)

| 字段            | 类型        | 说明                                        |
| ------------- | --------- | ----------------------------------------- |
| id            | uuid      | 主键                                        |
| name          | string    | 商品名称                                      |
| category      | string    | 分类：bucket\_water/bottled\_water/equipment |
| specification | string    | 规格                                        |
| price         | decimal   | 默认单价                                      |
| status        | string    | 状态：active/inactive                        |
| created\_at   | timestamp | 创建时间                                      |

### 2.9 仓库库存表 (product\_inventory)

| 字段            | 类型        | 说明   |
| ------------- | --------- | ---- |
| id            | uuid      | 主键   |
| warehouse\_id | uuid      | 仓库ID |
| product\_id   | uuid      | 商品ID |
| quantity      | int       | 库存数量 |
| updated\_at   | timestamp | 更新时间 |

### 2.10 空桶流水表 (bucket\_transaction)

记录空桶全生命周期：押金收取→回桶→欠桶→补缴→差异赔偿

- 每笔交易记录变动后的余额 (`balance`)
- 关联订单、司机、仓库，形成完整追溯链

| 字段            | 类型        | 说明                                      |
| ------------- | --------- | --------------------------------------- |
| id            | uuid      | 主键                                      |
| station\_id   | uuid      | 水站ID                                    |
| order\_id     | uuid      | 关联订单（可为空）                               |
| driver\_id    | uuid      | 司机ID（可为空）                               |
| warehouse\_id | uuid      | 仓库ID（可为空）                               |
| type          | string    | 类型：deposit/return/owed/pay/compensation |
| quantity      | int       | 数量（正数增加，负数减少）                           |
| balance       | int       | 变动后欠桶余额                                 |
| remark        | string    | 备注                                      |
| created\_at   | timestamp | 创建时间                                    |

### 2.11 司机回仓表 (driver\_return)

记录司机中途回仓或配送结束回仓

- 仓库核对后记录差异 (`difference`) 及原因
- 差异由司机承担，生成赔偿记录

| 字段                  | 类型        | 说明                 |
| ------------------- | --------- | ------------------ |
| id                  | uuid      | 主键                 |
| driver\_id          | uuid      | 司机ID               |
| warehouse\_id       | uuid      | 仓库ID               |
| status              | string    | 状态：pending/checked |
| bucket\_returned    | int       | 司机上报交回数量           |
| actual\_bucket\_qty | int       | 仓库实收数量             |
| difference          | int       | 差异数量               |
| difference\_reason  | text      | 差异原因               |
| replenishment       | json      | 补货申请               |
| created\_at         | timestamp | 创建时间               |
| checked\_at         | timestamp | 核对时间               |

### 2.12 对账单表 (monthly\_statement)

- 每月固定日期自动生成
- 期初余额+本月进货-本月回款=期末余额
- 支持水站确认或标记争议

| 字段                | 类型        | 说明                              |
| ----------------- | --------- | ------------------------------- |
| id                | uuid      | 主键                              |
| station\_id       | uuid      | 水站ID                            |
| year\_month       | string    | 账单月份（如2026-04，唯一）               |
| start\_date       | date      | 账期开始日期                          |
| end\_date         | date      | 账期结束日期                          |
| opening\_balance  | decimal   | 期初余额                            |
| total\_amount     | decimal   | 本月进货总额                          |
| payment\_received | decimal   | 本月回款金额                          |
| closing\_balance  | decimal   | 期末余额                            |
| status            | string    | 状态：generated/confirmed/disputed |
| generated\_at     | timestamp | 生成时间                            |
| confirmed\_at     | timestamp | 确认时间                            |

### 2.13 售后表 (after\_sales)

- 水站发起或仓库发起（缺货）
- 同意售后生成新订单 (`new_order_id`)
- 拒绝需填写原因

| 字段                  | 类型        | 说明                                        |
| ------------------- | --------- | ----------------------------------------- |
| id                  | uuid      | 主键                                        |
| order\_id           | uuid      | 原订单ID                                     |
| station\_id         | uuid      | 水站ID                                      |
| product\_id         | uuid      | 商品ID（可为空）                                 |
| type                | string    | 类型：quality\_issue/wrong\_product/shortage |
| reason              | text      | 原因                                        |
| photos              | json      | 图片                                        |
| request\_type       | string    | 请求类型：replenishment/refund                 |
| requested\_quantity | int       | 请求数量                                      |
| status              | string    | 状态：pending/approved/rejected              |
| new\_order\_id      | uuid      | 新订单ID（同意售后时生成）                            |
| reject\_reason      | text      | 拒绝原因                                      |
| created\_at         | timestamp | 创建时间                                      |
| processed\_at       | timestamp | 处理时间                                      |

## 三、 关键索引设计

| 表名                  | 索引字段                       | 索引类型   | 说明       |
| ------------------- | -------------------------- | ------ | -------- |
| user                | phone                      | UNIQUE | 手机号唯一    |
| user                | role, warehouse\_id        | INDEX  | 按角色和仓库查询 |
| user                | station\_id                | INDEX  | 水站账号查询   |
| station             | status                     | INDEX  | 状态筛选     |
| station\_account    | station\_id                | UNIQUE | 水站账户唯一   |
| warehouse           | status                     | INDEX  | 状态筛选     |
| warehouse           | lat, lng                   | INDEX  | 地理位置查询   |
| driver              | region                     | INDEX  | 区域查询     |
| driver              | status                     | INDEX  | 状态筛选     |
| order               | order\_no                  | UNIQUE | 订单号唯一    |
| order               | station\_id, created\_at   | INDEX  | 水站查订单    |
| order               | warehouse\_id, status      | INDEX  | 仓库查待处理   |
| order               | driver\_id, status         | INDEX  | 司机查任务    |
| order               | status, created\_at        | INDEX  | 状态+时间筛选  |
| order\_item         | order\_id                  | INDEX  | 订单查明细    |
| product             | category                   | INDEX  | 分类查询     |
| product             | status                     | INDEX  | 状态筛选     |
| product\_inventory  | warehouse\_id, product\_id | UNIQUE | 仓库商品唯一   |
| bucket\_transaction | station\_id, created\_at   | INDEX  | 水站查流水    |
| bucket\_transaction | order\_id                  | INDEX  | 订单查流水    |
| bucket\_transaction | driver\_id                 | INDEX  | 司机查流水    |
| driver\_return      | driver\_id, status         | INDEX  | 司机回仓查询   |
| driver\_return      | warehouse\_id, status      | INDEX  | 仓库核对查询   |
| monthly\_statement  | station\_id, year\_month   | UNIQUE | 每月唯一对账单  |
| monthly\_statement  | station\_id                | INDEX  | 水站对账单查询  |
| after\_sales        | order\_id                  | INDEX  | 订单查售后    |
| after\_sales        | station\_id, status        | INDEX  | 水站查售后    |
| after\_sales        | status, created\_at        | INDEX  | 状态+时间筛选  |

## 四、 数据库选型建议

### 4.1 主数据库

**推荐：MySQL 8.0 / PostgreSQL 14+**

- MySQL：成熟稳定，社区活跃，适合互联网业务
- PostgreSQL：功能丰富，支持GIS，适合地图相关业务

### 4.2 缓存层

**Redis**

- 会话存储（JWT Token）
- 库存热点数据缓存
- 订单状态缓存
- 限流控制

### 4.3 搜索引擎

**Elasticsearch**

- 订单全文搜索
- 报表统计聚合
- 日志分析

### 4.4 文件存储

**OSS / S3**

- 签收照片存储
- 售后图片存储
- 导出文件存储

### 4.5 地图数据

**PostGIS（PostgreSQL扩展）**

- 配送路线优化
- 仓库位置管理
- 距离计算

### 4.6 数据库架构建议

```sql
-- 主从复制架构
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Write DB   │────▶│  Read DB 1  │     │  Read DB 2  │
│  (Master)    │     │  (Replica)  │     │  (Replica)  │
└─────────────┘     └─────────────┘     └─────────────┘
       │
       ▼
┌─────────────┐
│    Redis    │
│   Cluster   │
└─────────────┘
```

## 五、 表关系总结

### 5.1 核心业务流

```
水站 (station) ──下单──▶ 订单 (order) ──接单──▶ 仓库 (warehouse)
                                    │
                                    ▼
                              派单给司机 ──▶ 司机 (driver) ──配送──▶ 完成
                                                     │
                                                     ▼
                                              空桶回收 ──▶ 空桶流水
```

### 5.2 财务流

```
水站账户 ──预存金/信用──▶ 订单扣款 ──▶ 月结对账 ──▶ 对账单
```

### 5.3 空桶流

```
订单配送 ──▶ 司机回收 ──▶ 司机回仓 ──▶ 仓库核对 ──▶ 差异处理
```

***

**文档版本**：v1.0

**生成时间**：2026-04-18

**作者**：MiniMax Agent
