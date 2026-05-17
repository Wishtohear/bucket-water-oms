# 水厂订货管理系统 - Claude Code 循环提示词

## 项目概述

水厂订货管理系统是一个实现水站下单→仓库备货派单→司机配送签收→空桶回收→仓库核对的完整业务闭环系统。

### 技术栈

| 端 | 技术 | 路径 |
|----|------|------|
| 后端 | Java + Spring Boot + MyBatis-Plus | `bucket-water-oms-java/` |
| PC管理后台 | Vue 3 + TypeScript + Element Plus | `bucket-water-oms-admin/` |
| 移动端 | Flutter + Dart | `bucket-water-oms-admin-mobile/` |

### 核心模块

```
├── auth           # 认证模块（登录、JWT）
├── admin          # 水厂管理员后台
├── station        # 水站端（水站老板）
├── warehouse      # 仓库端
├── driver         # 司机端
├── order          # 订单模块
├── product        # 产品/商品模块
├── payment        # 支付模块
├── aftersales     # 售后模块
├── bucket         # 空桶管理模块
├── statement      # 对账模块
├── inventory      # 库存模块
├── report         # 报表模块
├── notification   # 通知模块
├── sms            # 短信模块
├── print          # 打印模块
├── map            # 地图服务模块
└── customer       # 客户管理模块
```

---

## 循环提示词模板

### 基础版循环提示词

```markdown
# 水厂订货管理系统开发循环

## 项目根目录
`c:\Users\Wishtohear\Documents\bucket-water-oms\`

## 开发文档
`c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-java\水厂订货管理系统.md`

## 当前任务
{TASK_DESCRIPTION}

## 工作目录
- 后端: `c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-java\`
- PC前端: `c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin\`
- 移动端: `c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile\`

## 执行步骤
1. 阅读开发文档理解需求
2. 分析现有代码结构
3. 实现功能代码
4. 编写单元测试
5. 编译验证后端 `mvn clean compile -DskipTests`
6. 运行前端类型检查
7. 验证功能完整性

## 核心业务规则（参考）
- 订单状态流转: PENDING_REVIEW → REVIEWED → DISPATCHED → DELIVERING → COMPLETED
- 扣款规则: 预存金下单时不冻结直接扣减，月结配送完成时增加已用额度
- 空桶规则: 回桶/欠桶需记录流水，差异处理按多报少报计算赔偿
- 司机选择算法: 距离40% + 任务数30% + 在线状态20% + 历史评分10%

## 测试覆盖要求
- Service层测试覆盖率 ≥ 80%
- 核心业务逻辑必须100%覆盖
- 使用JUnit 5 + Mockito

## 输出要求
完成后输出:
- 修改的文件列表
- 测试运行结果
- 编译/类型检查结果
```

---

### 测试覆盖率提升循环提示词

```markdown
# 将 src/ 下业务代码的测试覆盖率提升至 ≥90%

## 项目根目录
`c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-java\`

## 工作目录
`c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-java\`

## 步骤
1. 运行 `mvn test jacoco:report` 生成覆盖率报告
2. 分析 `target/site/jacoco/index.html` 找出未覆盖的类和方法
3. 为未覆盖的业务逻辑编写单元测试
4. 重复直到覆盖率达标

## 重点覆盖模块（按优先级）
1. **order/OrderService** - 订单创建、状态流转、扣款逻辑
2. **station/StationService** - 水站账户、水站定价
3. **driver/DriverService** - 配送流程、位置管理
4. **warehouse/WarehouseService** - 接单拒单、派单
5. **bucket/BucketService** - 空桶流水、差异处理
6. **statement/StatementService** - 对账单生成
7. **aftersales/AfterSalesService** - 售后处理

## 测试模板
```java
@ExtendWith(MockitoExtension.class)
class {ServiceName}Test {

    @Mock
    private {Repository} {repository};

    private {Service} {service};

    @BeforeEach
    void setUp() {
        {service} = new {Service}({repository});
    }

    @Test
    @DisplayName("{测试场景描述}")
    void {methodName}_{scenario}_{expectedResult}() {
        // Given
        {准备测试数据}

        // When
        {执行方法}

        // Then
        {验证结果}
        verify({repository}).{验证方法调用};
    }
}
```

## 输出
完成后输出: ✅DONE
覆盖率报告路径: `target/site/jacoco/index.html`
```

---

### API前后端联调循环提示词

```markdown
# 核心功能前后端联调循环

## 项目根目录
`c:\Users\Wishtohear\Documents\bucket-water-oms\`

## 联调范围
- 后端API: `bucket-water-oms-java/src/main/java/com/bucketwater/oms/module/`
- PC前端: `bucket-water-oms-admin/src/`
- 移动端: `bucket-water-oms-admin-mobile/lib/`

## 联调步骤
1. **后端实现**: 在 `module/{name}/controller/` 创建/完善Controller
2. **API文档**: 更新 `apidocs.json` 记录接口定义
3. **前端调用**: 在对应 `api/` 目录添加API方法
4. **类型定义**: 在 `models/` 添加数据模型
5. **页面集成**: 在 `pages/` 页面中调用API
6. **编译验证**: 
   - 后端: `mvn clean compile -DskipTests`
   - 前端: `npm run type-check` (如配置)

## 当前联调模块
{SELECTED_MODULE}

## 联调检查清单
- [ ] Controller方法添加 `@Operation` 注解
- [ ] 响应使用统一 `Result<T>` 包装
- [ ] 前端API方法与后端接口路径一致
- [ ] DTO字段命名前后端一致（参考OrderVO字段设计）
- [ ] 分页响应使用 `PageResult<T>`
- [ ] 错误码使用 `ResultCode` 枚举

## 核心字段对照表（移动端兼容）
| 后端字段 | 移动端期望 | 说明 |
|----------|-----------|------|
| stationLat/stationLng | latitude/longitude | 水站坐标 |
| warehouse.name | warehouseName | 仓库名称(扁平) |
| station.name | stationName | 水站名称 |
| - | totalQuantity | 总数量 |

## 验证方法
1. 启动后端: `mvn spring-boot:run` 或IDE运行
2. 启动PC前端: `cd bucket-water-oms-admin && npm run dev`
3. 启动移动端: `cd bucket-water-oms-admin-mobile && flutter run`
4. 测试接口: `curl http://localhost:8080/api/{module}/{endpoint}`
```

---

### 核心业务流程开发循环提示词

```markdown
# 水厂订货管理系统 - 核心业务功能开发

## 项目根目录
`c:\Users\Wishtohear\Documents\bucket-water-oms\`

## 开发文档
`c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-java\水厂订货管理系统.md`

## 开发任务
{TASK_DESCRIPTION}

## 参考章节
- 订单模块: 第四章 4.1.6 ~ 4.1.7
- 水站端: 第四章 4.2
- 仓库端: 第四章 4.3
- 司机端: 第四章 4.4

## 代码模板

### 后端 Controller 模板
```java
@RestController
@RequestMapping("/{module}")
@RequiredArgsConstructor
@Tag(name = "{模块名称}", description = "{模块描述}")
public class {Module}Controller {

    private final {Module}Service {module}Service;

    @GetMapping
    @Operation(summary = "获取列表", description = "{接口描述}")
    public Result<PageResult<{DTO}>> getList(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "20") Integer size,
            @RequestParam(required = false) String status) {
        return Result.ok({module}Service.getPageList(page, size, status));
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取详情", description = "{接口描述}")
    public Result<{DTO}> getDetail(@PathVariable Long id) {
        return Result.ok({module}Service.getDetail(id));
    }

    @PostMapping
    @Operation(summary = "创建", description = "{接口描述}")
    public Result<{DTO}> create(@RequestBody @Valid Create{Module}Request request) {
        return Result.ok({module}Service.create(request));
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新", description = "{接口描述}")
    public Result<Void> update(@PathVariable Long id, @RequestBody @Valid Update{Module}Request request) {
        {module}Service.update(id, request);
        return Result.ok();
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除", description = "{接口描述}")
    public Result<Void> delete(@PathVariable Long id) {
        {module}Service.delete(id);
        return Result.ok();
    }
}
```

### 后端 Service 模板
```java
@Service
@RequiredArgsConstructor
@Slf4j
public class {Module}Service {

    private final {Module}Mapper {module}Mapper;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    @Transactional
    public {DTO} create(Create{Module}Request request) {
        log.info("[{模块}] 创建: {}", request);
        // 业务逻辑
        {Entity} entity = new {Entity}();
        // 字段映射
        {module}Mapper.insert(entity);
        return convertToDTO(entity);
    }

    @Transactional
    public void update(Long id, Update{Module}Request request) {
        {Entity} entity = {module}Mapper.selectById(id);
        if (entity == null) {
            throw new BusinessException(ResultCode.NOT_FOUND);
        }
        // 更新逻辑
        {module}Mapper.updateById(entity);
    }

    private {DTO} convertToDTO({Entity} entity) {
        {DTO} dto = new {DTO}();
        // 转换逻辑
        return dto;
    }
}
```

### 前端 API 模板 (TypeScript)
```typescript
// api/{module}.ts
import request from '@/utils/request'

export interface {Module}DTO {
  id: number
  name: string
  status: string
  createTime: string
}

export interface Create{Module}Request {
  name: string
}

export const {module}Api = {
  getList: (params: { page?: number; size?: number; status?: string }) => {
    return request.get<{ records: {Module}DTO[]; total: number }>('/{module}', { params })
  },

  getDetail: (id: number) => {
    return request.get<{Module}DTO>(`/{module}/${id}`)
  },

  create: (data: Create{Module}Request) => {
    return request.post<{Module}DTO>('/{module}', data)
  },

  update: (id: number, data: Partial<Create{Module}Request>) => {
    return request.put<void>(`/{module}/${id}`, data)
  },

  delete: (id: number) => {
    return request.delete<void>(`/{module}/${id}`)
  }
}
```

## 业务规则提醒
- 密码必须BCrypt加密存储
- 所有时间字段使用LocalDateTime
- 金额字段使用BigDecimal
- 状态枚举与前端保持一致
- 日志记录关键业务操作

## 验证清单
- [ ] 编译通过: `mvn clean compile -DskipTests`
- [ ] 单元测试通过: `mvn test`
- [ ] 接口文档更新
- [ ] 前端类型检查通过
```

---

## 常用开发任务模板

### 1. 新增水站端功能
```markdown
# 新增水站端功能: {FEATURE_NAME}

## 参考文档
- 第四章 4.2 水站端

## 需要修改的文件
后端:
- `module/station/controller/StationController.java`
- `module/station/service/StationService.java`
- `module/station/dto/` (如需新增DTO)

前端(PC):
- `src/views/owner/Owner{Page}.vue`
- `src/api/stationOwner.ts`

前端(移动端):
- `lib/pages/owner/owner_{page}.dart`
- `lib/services/station_service.dart`
- `lib/models/station_model.dart`

## 权限说明
水站端分老板和店员权限，见第二章 2.3.1
```

### 2. 新增仓库端功能
```markdown
# 新增仓库端功能: {FEATURE_NAME}

## 参考文档
- 第四章 4.3 仓库端

## 需要修改的文件
后端:
- `module/warehouse/controller/WarehouseController.java`
- `module/warehouse/service/WarehouseService.java`
- `module/bucket/` (如涉及空桶)

前端(PC):
- `src/views/warehouse/Warehouse{Page}.vue`
- `src/api/warehouse.ts`

前端(移动端):
- `lib/pages/warehouse/warehouse_{page}.dart`
- `lib/services/warehouse_service.dart`

## 权限说明
仓库端仅仓库管理员可用，见第二章 2.3.2
```

### 3. 新增司机端功能
```markdown
# 新增司机端功能: {FEATURE_NAME}

## 参考文档
- 第四章 4.4 司机端

## 需要修改的文件
后端:
- `module/driver/controller/DriverController.java`
- `module/driver/service/DriverService.java`

前端(移动端):
- `lib/pages/driver/driver_{page}.dart`
- `lib/services/driver_service.dart`
- `lib/models/driver_task_model.dart`

## 司机状态
- online: 在线
- offline: 离线
- break: 休息中

## 司机位置更新
心跳间隔: 5分钟
离线超时: 10分钟
```

### 4. 新增管理后台功能
```markdown
# 新增管理后台功能: {FEATURE_NAME}

## 参考文档
- 第四章 4.1 水厂管理员后台

## 需要修改的文件
后端:
- `module/admin/controller/Admin{Module}Controller.java`
- `module/admin/service/Admin{Module}Service.java`

前端(PC):
- `src/views/admin/Admin{Page}.vue`
- `src/api/{module}.ts`

## 功能优先级
见第十章 开发优先级建议
```

---

## 快速启动命令

### 后端
```powershell
# 编译
cd c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-java
mvn clean compile -DskipTests

# 测试
mvn test

# 覆盖率报告
mvn test jacoco:report

# 运行
mvn spring-boot:run
```

### PC前端
```powershell
# 安装依赖
cd c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin
npm install

# 开发
npm run dev

# 类型检查
npm run type-check
```

### 移动端
```powershell
# 安装依赖
cd c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile
flutter pub get

# 运行
flutter run

# 分析
flutter analyze
```

---

## 常见问题处理

| 问题 | 解决方案 |
|------|----------|
| 登录失败: 用户不存在 | 检查role参数是否正确，参考AGENTS.md 2026-04-23记录 |
| 登录失败: 密码错误 | 检查BCrypt加密，参考AGENTS.md 2026-04-24记录 |
| 接口500错误 | 检查Region实体deleted字段，参考AGENTS.md 2026-04-21记录 |
| 前后端字段不匹配 | 添加兼容字段，参考AGENTS.md 2026-04-24记录 |

---

## 版本历史
- v1.0: 初始版本
- 基于: 水厂订货管理系统 PRD v1.2
