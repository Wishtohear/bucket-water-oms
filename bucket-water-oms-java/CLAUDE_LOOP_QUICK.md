# 水厂订货管理系统 - Claude Code 快速循环提示词

## 使用方法

将以下内容复制到 Claude Code 中执行：

---

### 1. 测试覆盖率提升（参考用户示例）

```
/ralph-loop "将 src/main/java/com/bucketwater/oms/ 下业务代码的测试覆盖率提升至 ≥90%

步骤：
1. 运行 mvn test jacoco:report 生成覆盖率报告
2. 分析 target/site/jacoco/index.html 找出未覆盖的类和方法
3. 为未覆盖的业务逻辑编写单元测试（使用 JUnit 5 + Mockito）
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

    @BeforeEach void setUp() { {service} = new {Service}({repository}); }

    @Test @DisplayName(\"{场景描述}\")
    void {method}_{scenario}_{expected}() {
        // Given
        when({repository}.{方法}).thenReturn({数据});
        // When
        var result = {service}.{方法}({参数});
        // Then
        assertThat(result).{断言};
        verify({repository}).{验证方法}({参数});
    }
}
```

开发文档：c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-java\水厂订货管理系统.md
编译命令：mvn clean compile -DskipTests

完成后输出：✅DONE" \
--max-iterations 20 \
--completion-promise "✅DONE"
```

---

### 2. 前后端联调

```
/ralph-loop "对 {MODULE} 模块进行前后端联调

步骤：
1. 读取后端 Controller 接口定义（module/{module}/controller/）
2. 对比前端 API 调用（bucket-water-oms-admin/src/api/）
3. 检查移动端模型（bucket-water-oms-admin-mobile/lib/models/）
4. 修复字段名不匹配问题（参考 OrderVO 的兼容字段设计）
5. 运行验证：
   - 后端：mvn clean compile -DskipTests
   - PC前端：npm run type-check（需在 admin 目录）
   - 移动端：flutter analyze（需在 mobile 目录）

联调检查清单：
□ Controller 有 @Operation 注解
□ 响应使用 Result<T> 包装
□ 前端 API 路径与后端一致
□ 字段命名一致（stationLat→latitude, 嵌套→扁平）
□ 分页使用 PageResult<T>
□ 错误码使用 ResultCode

开发文档：c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-java\水厂订货管理系统.md

完成后输出：✅DONE" \
--max-iterations 15 \
--completion-promise "✅DONE"
```

---

### 3. 核心功能开发

```
/ralph-loop "开发 {FEATURE_NAME} 功能

参考文档：bucket-water-oms-java/水厂订货管理系统.md 第{CHAPTER}章

功能描述：
{FEATURE_DESCRIPTION}

实现步骤：
1. 阅读 PRD 相关章节
2. 创建/完善实体类（entity/）
3. 创建/完善 DTO 类（dto/）
4. 创建/完善 Mapper 接口（mapper/）
5. 实现 Service 层业务逻辑
6. 编写单元测试（覆盖率 ≥ 80%）
7. 实现 Controller 接口
8. 前端页面开发（PC和/或移动端）
9. 编译验证

代码规范：
- 密码必须 BCrypt 加密
- 使用 @Transactional 管理事务
- 日志记录关键操作
- 统一使用 Result<T> 包装响应

项目路径：
- 后端：c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-java\
- PC前端：c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin\
- 移动端：c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\

编译命令：mvn clean compile -DskipTests

完成后输出：✅DONE" \
--max-iterations 25 \
--completion-promise "✅DONE"
```

---

### 4. Bug 修复

```
/ralph-loop "修复 {BUG_NAME}

问题描述：
{BUG_DESCRIPTION}

问题原因：
{ROOT_CAUSE}

修复步骤：
1. 定位问题代码位置
2. 分析问题根因
3. 编写修复代码
4. 添加回归测试防止复现
5. 运行测试验证：
   - mvn test（后端）
   - npm run type-check（PC前端）
   - flutter analyze（移动端）

相关文件：
{FILES}

历史参考：bucket-water-oms-admin/AGENTS.md

完成后输出：✅DONE" \
--max-iterations 5 \
--completion-promise "✅DONE"
```

---

## 项目关键信息

### 项目路径
```
c:\Users\Wishtohear\Documents\bucket-water-oms\
├── bucket-water-oms-java/          # 后端 (Spring Boot)
├── bucket-water-oms-admin/         # PC前端 (Vue 3)
└── bucket-water-oms-admin-mobile/  # 移动端 (Flutter)
```

### 核心模块
| 模块 | 路径 | 说明 |
|------|------|------|
| auth | module/auth/ | 认证、登录、JWT |
| order | module/order/ | 订单管理 |
| station | module/station/ | 水站端 |
| warehouse | module/warehouse/ | 仓库端 |
| driver | module/driver/ | 司机端 |
| bucket | module/bucket/ | 空桶管理 |
| aftersales | module/aftersales/ | 售后管理 |
| statement | module/statement/ | 对账管理 |

### 常用命令
```powershell
# 后端编译
cd c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-java
mvn clean compile -DskipTests

# 后端测试
mvn test

# 后端覆盖率
mvn test jacoco:report

# PC前端类型检查
cd c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin
npm run type-check

# 移动端分析
cd c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile
flutter analyze
```

### 关键开发记录（AGENTS.md）
- 2026-04-24：修复新增司机默认密码不是123456的问题（密码BCrypt加密）
- 2026-04-24：仓库端后端API完善
- 2026-04-23：修复仓库账号登录"用户不存在"错误
- 2026-04-23：PC端登录添加角色选择功能
- 2026-04-23：Flutter移动端司机端删除写死测试数据
- 2026-04-24：修复司机端API字段不匹配问题
- 2026-04-27：修复水站端的账户扣款逻辑错误
- 2026-04-27：水站端前端显示的账户信息修正
