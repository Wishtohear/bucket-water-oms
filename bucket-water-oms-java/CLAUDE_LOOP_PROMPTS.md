# 水厂订货管理系统 - Claude Code 循环提示词集

> 基于 `水厂订货管理系统.md` PRD v1.2 生成的 Claude Code 迭代开发提示词

---

## 目录

- [快速开始](#快速开始)
- [测试覆盖率提升循环](#测试覆盖率提升循环)
- [前后端联调循环](#前后端联调循环)
- [核心业务流程开发循环](#核心业务流程开发循环)
- [模块专项开发循环](#模块专项开发循环)
- [常用任务模板](#常用任务模板)

---

## 快速开始

### 项目信息

| 项目 | 路径 |
|------|------|
| 后端 | `c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-java\` |
| PC前端 | `c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin\` |
| 移动端 | `c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\` |
| 开发文档 | `c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-java\水厂订货管理系统.md` |
| 开发记录 | `c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin\AGENTS.md` |

### 快速验证命令

```powershell
# 后端编译
cd c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-java
mvn clean compile -DskipTests

# 后端测试
mvn test

# 后端覆盖率
mvn test jacoco:report
# 报告位置: target/site/jacoco/index.html

# PC前端类型检查
cd c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin
npm run type-check

# 移动端分析
cd c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile
flutter analyze
```

---

## 测试覆盖率提升循环

### 完整循环提示词

```markdown
/rallph-loop "将 bucket-water-oms-java/src/ 下业务代码的测试覆盖率提升至 ≥90%

步骤：
1. 运行 mvn test jacoco:report 生成覆盖率报告
2. 分析 target/site/jacoco/index.html 找出未覆盖的类和方法
3. 为未覆盖的业务逻辑编写单元测试
4. 重复直到覆盖率达标

重点覆盖模块（按优先级）：
1. order/OrderService - 订单创建、状态流转、扣款逻辑
2. station/StationService - 水站账户、水站定价
3. driver/DriverService - 配送流程、位置管理
4. warehouse/WarehouseService - 接单拒单、派单
5. bucket/BucketService - 空桶流水、差异处理
6. statement/StatementService - 对账单生成
7. aftersales/AfterSalesService - 售后处理

测试模板：
```java
@ExtendWith(MockitoExtension.class)
class {ServiceName}Test {
    @Mock private {Repository} {repository};
    private {Service} {service};

    @BeforeEach
    void setUp() {
        {service} = new {Service}({repository});
    }

    @Test
    @DisplayName(\"{测试场景描述}\")
    void {methodName}_{scenario}_{expectedResult}() {
        // Given - 准备测试数据
        {准备测试数据}

        // When - 执行方法
        {执行方法}

        // Then - 验证结果
        {验证结果}
        verify({repository}).{验证方法调用};
    }
}
```

完成后输出：
✅DONE
覆盖率报告路径: target/site/jacoco/index.html
" \
--max-iterations 20 \
--completion-promise "✅DONE"
```

### 按模块测试覆盖率提升

```markdown
/rallph-loop "将 bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/{MODULE}/ 的测试覆盖率提升至 ≥90%

步骤：
1. 运行 mvn test -Dtest=**/{MODULE}/**/*Test jacoco:report
2. 分析覆盖率报告找出未覆盖方法
3. 编写测试覆盖以下场景：
   - 正常流程
   - 异常情况（数据不存在、参数错误）
   - 边界条件
   - 事务回滚
4. 重复直到覆盖率达标

{MODULE}模块关键业务逻辑：
- {列出关键方法和业务规则}

完成后输出：✅DONE
" \
--max-iterations 10 \
--completion-promise "✅DONE"
```

---

## 前后端联调循环

### 完整联调循环

```markdown
/rallph-loop "对 {MODULE} 模块进行前后端联调

步骤：
1. 检查后端 Controller 接口定义和参数
2. 对比前端 API 调用是否匹配
3. 检查数据模型字段是否一致
4. 修复不匹配的地方
5. 运行后端 mvn compile 和前端 npm run type-check
6. 如有移动端，同时检查移动端模型

后端路径: bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/{MODULE}/
PC前端路径: bucket-water-oms-admin/src/
移动端路径: bucket-water-oms-admin-mobile/lib/

联调检查清单：
□ Controller 方法有 @Operation 注解
□ 响应使用 Result<T> 包装
□ 前端 API 路径与后端一致
□ DTO 字段命名前后端一致
□ 分页使用 PageResult<T>
□ 错误码使用 ResultCode

完成后输出：✅DONE
" \
--max-iterations 15 \
--completion-promise "✅DONE"
```

### 字段匹配联调

```markdown
/rallph-loop "检查并修复 {MODULE} 模块前后端字段不匹配问题

步骤：
1. 读取后端 DTO 类定义
2. 对比前端模型类
3. 修复字段名不一致问题
4. 确保移动端兼容字段存在

常见不匹配问题（参考 AGENTS.md）：
- stationLat/stationLng vs latitude/longitude
- 嵌套对象 vs 扁平字段
- List<Object> vs 单个对象

完成后输出：✅DONE
" \
--max-iterations 5 \
--completion-promise "✅DONE"
```

---

## 核心业务流程开发循环

### 订单流程开发

```markdown
/rallph-loop "实现水厂订货管理系统的订单流程功能

订单流程（参考 PRD 第三章）：
水站下单 → 仓库接单 → 备货 → 派单 → 司机配送 → 完成配送 → 回仓核对

需要开发的功能：
1. 订单创建（station/OrderService）
   - 库存检查
   - 余额/额度检查
   - 欠桶阈值检查
   - 水站独立定价

2. 订单状态流转（order/OrderService）
   - PENDING_REVIEW → REVIEWED → DISPATCHED → DELIVERING → COMPLETED
   - CANCELLED / REJECTED

3. 仓库接单（warehouse/WarehouseService）
   - 接单审查
   - 拒单处理
   - 备货管理
   - 派单给司机

4. 司机配送（driver/DriverService）
   - 开始配送
   - GPS打卡
   - 卸货核对
   - 回桶/欠桶录入
   - 电子签收

5. 账户扣款（order/OrderService）
   - 预存金扣款（配送完成时）
   - 月结扣款（增加已用额度）

步骤：
1. 阅读 PRD 相关章节
2. 实现后端 Service 层
3. 编写单元测试
4. 实现 Controller
5. 前端页面集成
6. 编译验证

完成后输出：✅DONE
" \
--max-iterations 30 \
--completion-promise "✅DONE"
```

### 空桶管理流程开发

```markdown
/rallph-loop "实现水厂订货管理系统的空桶管理功能

空桶流程（参考 PRD 第四章 4.3.3）：
司机回仓申请 → 仓库清点 → 差异核对 → 确认入库

需要开发的功能：
1. 空桶流水记录（bucket/BucketService）
   - 回桶（RETURN）
   - 欠桶（OWED）
   - 押金收取（DEPOSIT）
   - 补缴押金（DEPOSIT_REFUND）
   - 差异赔偿（DIFF_COMPENSATION）

2. 差异处理规则：
   - 司机上报 = 仓库实收 → 正常入库
   - 司机上报 > 仓库实收 → 多报赔偿
   - 司机上报 < 仓库实收 → 少报赔偿

3. 赔偿金额计算：
   - 差异数量 × 每桶押金金额

步骤：
1. 实现 BucketTransaction 实体和 Mapper
2. 实现流水记录 Service
3. 实现回仓核对功能
4. 实现差异处理逻辑
5. 编写测试覆盖所有流水类型
6. 前后端联调

完成后输出：✅DONE
" \
--max-iterations 20 \
--completion-promise "✅DONE"
```

### 对账流程开发

```markdown
/rallph-loop "实现水厂订货管理系统的对账功能

对账流程（参考 PRD 第四章 4.2.4）：
每月固定日期生成对账单 → 水站确认 → 有异议可提交

需要开发的功能：
1. 对账单生成（statement/StatementService）
   - 每月固定日期凌晨2点生成
   - 账期范围：上月1日至月末
   - 内容：期初余额、本月明细、回款、期末余额

2. 对账单确认（statement/StatementService）
   - 水站确认对账单
   - 有异议标记 DISPUTED
   - 记录确认日期

3. 司机对账单（driver/DriverStatementService）
   - 配送单数、桶数统计
   - 里程、里程补助
   - 差异赔偿记录

步骤：
1. 实现 MonthlyStatement 实体
2. 实现对账单生成逻辑
3. 实现定时任务（每月生成）
4. 实现对账单确认/异议
5. 实现司机对账单
6. 前后端联调

完成后输出：✅DONE
" \
--max-iterations 25 \
--completion-promise "✅DONE"
```

---

## 模块专项开发循环

### 水站端功能开发

```markdown
/rallph-loop "为水站端开发 {FEATURE_NAME} 功能

参考：PRD 第四章 4.2 水站端

功能描述：
{FEATURE_DESCRIPTION}

权限说明（参考 PRD 第二章 2.3.1）：
- 水站老板：完整权限
- 水站店员：仅查看库存、收货确认

需要修改的文件：
后端：
- module/station/controller/StationController.java
- module/station/service/StationService.java
- module/station/dto/ (如需)

PC前端：
- src/views/owner/Owner{Page}.vue
- src/api/stationOwner.ts

移动端：
- lib/pages/owner/owner_{page}.dart
- lib/services/station_service.dart
- lib/models/station_model.dart

步骤：
1. 阅读 PRD 相关章节
2. 实现后端 API
3. 编写单元测试
4. 前端页面开发
5. 编译验证

完成后输出：✅DONE
" \
--max-iterations 15 \
--completion-promise "✅DONE"
```

### 仓库端功能开发

```markdown
/rallph-loop "为仓库端开发 {FEATURE_NAME} 功能

参考：PRD 第四章 4.3 仓库端

功能描述：
{FEATURE_DESCRIPTION}

需要修改的文件：
后端：
- module/warehouse/controller/WarehouseController.java
- module/warehouse/service/WarehouseService.java
- module/bucket/ (如涉及空桶)

PC前端：
- src/views/warehouse/Warehouse{Page}.vue
- src/api/warehouse.ts

移动端：
- lib/pages/warehouse/warehouse_{page}.dart
- lib/services/warehouse_service.dart

步骤：
1. 阅读 PRD 相关章节
2. 实现后端 API
3. 编写单元测试
4. 前端页面开发
5. 编译验证

完成后输出：✅DONE
" \
--max-iterations 15 \
--completion-promise "✅DONE"
```

### 司机端功能开发

```markdown
/rallph-loop "为司机端开发 {FEATURE_NAME} 功能

参考：PRD 第四章 4.4 司机端

功能描述：
{FEATURE_DESCRIPTION}

司机状态说明：
- online：在线，正常接单配送
- offline：离线，不接单
- break：休息中，暂停接单

位置管理：
- 心跳间隔：5分钟
- 离线超时：10分钟
- GPS 位置上报

需要修改的文件：
后端：
- module/driver/controller/DriverController.java
- module/driver/service/DriverService.java

移动端：
- lib/pages/driver/driver_{page}.dart
- lib/services/driver_service.dart
- lib/models/driver_task_model.dart

步骤：
1. 阅读 PRD 相关章节
2. 实现后端 API
3. 编写单元测试
4. 移动端页面开发
5. 编译验证

完成后输出：✅DONE
" \
--max-iterations 15 \
--completion-promise "✅DONE"
```

---

## 常用任务模板

### Bug修复循环

```markdown
/rallph-loop "修复 {BUG_DESCRIPTION}

问题描述：
{BUG_DESCRIPTION}

问题原因：
{ROOT_CAUSE}

复现步骤：
1. {STEP1}
2. {STEP2}
3. {STEP3}

修复步骤：
1. 定位问题代码
2. 分析问题原因
3. 编写修复代码
4. 添加回归测试防止复现
5. 运行测试验证修复

相关文件：
- {FILE1}
- {FILE2}

完成后输出：✅DONE
" \
--max-iterations 5 \
--completion-promise "✅DONE"
```

### 性能优化循环

```markdown
/rallph-loop "优化 {MODULE} 模块性能

优化目标：
1. 接口响应时间 < 200ms
2. 数据库查询优化（N+1问题）
3. 减少不必要的数据加载

优化步骤：
1. 使用 Arthas/Dynamic Tracing 分析慢查询
2. 使用 explain 分析 SQL 执行计划
3. 添加适当索引
4. 使用缓存（Redis）
5. 优化代码逻辑
6. 性能测试验证

完成后输出：✅DONE
" \
--max-iterations 10 \
--completion-promise "✅DONE"
```

### 安全审计循环

```markdown
/rallph-loop "对 {MODULE} 模块进行安全审计

审计要点（参考 AGENTS.md 安全相关记录）：
1. 密码必须 BCrypt 加密存储
2. SQL 注入防护（参数化查询）
3. XSS 防护
4. 权限验证
5. 敏感数据脱敏
6. 日志不记录敏感信息

审计步骤：
1. 代码审查
2. 查找安全漏洞
3. 修复安全问题
4. 添加安全测试
5. 验证修复

完成后输出：✅DONE
" \
--max-iterations 10 \
--completion-promise "✅DONE"
```

---

## 历史经验参考

### 常见问题速查

| 问题 | 参考记录 | 解决方案 |
|------|----------|----------|
| 登录失败 | AGENTS.md 2026-04-23 | 修改后端支持不带role登录 |
| 密码不匹配 | AGENTS.md 2026-04-24 | 所有密码必须BCrypt加密 |
| Region表不存在 | AGENTS.md 2026-04-21 | 添加deleted字段，执行SQL脚本 |
| 前后端字段不匹配 | AGENTS.md 2026-04-24 | 添加兼容字段如latitude/longitude |
| 账户扣款重复 | AGENTS.md 2026-04-27 | 移除重复扣款逻辑 |
| 账户显示不正确 | AGENTS.md 2026-04-27 | 修改字段名为业务含义 |

### 代码规范

1. **密码处理**
   - 所有密码必须 BCrypt 加密
   - 使用 `passwordEncoder.encode(password)`
   - 验证使用 `passwordEncoder.matches(raw, encoded)`

2. **日志记录**
   - 关键业务操作记录日志
   - 使用 `log.info("[模块] 操作: {}", params)`
   - 敏感信息不记录

3. **事务管理**
   - 涉及多表操作使用 `@Transactional`
   - 库存更新、扣款等必须事务保证

4. **异常处理**
   - 使用 `BusinessException(ResultCode.XXX)`
   - 统一使用 `Result<T>` 包装响应
   - 不暴露内部错误信息

---

## 版本信息

- 版本：v1.0
- 生成日期：2026-04-28
- 基于：PRD v1.2
