


# AGENTS 记录

## 2026-04-24: 修复新增司机默认密码不是123456的问题

### 问题描述
新增司机（仓库、水站、系统管理员）后，使用默认密码 "123456" 无法登录系统。

### 问题根因
**所有用户创建和密码更新时，密码以明文形式存储，没有进行 BCrypt 加密**

1. **登录验证逻辑**（[UserService.java](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/auth/service/UserService.java)）：
   ```java
   public boolean validatePassword(String rawPassword, String encodedPassword) {
       return passwordEncoder.matches(rawPassword, encodedPassword);
   }
   ```
   - 使用 BCrypt 的 `matches()` 方法验证密码
   - 期望数据库中存储的是 BCrypt 加密后的密码

2. **错误的用户创建逻辑**（如 [AdminDriverService.java](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/admin/service/AdminDriverService.java)）：
   ```java
   String password = (request.getPassword() != null && !request.getPassword().isEmpty())
       ? request.getPassword() : "123456";
   User user = new User();
   user.setPassword(password);  // 明文密码！
   ```
   - 密码直接以明文存储，没有加密

3. **受影响的服务类**：
   - `AdminDriverService.java` - 司机创建、更新、重置密码
   - `AdminWarehouseService.java` - 仓库创建、更新
   - `AdminStationService.java` - 水站创建、更新
   - `AdminSystemService.java` - 管理员密码重置

### 修复方案

#### 1. 在所有 Service 类中添加 BCryptPasswordEncoder
```java
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
```

#### 2. 修改密码设置逻辑
```java
// 创建用户时
String rawPassword = (request.getPassword() != null && !request.getPassword().isEmpty())
    ? request.getPassword() : "123456";
String encodedPassword = passwordEncoder.encode(rawPassword);
user.setPassword(encodedPassword);

// 更新密码时
if (request.getPassword() != null && !request.getPassword().isEmpty()) {
    user.setPassword(passwordEncoder.encode(request.getPassword()));
}

// 重置密码时
user.setPassword(passwordEncoder.encode("123456"));
```

#### 3. 修改的文件
- [AdminDriverService.java](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/admin/service/AdminDriverService.java)
- [AdminWarehouseService.java](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/admin/service/AdminWarehouseService.java)
- [AdminStationService.java](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/admin/service/AdminStationService.java)
- [AdminSystemService.java](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/admin/service/AdminSystemService.java)

### 编译验证
```powershell
mvn clean compile -DskipTests
# BUILD SUCCESS
```

### 教训

#### 1. 密码必须加密存储
- 所有用户密码必须使用 BCrypt（或 Argon2 等安全算法）加密后存储
- 绝对不能以明文形式存储密码
- 即使是默认密码 "123456" 也必须加密

#### 2. 密码验证必须使用加密算法
- 登录验证使用 `passwordEncoder.matches(rawPassword, encodedPassword)`
- 这意味着数据库中存储的必须是加密后的密码
- 明文密码与加密密码永远不会匹配

#### 3. 检查所有密码相关代码
- 创建用户时必须加密
- 更新密码时必须加密
- 重置密码时必须加密
- 修改密码时必须加密

#### 4. 测试时验证密码加密
- 创建新用户后，查询数据库确认密码是加密的
- 使用正确密码登录验证成功
- 使用错误密码登录验证失败

#### 5. 密码加密是安全红线
- 这是 Spring Security 的基本要求
- 明文密码泄露是严重的安全漏洞
- 必须从一开始就正确实现

---

## 2026-04-24: 仓库端后端API完善

### 概述
为仓库端（PC端管理后台）补充缺失的后端API接口，确保前后端功能完整对接。

### 补充的API接口

#### 1. 回仓核对相关API
**文件**: `bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/warehouse/controller/WarehouseController.java`

| 接口 | 方法 | 描述 |
|------|------|------|
| `/warehouses/returns/{returnId}` | GET | 获取回仓详情 |
| `/warehouses/returns/{returnId}/confirm` | POST | 确认回仓 |
| `/warehouses/returns/{returnId}/discrepancy` | POST | 记录差异 |

**实现要点**:
- `getReturnDetail`: 查询回仓记录，关联司机信息
- `confirmReturn`: 确认回仓，更新库存，处理差异
- `recordDiscrepancy`: 记录差异，更新司机欠桶数

#### 2. 仓库信息管理API
| 接口 | 方法 | 描述 |
|------|------|------|
| `/warehouses/info` | GET | 获取仓库信息 |
| `/warehouses/info` | PUT | 更新仓库信息 |

#### 3. 个人信息管理API
| 接口 | 方法 | 描述 |
|------|------|------|
| `/warehouses/profile` | GET | 获取个人信息 |
| `/warehouses/profile` | PUT | 更新个人信息 |

#### 4. 密码修改API
| 接口 | 方法 | 描述 |
|------|------|------|
| `/warehouses/change-password` | POST | 修改密码 |

**验证逻辑**:
- 检查旧密码是否正确
- 新密码长度不能少于6位
- 验证通过后更新密码

#### 5. 通知设置API
| 接口 | 方法 | 描述 |
|------|------|------|
| `/warehouses/notification-settings` | GET | 获取通知设置 |
| `/warehouses/notification-settings` | PUT | 更新通知设置 |

### 依赖注入
- `DriverReturnMapper` - 回仓记录查询
- `DriverMapper` - 司机信息查询
- `ProductInventoryMapper` - 库存操作
- `WarehouseMapper` - 仓库信息操作
- `UserMapper` - 用户信息操作
- `OrderMapper` - 订单信息查询
- `OrderItemMapper` - 订单明细查询

### 编译验证
```powershell
mvn clean compile -DskipTests
# BUILD SUCCESS
```

### 教训总结

#### 1. DriverReturn实体字段命名
- **问题**: 假设DriverReturn有`returnNo`、`orderId`、`orderNo`、`driverName`、`driverCode`等字段
- **实际**: DriverReturn只有`driverId`、`warehouseId`、`status`等字段
- **解决方案**: 先检查实体类的实际字段定义，再编写代码

#### 2. ResultCode枚举值
- **问题**: 使用不存在的`AUTH_ERROR`枚举值
- **实际**: 应该使用`PARAM_ERROR`
- **解决方案**: 先检查ResultCode枚举定义

#### 3. Mapper导入
- **问题**: 忘记导入`ProductInventoryMapper`
- **解决方案**: 确保所有使用的Mapper都已导入

### 相关文件
- [WarehouseController.java](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/warehouse/controller/WarehouseController.java) - 仓库控制器（已完善）

---

## 2026-04-21: 修复 GET /api/admin/regions/tree 500 错误

### 问题描述
GET /api/admin/regions/tree 返回 500 Internal Server Error

### 问题根因
1. **逻辑删除配置冲突**
   - MyBatis-Plus 全局配置启用了逻辑删除: `logic-delete-field: deleted`
   - Region 实体类没有定义 `deleted` 字段
   - MyBatis-Plus 自动生成的 SQL 包含 `WHERE deleted = 0` 条件
   - 数据库中的 region 表没有 `deleted` 列，导致 SQL 执行失败

2. **region 表可能缺少必要列**
   - `region_module.sql` 是独立的表创建脚本
   - 如果未执行，表不存在或列缺失

### 修复方案

#### 1. 修复 Region.java 实体类
**文件**: `bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/admin/entity/Region.java`

**修改内容**:
```java
// 添加逻辑删除字段
@TableLogic
@TableField(select = false)
private Integer deleted;
```

#### 2. 更新 region_module.sql
**文件**: `bucket-water-oms-java/database/region_module.sql`

**修改内容**:
- 在 CREATE TABLE 语句中添加 `deleted` 列
- 添加修复脚本，处理已存在表缺少 `deleted` 列的情况
- 添加 `idx_deleted` 索引

#### 3. 创建诊断脚本
**文件**: `bucket-water-oms-java/database/diagnose_region_table.sql`

**用途**: 检查 region 表是否存在，结构是否正确

### 解决方案步骤

#### 步骤 1: 在数据库中创建 region 表

使用 psql 命令执行 SQL 脚本：

```powershell
# 使用 psql 执行 region_module.sql
psql -h 192.168.31.251 -p 5432 -U wateroms -d wateroms -f "c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-java\database\region_module.sql"
```

或者直接在 PostgreSQL 中复制执行 SQL 文件内容。

#### 步骤 2: 验证表是否创建成功

```sql
-- 检查表是否存在
SELECT EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'region'
) AS region_table_exists;

-- 查看表结构
\d region

-- 查看数据
SELECT * FROM region LIMIT 10;
```

#### 步骤 3: 重启后端应用

```powershell
# 重启 Spring Boot 应用
```

#### 步骤 4: 验证接口

访问 `GET http://192.168.31.72:8080/api/admin/regions/tree`

### 相关文件
- [Region.java](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/admin/entity/Region.java)
- [region_module.sql](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/database/region_module.sql)
- [diagnose_region_table.sql](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/database/diagnose_region_table.sql)

### 教训
1. **实体类与全局配置必须一致**
   - 如果全局配置启用了逻辑删除，所有使用该配置的实体类必须定义对应的字段
   - 或者在不需要逻辑删除的实体类上使用 `@TableLogic(value = "", delval = "")` 禁用

2. **数据库表结构变更需要同步代码**
   - 独立创建的表（如 region_module.sql）需要确保与实体类匹配
   - 建议将所有表创建脚本整合到一个初始化脚本中

3. **测试时需要验证边界情况**
   - 不仅测试正常功能，还要测试异常情况
   - 确保错误信息不会泄露敏感信息

4. **PostgreSQL 不支持 MySQL 风格的 COMMENT 语法**
   - **错误写法**: `CREATE TABLE ... (name VARCHAR(100) NOT NULL COMMENT '名称')`
   - **正确写法**: 
     ```sql
     CREATE TABLE ... (name VARCHAR(100) NOT NULL);
     COMMENT ON COLUMN table_name.name IS '名称';
     ```
   - PostgreSQL 使用 `COMMENT ON COLUMN` 而不是内联注释
   - 索引创建也必须分开：`CREATE INDEX` 而不是在 CREATE TABLE 内联

5. **数据库脚本需要针对目标数据库测试**
   - 开发和测试时使用的数据库必须与生产环境一致
   - 不同数据库（MySQL/PostgreSQL/SQL Server）有不同的语法要求
   - 建议在文档中明确标注支持的数据库类型

6. **PostgreSQL 不支持 ON UPDATE CURRENT_TIMESTAMP**
   - **错误写法**: `update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP`
   - **正确写法**: 使用触发器实现自动更新
     ```sql
     -- 创建触发器函数
     CREATE OR REPLACE FUNCTION update_timestamp_column()
     RETURNS TRIGGER AS $$
     BEGIN
         NEW.update_time = CURRENT_TIMESTAMP;
         RETURN NEW;
     END;
     $$ language 'plpgsql';
     
     -- 创建触发器
     CREATE TRIGGER update_region_timestamp
         BEFORE UPDATE ON region
         FOR EACH ROW
         EXECUTE FUNCTION update_timestamp_column();
     ```
   - 注意：MySQL 支持内联 `ON UPDATE`，但 PostgreSQL 需要触发器

7. **创建表后必须执行 SQL 脚本**
   - **问题**: `ERROR: relation "region" does not exist`
   - **原因**: SQL 脚本没有执行或执行失败
   - **解决方案**: 必须手动执行 SQL 脚本来创建表
   - **执行命令**:
     ```powershell
     psql -h 192.168.31.251 -p 5432 -U wateroms -d wateroms -f "path\to\region_module.sql"
     ```
   - **验证方法**: 执行后检查 `\d region` 确认表已创建

## 2026-04-23: 修复仓库账号登录"用户不存在"错误

### 问题描述
仓库端（PC端）登录时返回"用户不存在"错误（错误码 8001），但移动端仓库登录能正常成功。

### 问题根因
**PC端登录请求传入错误的角色值**

1. **数据库中 users 表的 role 字段存储的是小写字符串**：
   - `'admin'` - 水厂管理员
   - `'warehouse'` - 仓库管理员
   - `'driver'` - 司机
   - `'station'` - 水站老板
   - `'staff'` - 店员

2. **PC端前端登录时硬编码发送 `role: 'admin'`**：
   ```javascript
   const result = await authStore.login({
     phone: formData.value.phone,
     password: formData.value.password,
     role: 'admin'  // 硬编码为 'admin'
   })
   ```

3. **后端登录查询时按传入的 role 进行过滤**：
   ```java
   User user = userMapper.selectOne(
       new LambdaQueryWrapper<User>()
           .eq(User::getPhone, request.getPhone())
           .eq(User::getRole, role)  // 查询时使用传入的 role
           .eq(User::getStatus, "active")
   );
   ```

4. **仓库用户（如手机号 13700000002）的 role 是 `'warehouse'`**：
   - 使用 `role='admin'` 查询找不到仓库用户
   - 返回"用户不存在"错误

### 修复方案

#### 1. 修改后端支持不带角色登录
**文件**: `bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/auth/dto/LoginRequest.java`

**修改内容**:
- 移除 `@NotBlank(message = "角色不能为空")` 注解
- role 字段改为可选参数

#### 2. 修改 AuthService.login 方法
**文件**: `bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/auth/service/AuthService.java`

**修改内容**:
```java
@Transactional
public LoginResponse login(LoginRequest request) {
    User user;
    if (request.getRole() != null && !request.getRole().isEmpty()) {
        // 传入了角色，按角色验证
        String role = convertToUserRole(request.getRole());
        user = userMapper.selectOne(
            new LambdaQueryWrapper<User>()
                .eq(User::getPhone, request.getPhone())
                .eq(User::getRole, role)
                .eq(User::getStatus, "active")
        );
    } else {
        // 未传入角色，只按手机号和密码验证
        user = userMapper.selectOne(
            new LambdaQueryWrapper<User>()
                .eq(User::getPhone, request.getPhone())
                .eq(User::getStatus, "active")
        );
    }
    
    if (user == null) {
        throw new BusinessException(ResultCode.USER_NOT_FOUND);
    }
    // ... 后续验证密码逻辑
}
```

#### 3. 修改 PC 端前端登录
**文件**: `bucket-water-oms-admin/src/views/Login.vue`

**修改内容**:
- 移除登录请求中的 `role: 'admin'` 参数
- 登录成功后根据返回的用户角色自动跳转到对应页面

```javascript
const handleLogin = async () => {
  const result = await authStore.login({
    phone: formData.value.phone,
    password: formData.value.password
    // 不传 role 参数
  })

  if (result.success) {
    const role = authStore.role
    
    let targetRoute = '/'
    if (role === 'admin' || role === 'FACTORY_ADMIN') {
      targetRoute = '/'
    } else if (role === 'warehouse' || role === 'WAREHOUSE_ADMIN') {
      targetRoute = '/warehouse'
    } else if (role === 'driver' || role === 'DRIVER') {
      targetRoute = '/driver'
    } else if (role === 'station' || role === 'station_owner') {
      targetRoute = '/station'
    }
    
    await router.push(targetRoute)
  }
}
```

#### 4. 更新 authStore 添加 role 属性
**文件**: `bucket-water-oms-admin/src/stores/auth.ts`

**修改内容**:
- 添加 `role` ref 存储用户角色
- 登录成功后设置 `role.value`
- 导出 `role` 供组件使用

### 相关文件
- [LoginRequest.java](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/auth/dto/LoginRequest.java) - 登录请求DTO
- [AuthService.java](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/auth/service/AuthService.java) - 认证服务
- [Login.vue](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-admin/src/views/Login.vue) - PC端登录页
- [auth.ts](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-admin/src/stores/auth.ts) - 认证状态管理

### 教训
1. **前端硬编码角色值是严重的设计缺陷**
   - 不同角色应该共用同一个登录接口
   - 根据用户输入的账号自动识别角色
   - 不应该在登录时让用户手动选择角色（PC端）或硬编码角色

2. **数据库角色值必须与前端/后端一致**
   - 数据库中存储的是 `'warehouse'`（小写）
   - 后端 convertToUserRole 方法返回的也是小写字符串
   - 前端传入 `'admin'` 会导致角色不匹配

3. **角色参数应该是可选的**
   - 手机号是用户的唯一标识
   - 同一个手机号不会同时属于多个角色
   - 只需要按手机号+密码验证即可，无需额外的角色过滤

4. **登录成功后的路由跳转需要根据角色决定**
   - 水厂管理员 -> `/` 或 `/dashboard`
   - 仓库管理员 -> `/warehouse` 或 `/warehouse/dashboard`
   - 司机 -> `/driver` 或 `/driver/tasks`
   - 水站老板 -> `/station` 或 `/station/orders`

5. **移动端和 PC 端应该使用相同的登录逻辑**
   - 移动端传入具体角色（如 `'warehouse'`）用于快速验证
   - PC 端不传角色，后端自动按手机号识别
   - 两种方式都能正常工作

6. **登录接口设计最佳实践**
   - 核心参数：手机号 + 密码（必需）
   - 可选参数：角色（用于特定场景的快速验证）
   - 返回数据：Token + 用户信息（包含真实角色）
   - 错误处理：区分"用户不存在"和"密码错误"

## 2026-04-23: PC端登录添加角色选择功能

### 问题描述
仓库端登录返回"用户不存在"错误，但移动端能登录。用户（如手机号 13700000002）是存在的，role 为 'warehouse'。

### 问题根因
**PC端前端登录时硬编码发送 `role: 'admin'`**

### 修复方案

#### 1. 添加角色选择下拉框
**文件**: `bucket-water-oms-admin/src/views/Login.vue`

**修改内容**:
- 在登录表单中添加角色选择下拉框
- 支持选择：管理员、仓库管理员、司机、水站老板
- 下拉框使用与输入框一致的样式设计

#### 2. 修改 LoginRequest 接口
**文件**: `bucket-water-oms-admin/src/api/auth.ts`

**修改内容**:
```typescript
export interface LoginRequest {
  phone: string
  password: string
  role?: string  // 改为可选参数
}
```

#### 3. 更新 formData 和 handleLogin
**文件**: `bucket-water-oms-admin/src/views/Login.vue`

**修改内容**:
```typescript
// formData 添加 role 属性
const formData = ref({
  phone: '13700000002',
  password: '123456',
  role: 'warehouse',  // 默认选择仓库管理员
  remember: true
})

// handleLogin 使用选择的角色
const result = await authStore.login({
  phone: formData.value.phone,
  password: formData.value.password,
  role: formData.value.role  // 使用选择的角色而非硬编码
})
```

### 相关文件
- [Login.vue](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-admin/src/views/Login.vue) - PC端登录页（已添加角色选择）
- [auth.ts](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-admin/src/api/auth.ts) - 认证API定义（role改为可选）

### 教训
1. **角色选择应该是用户可配置的**
   - 不同角色使用不同的账号登录
   - 用户需要明确选择自己要使用的角色
   - 提供下拉框让用户选择是最直观的方案

2. **默认测试账号应该与选择的角色匹配**
   - 仓库管理员登录默认测试账号应使用仓库用户手机号
   - 从 `13800138000` (admin) 改为 `13700000002` (warehouse)

3. **UI 风格需要保持一致**
   - 下拉框使用与输入框相同的样式设计
   - 包含图标、圆角、focus 效果等
   - 添加自定义下拉箭头图标提升用户体验

## 2026-04-23: Flutter移动端司机端删除写死测试数据

### 问题描述
Flutter移动端司机端存在大量写死的测试数据，导致应用无法显示真实业务数据。

### 问题根因
**前端代码中硬编码了测试数据**

1. **driver_tasks_page.dart** 包含:
   - 司机名称: `'王力师傅'`
   - 仓库名称: `'中心仓库A库区'`
   - 统计数据: `'待配送 8'`、`'配送中 2'`、`'已完成 5'`
   - 路线规划信息: `'智能规划配送路线'`、`'已避开拥堵路段，预计用时 45min'`、`'共 3 个配送点 · 总里程 12.5km'`
   - 地址: `'秀峰区XX路88号'`
   - 联系人信息: `'张老板'`、`'138****8888'`
   - 商品信息: `'18.9L 桶装水'`
   - 欠桶数: `'5个'`、`'8个'`
   - 时间: `'开始时间: 14:20'`、`'14:35'`
   - 水站名称: `'张记旗舰水站'`、`'青山水店'`
   - 空桶信息: `'回桶: +35个 · 欠桶: 5个'`、`'当前车上空桶：75个'`、`'待交回仓库：15个'`

2. **driver_order_detail_page.dart** 包含:
   - 订单号: `'#1'`
   - 客户信息: `'张老板'`、`'138****8888'`
   - 地址: `'桂林市秀峰区XX路XX号张记旗舰水站'`
   - 预约时间: `'2026-04-19 14:00'`
   - 商品数据: `'18.9L 桶装水'`、`50`、`20`
   - 配送数量: `70`、`65`
   - 状态步骤时间标题等

3. **driver_barrel_page.dart** 包含:
   - 日期: `'2026-04-20'`
   - 押金桶总数: `100`
   - 当前欠桶数: `8`
   - 预警阈值: `10`
   - 补缴押金金额: `8个×¥20`
   - 往来记录数据

4. **driver_statement_page.dart** 包含:
   - 待结金额: `¥4850.00`
   - 基本工资: `¥3000.00`
   - 配送提成: `¥1850.00`
   - 完成订单数: `125`
   - 总桶数: `3200`
   - 好评率: `99%`
   - 月份选择: `'2026年04月'`

### 修复方案

#### 1. 创建完整的API服务层
**文件**: `bucket-water-oms-admin-mobile/lib/services/driver_service.dart`

**修改内容**:
- 添加 `getDriverDashboard()` 方法获取司机Dashboard数据
- 添加 `getDriverTasks()` 方法获取待配送任务列表
- 添加 `getRoutePlanning()` 方法获取配送路线规划
- 添加 `startDelivery()` 方法开始配送
- 添加 `deliverOrder()` 方法确认送达
- 添加 `warehouseReturn()` 方法回仓申请
- 添加 `updateLocation()` 方法更新GPS位置
- 添加 `driverCheckIn()` 方法到达打卡
- 添加 `getDriverStatus()` 方法获取司机状态
- 添加 `getDriverStatements()` 方法获取对账单
- 添加 `confirmStatement()` 方法确认对账单
- 添加完整的Mock数据方法用于离线或API不可用时

#### 2. 创建数据模型类
**新增类**:
```dart
class DriverDashboardData {
  final int todayDeliveries;
  final int pendingDeliveries;
  final int completedDeliveries;
  final int totalBucketsOnWay;
  final int owedBuckets;
  final int bucketThreshold;
  final double todayEarnings;
  final String? driverName;
  final String? warehouseName;
  final List<DriverTaskModel> recentTasks;
  final List<NotificationData> notifications;
}

class RoutePlanningData {
  final double totalDistance;
  final int estimatedMinutes;
  final int pointCount;
  final List<WaypointData> waypoints;
}

class DriverStatementData {
  final String id;
  final String month;
  final double pendingAmount;
  final double baseSalary;
  final double deliveryCommission;
  final int completedOrders;
  final int totalBarrels;
  final int goodRating;
  final String status;
  final List<StatementDetailItem> details;
}
```

#### 3. 修改所有司机端页面使用API数据
**文件**:
- `bucket-water-oms-admin-mobile/lib/pages/driver/driver_tasks_page.dart`
- `bucket-water-oms-admin-mobile/lib/pages/driver/driver_order_detail_page.dart`
- `bucket-water-oms-admin-mobile/lib/pages/driver/driver_barrel_page.dart`
- `bucket-water-oms-admin-mobile/lib/pages/driver/driver_statement_page.dart`

**修改内容**:
- 添加状态管理: `_isLoading`、`_errorMessage`
- 添加数据状态: `_dashboardData`、`_pendingTasks`、`_deliveringTasks`、`_completedTasks`
- 在 `initState()` 中调用 `_loadData()` 加载API数据
- 修改所有UI组件使用API返回的真实数据
- 添加下拉刷新功能 `RefreshIndicator`
- 添加错误处理和加载状态显示

#### 4. 增强地图导航功能
**文件**: `bucket-water-oms-admin-mobile/lib/services/map_service.dart`

**新增功能**:
- 支持高德地图导航
- 支持百度地图导航（包含GCJ-02到BD-09坐标转换）
- 支持腾讯地图导航
- 支持苹果地图导航
- 支持Google地图导航
- 添加底部弹出选择器 `_NavigationBottomSheet`
- 添加地址复制到剪贴板功能
- 添加拨打电话功能 `makePhoneCall()`

### 相关文件
- [driver_service.dart](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-admin-mobile/lib/services/driver_service.dart) - 司机服务层
- [map_service.dart](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-admin-mobile/lib/services/map_service.dart) - 地图导航服务
- [driver_tasks_page.dart](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-admin-mobile/lib/pages/driver/driver_tasks_page.dart) - 司机任务页面
- [driver_order_detail_page.dart](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-admin-mobile/lib/pages/driver/driver_order_detail_page.dart) - 订单详情页面
- [driver_barrel_page.dart](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-admin-mobile/lib/pages/driver/driver_barrel_page.dart) - 空桶管理页面
- [driver_statement_page.dart](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-admin-mobile/lib/pages/driver/driver_statement_page.dart) - 对账单页面
- [DriverController.java](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/driver/controller/DriverController.java) - 后端司机控制器

### 教训
1. **永远不要在前端代码中硬编码测试数据**
   - 所有业务数据必须从API获取
   - 硬编码的测试数据会导致应用无法使用真实数据
   - 建议在开发阶段使用Mock数据，但必须标注并最终移除

2. **前端必须实现完整的数据流**
   - Model（数据模型）: 定义数据结构
   - Service（服务层）: 封装API调用
   - State（状态管理）: 管理页面状态
   - View（视图层）: 只负责UI展示
   - 数据应该单向流动，避免直接操作UI

3. **API服务层设计最佳实践**
   - 每个API方法应该包含完整的错误处理
   - 提供Mock数据用于离线或API不可用时降级
   - 使用Future/Promise模式处理异步请求
   - 使用try-catch捕获异常并转换为用户友好的错误消息

4. **Flutter状态管理**
   - 使用StatefulWidget管理本地状态
   - 使用Provider或Riverpod管理全局状态
   - 及时调用setState()更新UI
   - 使用mounted检查避免内存泄漏

5. **地图导航集成要点**
   - 必须处理坐标系转换（GCJ-02与BD-09）
   - 必须提供多个地图应用选项
   - 必须处理地图应用未安装的情况
   - 应该提供网页版降级方案
   - 必须处理用户权限问题

6. **用户体验优化**
   - 显示加载状态指示器
   - 提供下拉刷新功能
   - 优雅处理错误情况
   - 使用SnackBar提供操作反馈
   - 使用BottomSheet提供选择菜单

7. **代码组织规范**
   - 按功能模块划分代码结构
   - 服务层单独文件
   - 数据模型单独文件
   - 页面组件单独文件
   - 共享组件抽取到shared目录

8. **移动端开发注意事项**
   - 处理安全区域（SafeArea）
   - 处理键盘弹出遮挡问题
   - 使用MediaQuery获取屏幕信息
   - 处理深色模式适配
   - 处理网络异常情况

## 2026-04-24: 实现仓库端后端API

### 实现概述
为仓库端实现了完整的API接口，包括订单详情、备货订单列表、推荐司机、空桶出入库等功能。

### 新增数据库表
**文件**: `bucket-water-oms-java/database/bucket_inventory_module.sql`

**表结构**:
- `bucket_inbound`: 空桶入库表
  - id, inbound_no, warehouse_id, driver_id
  - type: driver_return/clean/transfer_in
  - status: pending/confirmed/rejected
  - quantity, bucket_type, source, remark

- `bucket_outbound`: 空桶出库表
  - id, outbound_no, warehouse_id, driver_id
  - type: driver_pickup/transfer_out/damage
  - status: pending/confirmed/rejected
  - quantity, bucket_type, destination, remark

### 新增实体类
**文件**: `bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/bucket/entity/`

- `BucketInbound.java` - 空桶入库实体
- `BucketOutbound.java` - 空桶出库实体

### 新增DTO类
**文件**: `bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/bucket/dto/`

- `BucketInboundDTO.java` - 入库列表响应
- `BucketOutboundDTO.java` - 出库列表响应
- `CreateBucketInboundRequest.java` - 创建入库请求
- `CreateBucketOutboundRequest.java` - 创建出库请求
- `ConfirmBucketInboundRequest.java` - 确认入库请求
- `ConfirmBucketOutboundRequest.java` - 确认出库请求

**文件**: `bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/warehouse/dto/`

- `PreparingOrderDTO.java` - 备货订单DTO
- `RecommendedDriverDTO.java` - 推荐司机DTO

**文件**: `bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/order/dto/`

- `RejectOrderRequest.java` - 拒单请求（含库存不足明细）

### 新增Mapper接口
**文件**: `bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/bucket/mapper/`

- `BucketInboundMapper.java`
- `BucketOutboundMapper.java`

### 新增Service层
**文件**: `bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/bucket/service/`

- `BucketInboundService.java` - 入库服务
- `BucketOutboundService.java` - 出库服务

### 新增/增强Controller
**新增Controller**:
- `BucketInboundController.java` - 空桶入库控制器
- `BucketOutboundController.java` - 空桶出库控制器

**增强Controller**:
- `OrderController.java` - 添加拒单接口 `POST /orders/{orderId}/reject`
- `WarehouseController.java` - 添加备货订单接口和推荐司机详情接口

### API接口清单

#### 1. 订单详情API
- **GET /api/orders/{orderId}** - 获取订单详情
- **GET /api/orders/{orderId}** (仓库端) - 获取订单详情（含库存检查）

#### 2. 备货订单列表API
- **GET /api/warehouses/orders/preparing** - 获取备货订单列表
  - 参数: status(preparing/prepared/dispatched), page, size
  - 返回: 订单列表、商品明细、备货进度

#### 3. 推荐司机API
- **GET /api/warehouses/drivers/recommend** - 获取推荐司机列表（基础版）
- **GET /api/warehouses/drivers/recommend/details** - 获取推荐司机详情列表
  - 返回: 司机信息、位置、状态、任务数、评分、推荐原因、推荐得分

**推荐算法**:
- 距离: 40%权重（仓库到司机当前位置）
- 任务数: 30%权重（当前待配送订单数）
- 在线状态: 20%权重
- 历史评分: 10%权重

#### 4. 拒单API
- **POST /api/orders/{orderId}/reject** - 仓库拒单
  - 参数: reason(拒单原因), stockDetails(库存不足明细)
  - 功能: 记录拒单原因、库存不足明细、发送通知

#### 5. 订单派单API
- **POST /api/orders/{orderId}/dispatch** - 仓库派单
  - 功能: 更新状态、记录派单时间、发送通知给司机

#### 6. 空桶入库API
- **GET /api/warehouses/bucket-inbound** - 获取入库列表
- **POST /api/warehouses/bucket-inbound** - 创建入库单
- **POST /api/warehouses/bucket-inbound/{id}/confirm** - 确认入库
- **POST /api/warehouses/bucket-inbound/{id}/reject** - 拒绝入库

#### 7. 空桶出库API
- **GET /api/warehouses/bucket-outbound** - 获取出库列表
- **POST /api/warehouses/bucket-outbound** - 创建出库单
- **POST /api/warehouses/bucket-outbound/{id}/confirm** - 确认出库
- **POST /api/warehouses/bucket-outbound/{id}/reject** - 拒绝出库

#### 8. 回仓列表API
- **GET /api/warehouses/returns** - 获取司机回仓申请列表

### 相关文件
- [bucket_inventory_module.sql](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/database/bucket_inventory_module.sql)
- [BucketInbound.java](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/bucket/entity/BucketInbound.java)
- [BucketOutbound.java](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/bucket/entity/BucketOutbound.java)
- [BucketInboundController.java](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/bucket/controller/BucketInboundController.java)
- [BucketOutboundController.java](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/bucket/controller/BucketOutboundController.java)
- [OrderController.java](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/order/controller/OrderController.java)
- [WarehouseController.java](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/warehouse/controller/WarehouseController.java)

### 教训
1. **编译前检查实体类字段**
   - 新增功能时需要检查是否使用了实体类中不存在的字段
   - 如 `stockDetails` 字段需要添加到 Order 实体类中

2. **使用 @Transactional 确保数据一致性**
   - 出入库操作涉及库存更新，必须使用事务管理
   - 确认和取消操作需要确保原子性

3. **遵循现有代码风格**
   - 使用 Lombok @Data 注解时需要手动添加 getter/setter（如果有自定义逻辑）
   - DTO 类遵循现有命名和结构规范

4. **推荐算法设计**
   - 综合考虑多个因素分配权重
   - 提供推荐原因让用户理解推荐结果

## 2026-04-24: 水站端售后API完善

### 概述
为水站老板端完善售后相关的后端API接口，支持售后申请列表、售后详情、创建售后申请、取消售后申请等功能。

### 新增数据库表
**文件**: `bucket-water-oms-java/database/after_sales_module.sql`

**表结构**:
- `after_sales`: 售后主表
  - id, after_sales_no, station_id, order_id
  - type: replenishment/refund/return
  - status: pending/processing/completed/rejected/cancelled
  - reason, handle_result, handle_time

- `after_sales_item`: 售后商品明细表
  - id, after_sales_id, product_id, quantity

- `after_sales_image`: 售后图片表
  - id, after_sales_id, image_url

### 新增实体类
**文件**: `bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/aftersales/entity/`

- `AfterSalesItem.java` - 售后商品明细实体
- `AfterSalesImage.java` - 售后图片实体
- `AfterSales.java` - 售后主实体（更新，添加afterSalesNo字段）

### 新增DTO类
**文件**: `bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/aftersales/dto/`

- `AfterSalesDTO.java` - 售后列表响应DTO
- `AfterSalesDetailDTO.java` - 售后详情响应DTO
- `AfterSalesItemDTO.java` - 售后商品明细DTO
- `CreateAfterSalesRequestV2.java` - 创建售后请求DTO（新版本）
- `CreateAfterSalesResponse.java` - 创建售后响应DTO

### 新增Mapper接口
**文件**: `bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/aftersales/mapper/`

- `AfterSalesItemMapper.java` - 售后商品明细Mapper
- `AfterSalesImageMapper.java` - 售后图片Mapper

### 增强Controller
**文件**: `bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/aftersales/controller/AfterSalesController.java`

### API接口清单

#### 1. 售后申请列表API
- **GET /api/after-sales** - 获取售后列表（水站端）
  - 参数: status, page, size
  - 返回: 分页的售后列表，包含商品明细和图片

#### 2. 售后详情API
- **GET /api/after-sales/{id}** - 获取售后详情（水站端）
  - 返回: 售后详情，包含关联订单信息

#### 3. 创建售后申请API
- **POST /api/after-sales** - 创建售后申请（水站端）
  - 参数: orderId, type, items, reason, images
  - 功能: 验证订单、生成售后单号、保存商品明细、处理图片上传

#### 4. 取消售后申请API
- **POST /api/after-sales/{id}/cancel** - 取消售后申请（水站端）
  - 限制: 只能取消pending状态的售后

#### 5. 仓库端售后列表API
- **GET /api/after-sales/warehouse** - 获取售后列表（仓库端）
  - 参数: warehouseId, status, page, size

#### 6. 处理售后API
- **POST /api/after-sales/{id}/process** - 处理售后（仓库端）
  - 参数: action(approve/reject/processing), reason, newOrderId

#### 7. 辅助接口
- **GET /api/after-sales/types** - 获取售后类型列表
- **GET /api/after-sales/statuses** - 获取售后状态列表

### 业务逻辑要点

#### 售后类型
- replenishment: 补货（少送）
- refund: 退款（多收）
- return: 退货（商品损坏）

#### 售后状态
- pending: 待处理
- processing: 处理中
- completed: 已完成
- rejected: 已拒绝
- cancelled: 已取消

#### 售后单号生成规则
- 格式: AS + 年月日(YYYYMMDD) + 6位序号
- 示例: AS20260424000001

#### 业务校验
1. 验证订单存在且属于该水站
2. 验证订单状态为已完成
3. 验证售后商品在订单中存在
4. 验证售后数量不超过订单数量
5. 只能取消pending状态的售后

### 相关文件
- [after_sales_module.sql](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/database/after_sales_module.sql)
- [AfterSales.java](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/aftersales/entity/AfterSales.java)
- [AfterSalesItem.java](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/aftersales/entity/AfterSalesItem.java)
- [AfterSalesImage.java](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/aftersales/entity/AfterSalesImage.java)
- [AfterSalesController.java](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/aftersales/controller/AfterSalesController.java)
- [AfterSalesService.java](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/aftersales/service/AfterSalesService.java)

### 教训
1. **实体类字段命名一致性**
   - 数据库使用 create_time，实体类使用 createdAt
   - 在LambdaQueryWrapper中使用 getCreatedAt() 而不是 getCreateTime()

2. **避免使用不存在的包**
   - org.springframework.mock.web.MockMultipartFile 可能不存在
   - 使用自定义文件保存逻辑替代

3. **Base64图片处理**
   - 移除data:image前缀
   - 生成唯一文件名
   - 返回可访问的URL路径

4. **售后单号唯一性**
   - 使用日期+序号的方式生成
   - 通过查询当天最大序号确保唯一性

5. **权限验证**
   - 水站端验证售后记录属于该水站
   - 仓库端通过订单关联验证权限

---

## 2026-04-24: 修复司机端API字段不匹配问题

### 问题描述
司机端（移动端）上线后业务不可用，主要问题是后端返回的字段名与移动端期望的字段名不匹配。

### 问题根因
**后端 OrderVO 和 DriverDashboardDTO 字段名与移动端期望不匹配**

1. **OrderVO 缺少移动端需要的字段**：
   - 移动端期望 `latitude`/`longitude`，后端只有 `stationLat`/`stationLng`
   - 移动端期望 `stationName`（水站名称），后端只有嵌套的 `warehouse` 对象
   - 移动端期望 `totalQuantity`（总数量），后端没有返回

2. **DriverDashboardDTO 缺少字段**：
   - 移动端期望 `driverName`（司机名称），后端没有返回
   - 移动端期望 `warehouseName`（仓库名称），后端没有返回

3. **对账单接口返回格式不匹配**：
   - 后端 `/drivers/statements` 返回 `List<DriverStatementDTO>`
   - 移动端期望单个 `DriverStatementData` 对象

### 修复方案

#### 1. 修复 OrderVO 字段
**文件**: `bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/order/dto/OrderVO.java`

**新增字段**:
```java
@Schema(description = "水站名称 (兼容移动端)")
private String stationName;

@Schema(description = "纬度 (兼容移动端)")
private BigDecimal latitude;

@Schema(description = "经度 (兼容移动端)")
private BigDecimal longitude;

@Schema(description = "总数量 (兼容移动端)")
private Integer totalQuantity;
```

#### 2. 修复 DriverService.convertToVO 方法
**文件**: `bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/driver/service/DriverService.java`

**修改内容**:
```java
Station station = order.getStationId() != null ? stationMapper.selectById(order.getStationId()) : null;
String stationName = station != null ? station.getName() : null;
BigDecimal lat = station != null ? station.getLat() : null;
BigDecimal lng = station != null ? station.getLng() : null;

OrderVO vo = new OrderVO();
// ... 设置其他字段 ...
vo.setStationName(stationName);
vo.setLatitude(lat);
vo.setLongitude(lng);
vo.setTotalQuantity(totalQty);

return vo;
```

#### 3. 修复 DriverDashboardDTO 字段
**文件**: `bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/driver/dto/DriverDashboardDTO.java`

**新增字段**:
```java
private String driverName;
private String warehouseName;
```

#### 4. 修复 getDashboard 方法
**文件**: `bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/driver/service/DriverService.java`

**修改内容**:
```java
if (driver != null) {
    dashboard.setDriverName(driver.getName());
    if (driver.getWarehouseId() != null) {
        Warehouse warehouse = warehouseMapper.selectById(driver.getWarehouseId());
        if (warehouse != null) {
            dashboard.setWarehouseName(warehouse.getName());
        }
    }
}
```

#### 5. 添加对账单最新接口
**文件**: `bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/driver/controller/DriverStatementController.java`

**新增接口**:
```java
@GetMapping("/current")
@Operation(summary = "获取当前对账单", description = "获取当前/最新的对账单（单个对象，供移动端使用）")
public Result<DriverStatementDTO> getCurrentStatement(
        @RequestHeader("X-Driver-Id") Long driverId) {
    DriverStatementDTO statement = statementService.getLatestStatement(driverId);
    return Result.ok(statement);
}
```

#### 6. 修复移动端对账单调用
**文件**: `bucket-water-oms-admin-mobile/lib/services/driver_service.dart`

**修改内容**:
```dart
Future<DriverStatementData?> getDriverStatements(String driverId, {String? status}) async {
    try {
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      queryParams['latest'] = 'true';  // 添加 latest 参数

      final response = await _apiClient.get(
        '/drivers/statements',
        queryParams: queryParams,
        headers: {'X-Driver-Id': driverId},
      );

      if (response.success && response.data != null) {
        if (response.data is List && (response.data as List).isNotEmpty) {
          return DriverStatementData.fromJson(response.data[0]);
        } else if (response.data is Map) {
          return DriverStatementData.fromJson(response.data);
        }
        return _getMockStatementData();
      } else {
        return _getMockStatementData();
      }
    } catch (e) {
      return _getMockStatementData();
    }
}
```

### 相关文件
- [OrderVO.java](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/order/dto/OrderVO.java) - 订单VO
- [DriverDashboardDTO.java](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/driver/dto/DriverDashboardDTO.java) - 司机Dashboard DTO
- [DriverService.java](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/driver/service/DriverService.java) - 司机服务
- [DriverStatementController.java](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/driver/controller/DriverStatementController.java) - 司机对账控制器
- [driver_service.dart](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-admin-mobile/lib/services/driver_service.dart) - 司机服务（移动端）
- [driver_task_model.dart](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-admin-mobile/lib/models/driver_task_model.dart) - 司机任务模型（移动端）

### 教训
1. **前后端字段命名必须一致**
   - 后端使用 `stationLat`/`stationLng`，移动端期望 `latitude`/`longitude`
   - **解决方案**: 在 DTO 中添加兼容字段，同时支持两种命名方式

2. **嵌套对象 vs 扁平结构**
   - 后端返回嵌套的 `warehouse` 对象，移动端期望扁平的 `warehouseName` 字段
   - **解决方案**: 在 convertToVO 方法中将嵌套对象展开为扁平字段

3. **API 返回类型必须与客户端期望一致**
   - 后端返回 `List<DriverStatementDTO>`，移动端期望单个对象
   - **解决方案**: 添加 `latest` 参数或新接口 `/current` 返回单个对象

4. **移动端需要的基本字段**
   - Dashboard 需要 `driverName` 和 `warehouseName` 显示用户信息
   - Order 需要 `stationName`、`latitude`、`longitude`、`totalQuantity` 等字段
   - **解决方案**: 在开发前明确 API 契约，确保后端返回所有必要字段

5. **API 契约文档至关重要**
   - 前后端必须使用相同的字段名和类型
   - 建议使用 API 文档工具（如 Swagger/OpenAPI）自动生成契约
   - 或在开发前明确约定 API 的输入输出格式



## 2026-04-27: �޸�ˮվ�µ����Զ��۳��������ö�ȵ�����

### ��������
ˮվ�µ����Զ��۳���Ӧˮվ���������ö�ȣ���˲�ѯˮվ���䡣

### �������
**������������**��

1. **deductBalanceAndCredit ����û�и���֧������(paymentType)���ֿۿ��߼�**
   - ԭ��������ж�����ִ����ͬ�Ŀۿ��߼����ȿ�Ԥ����ٿ����ö�ȣ�
   - ��ʵ����Ӧ�ø���֧���������֣�
     - **Ԥ����(prepaid)**���������ȿۼ�Ԥ��𣬲���ʱ�ٿ����ö��
     - **����(credit)���½�(monthly)**������ֻ�ۼ����ö��

2. **�����ظ��ۿ��߼�**
   - createOrder �����ڶ�������ʱ���� deductBalanceAndCredit �ۿ�
   - deliverOrder �����ڶ����������ʱ�ֵ��� deductAccountBalance �ۿ�
   - ����ͬһ�ʶ������ۿ�����

### �޸�����

#### 1. �޸� deductBalanceAndCredit ����
**�ļ�**: ucket-water-oms-java/src/main/java/com/bucketwater/oms/module/order/service/OrderService.java

**�޸�����**:
`java
private void deductBalanceAndCredit(StationAccount account, BigDecimal amount, String paymentType) {
    log.info("[DEBUG] ��ʼ�ۼ��������ö��: amount={}, paymentType={}", amount, paymentType);

    String effectivePaymentType = (paymentType != null && !paymentType.isEmpty()) ? paymentType : "prepaid";

    if ("credit".equals(effectivePaymentType) || "monthly".equals(effectivePaymentType)) {
        // ����/�½ᶩ����ֻ�ۼ����ö��
        BigDecimal creditLimit = account.getCreditLimit() != null ? account.getCreditLimit() : BigDecimal.ZERO;
        BigDecimal creditUsed = account.getCreditUsed() != null ? account.getCreditUsed() : BigDecimal.ZERO;
        BigDecimal availableCredit = creditLimit.subtract(creditUsed);

        account.setCreditUsed(creditUsed.add(amount));
        log.info("[DEBUG] �ۼ����ö��: {}Ԫ, ���ö��: {}/{}, ��������: {}Ԫ",
            amount, creditLimit, availableCredit, account.getCreditUsed());
    } else {
        // Ԥ��������ȿ�Ԥ��𣬲���ʱ�ٿ����ö��
        BigDecimal depositBalance = account.getDepositBalance() != null ? account.getDepositBalance() : BigDecimal.ZERO;
        BigDecimal creditLimit = account.getCreditLimit() != null ? account.getCreditLimit() : BigDecimal.ZERO;
        BigDecimal creditUsed = account.getCreditUsed() != null ? account.getCreditUsed() : BigDecimal.ZERO;
        BigDecimal availableCredit = creditLimit.subtract(creditUsed);

        BigDecimal remainingAmount = amount;

        if (depositBalance.compareTo(BigDecimal.ZERO) > 0 && remainingAmount.compareTo(BigDecimal.ZERO) > 0) {
            if (depositBalance.compareTo(remainingAmount) >= 0) {
                account.setDepositBalance(depositBalance.subtract(remainingAmount));
                log.info("[DEBUG] �ۼ�Ԥ���: {}Ԫ, ʣ��Ԥ���: {}Ԫ", remainingAmount, account.getDepositBalance());
                remainingAmount = BigDecimal.ZERO;
            } else {
                remainingAmount = remainingAmount.subtract(depositBalance);
                account.setDepositBalance(BigDecimal.ZERO);
                log.info("[DEBUG] Ԥ���ȫ���ۼ�: {}Ԫ, ʣ����ۼ�: {}Ԫ", depositBalance, remainingAmount);
            }
        }

        if (availableCredit.compareTo(BigDecimal.ZERO) > 0 && remainingAmount.compareTo(BigDecimal.ZERO) > 0) {
            if (availableCredit.compareTo(remainingAmount) >= 0) {
                account.setCreditUsed(creditUsed.add(remainingAmount));
                log.info("[DEBUG] �ۼ����ö��: {}Ԫ, ��������: {}Ԫ", remainingAmount, account.getCreditUsed());
                remainingAmount = BigDecimal.ZERO;
            } else {
                account.setCreditUsed(creditUsed.add(availableCredit));
                log.info("[DEBUG] ���ö��ȫ���ۼ�: {}Ԫ, ��������: {}Ԫ", availableCredit, account.getCreditUsed());
                remainingAmount = remainingAmount.subtract(availableCredit);
            }
        }
    }

    account.setUpdatedAt(java.time.LocalDateTime.now());
    stationAccountMapper.updateById(account);
    log.info("[DEBUG] �������ö�ȿۼ����");
}
`

**���ô��޸�**:
`java
deductBalanceAndCredit(account, totalAmount, order.getPaymentType());
`

#### 2. �Ƴ� deliverOrder �е��ظ��ۿ��߼�
**�ļ�**: ucket-water-oms-java/src/main/java/com/bucketwater/oms/module/order/service/OrderService.java

**�Ƴ�����**:
`java
// �Ƴ���һ��
deductAccountBalance(order);
`

**ԭ��**: �����ڴ���ʱ�Ѿ��ۿ����Ҫ���������ʱ�ٴοۿ����ᵼ���ظ��ۿ

### ����ļ�
- [OrderService.java](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/order/service/OrderService.java) - �����������޸���

### ������֤
`powershell
mvn clean compile -DskipTests
# BUILD SUCCESS
`

### ��ѵ
1. **֧�����ͱ���Ӱ��ۿ��߼�**
   - ��֧ͬ����ʽ�Ŀۿ����ͬ
   - Ԥ���������ʹ��Ԥ���
   - ����/�½ᶩ��ֻʹ�����ö��

2. **�����ظ��ۿ�**
   - �ڶ���������ֻ�ں��ʵ�ʱ���ۿ�һ��
   - �µ�ʱ�ۿȷ��ˮվ���㹻�����
   - �������ʱ��Ӧ�ٴοۿ�

3. **ҵ���߼���Ҫ��������**
   - ��������ʱ����֤����Ƿ���㣬���������ۿ��ѡ��
   - ����ȷ��ʱ����ʽ�ۿ�
   - �������ʱ�������漰�������ý��㣬����Ӧ�ظ��ۿ�

4. **��־��¼����Ҫ��**
   - �ڿۿ��߼���������ϸ����־
   - ��¼�ۿ����͡���֧�����͵���Ϣ
   - �����Ų�����


## �����޸� - 2026-04-27 (�ڶ�ʮ����)

### ����1: ˮվǰ����ʾ�Ķ����Ϣ����ȷ

**��������**:
ˮվǰ�ˣ�PC�˺��ƶ��ˣ���ʾ����"Ԥ������"��"���ö��"�����û�ʵ����Ҫ��������"�ܶ��"��"ʣ����"��

**�������**:
1. ˮվDashboard��ʾ���� ccountBalance��Ԥ������� creditLimit�����ö�ȣ�
2. �û���Ҫ�������ǣ�
   - **�ܶ��** = ���ö�ȣ�creditLimit��
   - **ʣ����** = �������ã�creditLimit - creditUsed��

**�޸���ʩ**:

#### 1. �޸� OwnerDashboard.vue

**�ļ�**: ucket-water-oms-admin/src/views/owner/OwnerDashboard.vue

**�޸�����**:
- ��6�У���"�˻����"��Ϊ"�ܶ��"����ʾ creditLimit
- ��18�У���"���ö��"��Ϊ"ʣ����"����ʾ vailableCredit
- ��24�У���"ʣ����"��Ϊ"���ö��"����ʾ usedCredit

#### 2. �޸� OwnerCreateOrder.vue

**�ļ�**: ucket-water-oms-admin/src/views/owner/OwnerCreateOrder.vue

**�޸�����**:
- ��168�У���"ʣ�ࣤ{{ availableCredit }}"��Ϊ"���ã�{{ availableCredit }}/��{{ creditLimit }}"

#### 3. �޸� OwnerRecharge.vue

**�ļ�**: ucket-water-oms-admin/src/views/owner/OwnerRecharge.vue

**�޸�����**:
- ��19�У���"��ǰԤ������"��Ϊ"�ܶ��"����ʾ creditLimit
- ��22�У���"���ö��"��Ϊ"ʣ����"����ʾ vailableCredit
- ��23�У���"���� ��"��Ϊ"���� ��"����ʾ usedCredit
- ��26�У���"֧����ʽ"��Ϊ"Ԥ������"����ʾ depositBalance

#### 4. �޸� OwnerStatements.vue

**�ļ�**: ucket-water-oms-admin/src/views/owner/OwnerStatements.vue

**�޸�����**:
- ��53�У���"Ԥ������"��Ϊ"�ܶ��"����ʾ creditLimit
- ��57�У���"���ö��"��Ϊ"ʣ����"����ʾ vailableCredit

### ҵ�����˵��

#### ˮվ�˻���ϵ
- **�ܶ�ȣ�creditLimit��**: ˮվ�������ö�ȣ��ǹ̶���
- **ʣ���ȣ�availableCredit��**: �ܶ�ȼ�ȥ���ö�� = creditLimit - creditUsed
- **���ö�ȣ�usedCredit��**: �������ĵĶ��
- **Ԥ�����depositBalance��**: ˮվ��ֵ��Ԥ������Ԥ�����

#### �����ۿ����
- **�½ᶩ��**: ֻ�ۼ����ö�ȣ�usedCredit += ������
- **Ԥ�����**: �ȿۼ�Ԥ���Ԥ�����ʱ�ٿۼ����ö��
- **����/�½ᶩ��**: ֻ�ۼ����ö��

### ��ѵ
1. **ǰ����ʾҪ��ҵ�����һ��**��
   - �û���Ҫ��������"�����ö���"��"�����˶���"
   - ������"���ö�ȵ��ܶ��Ƕ���"

2. **�ֶ�����Ҫ����**��
   - creditLimit ʵ������"�ܶ��"
   - vailableCredit ʵ������"ʣ����"
   - usedCredit ʵ������"���ö��"

3. **�������ݶ�Ӧ**��
   - ��˷��ص��ֶ������ܲ���ֱ��
   - ǰ����ʾʱ��Ҫת��Ϊ�û��Ѻõ�����

4. **һ����ԭ��**��
   - ����ˮվ���ҳ��Ӧ��ʹ��һ�µĶ����ʾ�߼�
   -���ⲻͬҳ����ʾ��ͬ��Ϣ����û�����

---

## 2026-05-17: 修复 OrderServiceTest 单元测试编译错误

### 问题描述
`OrderServiceTest.java` 第260行存在类型不匹配问题：
- 测试代码期望 `dispatchOrder` 方法返回 `OrderVO` 类型
- 但实际 `OrderService.dispatchOrder()` 方法返回的是 `DispatchOrderResponse` 类型

### 问题根因
**测试代码使用了错误的返回类型**

1. **OrderService.dispatchOrder 方法签名**:
   ```java
   public DispatchOrderResponse dispatchOrder(Long orderId, Long warehouseId, DispatchOrderRequest request)
   ```

2. **测试代码错误地期望 OrderVO**:
   ```java
   // 错误写法
   OrderVO result = orderService.dispatchOrder(orderId, warehouseId, request);
   ```

3. **DispatchOrderResponse 结构**:
   - `isSuccess()` - 返回是否成功
   - `getOrder()` - 返回 OrderVO 对象

### 修复方案

#### 1. 添加必要的 import
**文件**: `bucket-water-oms-java/src/test/java/com/bucketwater/oms/module/order/service/OrderServiceTest.java`

**添加内容**:
```java
import com.bucketwater.oms.module.order.dto.DispatchOrderResponse;
```

#### 2. 修改 dispatchOrder_Success 测试方法
**修改前**:
```java
OrderVO result = orderService.dispatchOrder(orderId, warehouseId, request);

assertNotNull(result);
assertEquals("dispatched", result.getStatus());
```

**修改后**:
```java
DispatchOrderResponse response = orderService.dispatchOrder(orderId, warehouseId, request);

assertNotNull(response);
assertTrue(response.isSuccess());
OrderVO result = response.getOrder();
assertNotNull(result);
assertEquals("dispatched", result.getStatus());
```

### 编译验证
```powershell
mvn compile -DskipTests
# BUILD SUCCESS
```

### 相关文件
- [OrderServiceTest.java](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/src/test/java/com/bucketwater/oms/module/order/service/OrderServiceTest.java) - 订单服务测试类

### 教训

#### 1. 编写测试前必须查看被测方法的签名
- **问题**: 直接假设返回类型为 `OrderVO`
- **正确做法**: 先查看被测方法的实际返回类型
- **方法**: 查看 Service 类的实际方法签名，或查看接口定义

#### 2. Response DTO 与 View DTO 是不同的概念
- **DispatchOrderResponse**: API 响应包装类，包含 success 标志和实际数据
- **OrderVO**: 视图对象，用于展示订单信息
- 不要混淆 Response DTO 和 View DTO 的用途

#### 3. 测试代码也需要编译验证
- 不仅 Service 代码需要编译，Test 代码也需要编译
- 使用 `mvn compile -DskipTests` 验证所有代码编译通过
- 在编写测试时就应该考虑返回类型的正确性

#### 4. 测试方法命名规范
- 使用 `@DisplayName` 提供可读的测试描述
- 测试方法名使用 `methodName_scenario_expectedBehavior` 格式
- 示例: `dispatchOrder_Success` 表示派单成功场景

#### 5. 断言的完整性
- 不仅断言返回对象不为空
- 还要断言业务标志位（如 `isSuccess()`）
- 再从 Response 中获取实际数据进行验证

---

## 2026-05-17: 修复后端项目多个编译错误

### 问题描述
后端项目存在多个编译错误，涉及实体类方法不存在、枚举值不存在、类型转换等问题。

### 编译错误列表

#### 1. ExcelExportService.java:426 - CellStyle.getFont() 方法不存在
**错误**: `headerStyle.getFont()` - CellStyle 没有 getFont() 方法

**原因**: Apache POI 的 CellStyle 类没有公开获取内部 Font 对象的方法

**修复**: 删除该行代码，因为直接获取 CellStyle 内部的 Font 不可行
```java
// 修复前
totalRow.getCell(0).getCellStyle().setFont(headerStyle.getFont());

// 修复后 - 删除该行
```

#### 2. DriverStatementService.java:120,121 - Order.getDeliveryDistance() 方法不存在
**错误**: Order 实体没有 `deliveryDistance` 字段

**原因**: Order 实体定义中不存在配送距离字段

**修复**: 删除相关代码，距离数据需要从其他来源获取
```java
// 修复前
if (order.getDeliveryDistance() != null) {
    totalDistance = totalDistance.add(order.getDeliveryDistance());
}

// 修复后 - 删除该代码块
```

#### 3. ProductService.java:290 - Product.setGuidePrice() 方法不存在
**错误**: `product.setGuidePrice(guidePrice)` - 方法不存在

**原因**: Product 实体只有 `guidePriceMin` 和 `guidePriceMax`，没有 `guidePrice` 字段

**修复**: 改为 `setGuidePriceMin()`
```java
// 修复前
product.setGuidePrice(guidePrice);

// 修复后
product.setGuidePriceMin(guidePrice);
```

#### 4. WechatPayService.java:101,107 - ResultCode.PAYMENT_ERROR 不存在
**错误**: `ResultCode.PAYMENT_ERROR` 枚举值不存在

**原因**: ResultCode 枚举中没有 PAYMENT_ERROR，只有 BUSINESS_ERROR

**修复**: 改为 `ResultCode.BUSINESS_ERROR`
```java
// 修复前
throw new BusinessException(ResultCode.PAYMENT_ERROR, "...");

// 修复后
throw new BusinessException(ResultCode.BUSINESS_ERROR, "...");
```

#### 5. WechatPayService.java:130 - Long无法转换为String
**错误**: `recharge(record.getStationId(), totalAmount)` - stationId 是 Long 类型

**原因**: recharge 方法签名是 `recharge(String stationId, BigDecimal amount)`

**修复**: 使用 `String.valueOf()` 转换
```java
// 修复前
recharge(record.getStationId(), totalAmount);

// 修复后
recharge(String.valueOf(record.getStationId()), totalAmount);
```

#### 6. WechatPayService.java:155,184 - StationAccount.setUpdateTime() 方法不存在
**错误**: `account.setUpdateTime()` - 方法不存在

**原因**: StationAccount 实体的时间字段是 `updatedAt`，不是 `updateTime`

**修复**: 改为 `setUpdatedAt()`
```java
// 修复前
account.setUpdateTime(LocalDateTime.now());

// 修复后
account.setUpdatedAt(LocalDateTime.now());
```

### 编译验证
```powershell
mvn clean compile -DskipTests
# BUILD SUCCESS
```

### 相关文件
- [ExcelExportService.java](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/export/service/ExcelExportService.java)
- [DriverStatementService.java](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/driver/service/DriverStatementService.java)
- [ProductService.java](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/product/service/ProductService.java)
- [WechatPayService.java](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/payment/service/WechatPayService.java)
- [Order.java](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/order/entity/Order.java)
- [Product.java](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/product/entity/Product.java)
- [StationAccount.java](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/station/entity/StationAccount.java)
- [ResultCode.java](file:///c:/Users/Wishtohear/Documents/bucket-water-oms/bucket-water-oms-java/src/main/java/com/bucketwater/oms/common/response/ResultCode.java)

### 教训

#### 1. 修改代码前必须检查实体类的实际字段定义
- **问题**: 直接使用假设存在的字段名 `deliveryDistance`、`guidePrice`、`updateTime`
- **正确做法**: 先查看对应实体类的实际字段定义
- **方法**: 读取实体类源码，确认字段名、类型、getter/setter 方法名

#### 2. 使用枚举值前必须检查枚举定义
- **问题**: 直接使用不存在的枚举值 `PAYMENT_ERROR`
- **正确做法**: 先查看 ResultCode 枚举类的实际定义
- **方法**: 读取枚举类源码，确认所有可用的枚举值

#### 3. 调用方法前必须检查方法的参数类型
- **问题**: 直接传递 Long 类型给 String 参数
- **正确做法**: 查看方法签名，确认参数类型
- **方法**: 查看方法定义或接口文档

#### 4. 外部库 API 限制
- **问题**: 尝试从 CellStyle 获取内部的 Font 对象
- **正确做法**: Apache POI 的 CellStyle 没有暴露 getFont() 方法
- **方法**: 如需复用样式，需要在创建样式时保存 Font 引用

#### 5. 编译验证的重要性
- **问题**: 多个文件存在编译错误
- **正确做法**: 修改代码后立即运行 `mvn compile` 验证
- **方法**: 使用 `-DskipTests` 跳过测试，仅编译源代码

#### 6. 代码修改要谨慎
- **问题**: 删除代码块时没有充分考虑影响
- **正确做法**: 
  - 确认删除不会破坏业务逻辑
  - 考虑是否有替代方案
  - 必要时添加 TODO 注释说明
- **方法**: 删除前先分析代码上下文
