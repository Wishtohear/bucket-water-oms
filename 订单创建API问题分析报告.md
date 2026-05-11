# 订单创建 API 500 错误问题分析报告

> 生成时间：2026-04-30
> 问题等级：P0 (阻塞)

---

## 1. 问题描述

### 症状
- 水站下单页面提交订单时，后端返回 500 Internal Server Error
- 前端无法创建新订单
- 阻塞核心业务流程

### 影响范围
- 水站老板端创建订单
- 所有需要创建订单的场景

---

## 2. 错误分析

### 2.1 前端请求格式

**前端发送的请求** (stationOwner.ts):
```typescript
{
  warehouseId: string
  items: { productId: string; quantity: number }[]
  remark?: string
}
```

**后端期望的请求** (CreateOrderRequest.java):
```java
@NotNull warehouseId
@NotEmpty @Valid items
@NotBlank deliveryAddress      // 前端未发送 ❌
@NotBlank contactName          // 前端未发送 ❌
@NotBlank contactPhone         // 前端未发送 ❌
paymentType (可选)
remark (可选)
```

### 2.2 缺失字段

| 字段 | 类型 | 验证 | 前端发送 | 问题 |
|------|------|------|----------|------|
| warehouseId | Long | @NotNull | ✅ | - |
| items | List | @NotEmpty | ✅ | - |
| deliveryAddress | String | @NotBlank | ❌ | **缺失** |
| contactName | String | @NotBlank | ❌ | **缺失** |
| contactPhone | String | @NotBlank | ❌ | **缺失** |

---

## 3. 根本原因

### 3.1 前后端字段不一致

1. **CreateOrderRequest 定义了 @NotBlank 验证**，要求 deliveryAddress、contactName、contactPhone 必填
2. **前端没有发送这些字段**，导致 Spring Validation 验证失败
3. **验证失败可能抛出 MethodArgumentNotValidException**，但被全局异常处理器捕获后返回 500

### 3.2 可能的代码问题

#### OrderItem 实体类
```java
@Data  // Lombok 会生成 getter/setter
@TableName("order_item")
public class OrderItem {
    // ... 手动定义了所有 getter/setter
}
```
- 同时使用 @Data 和手动 getter/setter 可能导致冲突

---

## 4. 修复方案

### 方案 A: 修改前端发送缺失字段 (推荐)

修改前端 `OwnerCreateOrder.vue` 和 `stationOwner.ts`，在创建订单时发送缺失的字段：

```typescript
// stationOwner.ts
createOrder(data: {
  warehouseId: string
  items: { productId: string; quantity: number }[]
  deliveryAddress: string   // 添加
  contactName: string     // 添加
  contactPhone: string    // 添加
  remark?: string
}): Promise<OrderVO> {
  return axios.post('/orders', data)
}
```

### 方案 B: 修改后端移除必填验证

如果这些字段确实不需要，可以移除 @NotBlank 验证：

```java
// CreateOrderRequest.java
// @NotBlank  // 改为可选
@Schema(description = "配送地址")
private String deliveryAddress;

// @NotBlank  // 改为可选
@Schema(description = "联系人")
private String contactName;

// @NotBlank  // 改为可选
@Schema(description = "联系电话")
private String contactPhone;
```

---

## 5. 修复步骤

### 步骤 1: 修改前端 stationOwner.ts

**文件**: `bucket-water-oms-admin/src/api/stationOwner.ts`

```typescript
// 修改 createOrder 方法签名
createOrder(data: {
  warehouseId: string
  items: { productId: string; quantity: number }[]
  deliveryAddress: string   // 新增
  contactName: string        // 新增
  contactPhone: string     // 新增
  remark?: string
}): Promise<OrderVO> {
  return axios.post('/orders', data)
}
```

### 步骤 2: 修改前端 OwnerCreateOrder.vue

**文件**: `bucket-water-oms-admin/src/views/owner/OwnerCreateOrder.vue`

确保在提交订单时包含以下字段：
- `deliveryAddress` - 从收货地址输入框获取
- `contactName` - 从联系人输入框获取
- `contactPhone` - 从联系电话输入框获取

### 步骤 3: 验证修复

1. 启动后端服务
2. 启动前端开发服务器
3. 使用水站老板账号登录
4. 进入下单页面
5. 填写商品、地址、联系人信息
6. 点击提交订单
7. 验证订单创建成功

---

## 6. 其他潜在问题

### 6.1 OrderItem 实体类

**文件**: `OrderItem.java`

**问题**: 同时使用 @Data 和手动 getter/setter

**建议**: 移除 @Data 注解或移除手动 getter/setter

```java
// 方案1: 移除 @Data
// @Data  // 注释掉
@TableName("order_item")
public class OrderItem {
    // 保留手动定义的 getter/setter
}

// 方案2: 移除手动 getter/setter
@Data
@TableName("order_item")
public class OrderItem {
    // 删除所有手动 getter/setter
}
```

### 6.2 缺少审计字段

**问题**: OrderItem 没有审计字段（create_time, update_time 等），但数据库表有这些列

**建议**: 
1. 让 OrderItem 继承 BaseEntity，或
2. 在实体类中添加这些字段并标记 `@TableField(exist = false)`

---

## 7. 测试用例

### TEST-ORDER-001-FIX: 订单创建修复验证

**前置条件**: 
- 水站老板账号已登录
- 存在可用的仓库和商品

**测试步骤**:
1. 进入下单页面
2. 选择仓库
3. 选择商品和数量
4. 填写配送地址
5. 填写联系人信息
6. 点击提交订单

**预期结果**:
- 订单创建成功
- 返回订单详情
- 页面跳转到订单列表或订单详情页

**实际结果**:
- 待验证

---

## 8. 教训总结

### 8.1 前后端字段必须同步

- **问题**: 后端 DTO 定义了必填字段，前端没有发送
- **后果**: 验证失败导致 500 错误
- **解决方案**: 
  1. 前后端使用相同的字段定义
  2. 使用 Swagger/OpenAPI 自动生成 API 契约
  3. 前端 TypeScript 接口与后端 DTO 保持一致

### 8.2 @NotBlank 验证的陷阱

- **问题**: @NotBlank 会拒绝空字符串和 null
- **建议**: 
  1. 如果字段确实可选，使用 @Schema(description = "...") 而不添加验证
  2. 如果字段必填，确保前端发送该字段
  3. 使用 @Validated 进行分组验证，区分创建和更新场景

### 8.3 代码审查要点

- **前后端接口一致性**: 确保前端发送的每个字段都在后端 DTO 中定义
- **验证注解一致性**: 必填字段在前端和后端都要验证
- **Lombok 与手动代码冲突**: 避免同时使用 @Data 和手动 getter/setter

---

**报告生成**: AI Assistant
**检查时间**: 2026-04-30
**修复状态**: 待修复
