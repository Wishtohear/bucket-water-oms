# 水厂订货管理系统 (Bucket Water OMS)

## 项目简介

水厂订货管理系统是一个实现水站线下单→仓库备货派单→司机配送签收→空桶回收→仓库核对的完整业务闭环管理系统。所有操作均可通过手机端完成，替代传统电话订货和手工水卡记录方式。

## 技术栈

### 后端技术

- **Spring Boot**: 3.2.5
- **Java**: 17
- **ORM框架**: MyBatis Plus 3.5.6
- **数据库**: PostgreSQL
- **缓存**: Redis
- **数据库连接池**: Druid 1.2.21
- **身份认证**: JWT 0.12.6
- **对象映射**: MapStruct 1.5.5
- **API文档**: SpringDoc OpenAPI 2.3.0 (Swagger)
- **日志框架**: SLF4J + Logback

### 项目依赖

```
├── Spring Boot Web
├── Spring Boot Validation
├── Spring Boot Data JPA
├── PostgreSQL Driver
├── Redis (Spring Data Redis)
├── MyBatis Plus
├── Druid Connection Pool
├── JWT (jjwt)
├── Lombok
├── MapStruct
├── SpringDoc OpenAPI (Swagger UI)
├── Apache Commons Lang3
└── Spring Boot Actuator
```

## 系统架构

### 核心模块

- **水厂管理员后台**: 账号管理、定价策略、报表中心
- **水站端**: 库存查看、订单管理、对账管理
- **仓库端**: 订单处理、派单管理、库存管理
- **司机端**: 配送任务、签收管理、回桶录入

### 业务流程

```
[水站端] 查看库存 → 提交订单 → （审查前可修改/取消）
     ↓
[仓库端] 接单审查 → 【库存不足：拒单退回水站】 / 【库存充足：备货】 → 手动派单给司机
     ↓
[司机端] 接单 → 地图路线规划 → 配送导航 → 到达签收（拍照+核对数量）
     ↓
[仓库端] 司机回仓 → 核对空桶实收 → 差异追责
```

## 项目结构

```
bucket-water-oms-java/
├── src/
│   └── main/
│       ├── java/
│       │   └── com/
│       │       └── bucketwater/
│       │           └── oms/
│       │               ├── common/          # 公共模块
│       │               │   ├── enums/        # 枚举类
│       │               │   ├── exception/   # 异常处理
│       │               │   ├── response/    # 统一响应
│       │               │   └── BaseEntity.java
│       │               ├── config/           # 配置类
│       │               ├── controller/       # 控制器
│       │               ├── module/          # 业务模块
│       │               │   └── user/        # 用户模块示例
│       │               └── BucketWaterOmsApplication.java
│       └── resources/
│           ├── application.yml
│           ├── application-dev.yml
│           ├── application-prod.yml
│           └── logback-spring.xml
├── database/
│   └── init.sql
├── pom.xml
├── README.md
├── ER图.md
├── 水厂订货管理系统.md
└── 接口定义文档.md
```

## 快速开始

### 环境要求

- JDK 17+
- Maven 3.6+
- PostgreSQL 14+
- Redis 6+

### 配置说明

1. 复制配置文件并修改数据库连接信息：

```yaml
# application-dev.yml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/bucket_water_oms
    username: your_username
    password: your_password
  redis:
    host: localhost
    port: 6379
```

2. 修改 JWT 密钥（生产环境必须修改）：

```yaml
jwt:
  secret: your-secret-key-here
  expiration: 86400000
```

### 构建和运行

```bash
# 编译项目
mvn clean compile

# 运行项目
mvn spring-boot:run

# 打包
mvn clean package -DskipTests
```

### API文档

启动项目后访问 Swagger UI：

- Swagger UI: http://localhost:8080/swagger-ui.html
- API Docs: http://localhost:8080/v3/api-docs

### 账户信息

开发环境默认账户（请及时修改）：

| 角色 | 用户名 | 密码 |
|------|--------|------|
| 水厂管理员 | admin | admin123 |

## 核心功能

### 1. 订单管理

- 订单创建、修改、取消
- 订单状态流转（待审查→已接单→已派单→配送中→已完成）
- 拒单处理（库存不足等原因）
- 订单历史查询

### 2. 水站管理

- 水站开户（手机号+密码）
- 销售政策配置（单价、账期、预存金要求、阶梯价）
- 空桶押金管理（按水站独立设置）
- 店员账号管理

### 3. 仓库管理

- 订单接单/拒单
- 备货管理
- 司机派单
- 司机回仓核对
- 空桶库存管理

### 4. 司机管理

- 配送任务接收
- 地图路线规划
- 配送签收（拍照）
- 回桶录入
- 中途回仓

### 5. 财务管理

- 预存金管理
- 信用额度管理
- 月结对账
- 应收款管理

### 6. 报表中心

- 水站进货报表
- 司机配送报表
- 空桶汇总报表
- 财务对账报表
- Excel导出功能

## API接口

详见 [接口定义文档.md](接口定义文档.md)

## 数据库设计

详见 [ER图.md](ER图.md)

## 产品需求文档

详见 [水厂订货管理系统.md](水厂订货管理系统.md)

## 开发规范

### 代码规范

- 使用 Google Java Style
- 使用 Lombok 简化代码
- 使用 MapStruct 进行对象映射
- 使用 MyBatis Plus 进行数据库操作

### Git提交规范

```
feat: 新功能
fix: 修复bug
docs: 文档更新
style: 代码格式调整
refactor: 重构
perf: 性能优化
test: 测试相关
chore: 构建/工具相关
```

### 分支管理

```
main (生产环境)
├── develop (开发环境)
│   ├── feature/功能分支
│   ├── fix/修复分支
│   └── refactor/重构分支
```

## 测试

```bash
# 运行单元测试
mvn test

# 生成测试覆盖率报告
mvn test jacoco:report
```

## 部署

### 环境配置

生产环境需要配置以下环境变量：

```bash
# 数据库
export DB_HOST=your-db-host
export DB_PORT=5432
export DB_NAME=bucket_water_oms
export DB_USERNAME=your-username
export DB_PASSWORD=your-password

# Redis
export REDIS_HOST=your-redis-host
export REDIS_PORT=6379

# JWT
export JWT_SECRET=your-production-secret
```

### Docker 部署

```dockerfile
FROM eclipse-temurin:17-jre-alpine
COPY target/oms-1.0.0-SNAPSHOT.jar app.jar
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

## 性能优化

- 数据库连接池：Druid
- 缓存：Redis（会话、热点数据）
- 索引优化：合理创建数据库索引
- 异步处理：使用异步任务处理非核心流程

## 安全建议

- 生产环境务必修改默认账户密码
- 使用 HTTPS 传输数据
- 定期更新依赖版本
- 启用审计日志
- 敏感数据加密存储

## 常见问题

### Q: 如何添加新的业务模块？

1. 在 `module` 下创建新模块包
2. 创建实体类（Entity）
3. 创建 Mapper 接口
4. 创建 Service 层
5. 创建 Controller 层
6. 在 `BucketWaterOmsApplication.java` 添加包扫描

### Q: 如何处理空桶差异？

当司机回仓数量与实际上报数量不一致时：
- 系统自动标记差异
- 生成赔偿记录
- 从司机工资或押金中扣除

## 许可证

本项目仅供学习交流使用。

## 联系方式

如有问题，请提交 Issue。

## 版本历史

- **v1.0.0-SNAPSHOT** (2026-04-19)
  - 初始化项目
  - 基础架构搭建
  - Spring Boot 3.2.5 升级
  - MyBatis Plus 集成
  - Swagger API 文档集成
