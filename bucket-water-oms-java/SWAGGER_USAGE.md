# 水厂订货管理系统 - Swagger API 文档使用指南

## 🚀 启动应用

```bash
mvn spring-boot:run
```

启动后，在控制台会看到以下启动日志：

```
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║              💧 水厂订货管理系统 (Bucket Water OMS)        ║
╠═══════════════════════════════════════════════════════════╣
║                                                           ║
║  ✅ Application:    bucket-water-oms                       ║
║  📦 Version:       1.0.0-SNAPSHOT                        ║
║  🕐 Start Time:    2026-04-19 16:20:30                   ║
║  🌐 Server Port:   8080                                   ║
║  📚 API Docs:      http://localhost:8080/swagger-ui.html   ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
```

## 📖 Swagger UI 访问地址

- **Swagger UI**: http://localhost:8080/swagger-ui.html
- **API Docs (JSON)**: http://localhost:8080/v3/api-docs
- **Actuator Health**: http://localhost:8080/actuator/health

## 🔧 Swagger 注解使用示例

### 1. Controller 级别的注解

```java
@Tag(name = "用户管理", description = "用户相关的增删改查操作")
@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
public class UserController {
    // ...
}
```

### 2. 方法级别的注解

```java
@GetMapping("/{id}")
@Operation(summary = "获取用户详情", description = "根据用户ID获取详细信息")
public Result<UserDTO> getUser(@PathVariable Long id) {
    // ...
}
```

### 3. 参数级别的注解

```java
@Parameter(description = "用户ID", required = true, example = "1")
@PathVariable Long id

@Parameter(description = "页码", example = "0")
@RequestParam(defaultValue = "0") int page
```

### 4. 请求体注解

```java
@io.swagger.v3.oas.annotations.parameters.RequestBody(
    description = "用户创建信息",
    required = true,
    content = @Content(
        mediaType = "application/json",
        schema = @Schema(example = "{\"username\":\"test\",\"phone\":\"13800138000\"}")
    )
)
@RequestBody UserCreateRequest request
```

### 5. 响应注解

```java
@ApiResponses(value = {
    @ApiResponse(responseCode = "200", description = "成功"),
    @ApiResponse(responseCode = "400", description = "参数错误"),
    @ApiResponse(responseCode = "404", description = "用户不存在")
})
```

## 📝 Lombok 注解使用示例

### 1. DTO 类中使用 Lombok

```java
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Schema(description = "用户DTO")
public class UserDTO {

    @Schema(description = "用户ID", example = "1")
    private Long id;

    @Schema(description = "用户名", example = "zhangsan")
    private String username;

    @Schema(description = "手机号", example = "13800138000")
    private String phone;
}
```

### 2. Service 类中使用 Lombok

```java
@Slf4j
@Service
public class UserService {

    public void createUser(UserDTO user) {
        log.info("Creating user: {}", user);
        // 业务逻辑
    }
}
```

### 3. 实体类中使用 Lombok

```java
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("sys_user")
@Schema(description = "系统用户实体")
public class User extends BaseEntity {

    @Schema(description = "用户名")
    private String username;

    @Schema(description = "密码")
    private String password;
}
```

## 🎯 常用注解说明

### Lombok 注解

| 注解 | 说明 |
|------|------|
| `@Data` | 自动生成 getter/setter/toString/equals/hashCode |
| `@Getter` | 自动生成 getter |
| `@Setter` | 自动生成 setter |
| `@NoArgsConstructor` | 生成无参构造函数 |
| `@AllArgsConstructor` | 生成全参构造函数 |
| `@Builder` | 生成 Builder 模式 |
| `@Slf4j` | 自动生成 log 静态字段 |
| `@RequiredArgsConstructor` | 生成包含 final 和 @NonNull 字段的构造函数 |

### Swagger 注解

| 注解 | 说明 |
|------|------|
| `@Tag` | API 分组标签 |
| `@Operation` | 方法描述 |
| `@Parameter` | 参数描述 |
| `@ApiResponse` | 响应描述 |
| `@Schema` | 模型属性描述 |

## 🔨 开发建议

### 1. 所有 DTO 必须添加 Schema 注解

```java
@Data
@Builder
@Schema(description = "订单创建请求")
public class OrderCreateRequest {

    @Schema(description = "水站ID", required = true, example = "1")
    @NotNull(message = "水站ID不能为空")
    private Long stationId;

    @Schema(description = "商品列表", required = true)
    @NotEmpty(message = "商品列表不能为空")
    private List<OrderItemDTO> items;
}
```

### 2. 所有 Controller 必须添加 Tag 注解

```java
@Tag(name = "订单管理", description = "订单的创建、查询、状态更新等操作")
@RestController
@RequestMapping("/api/v1/orders")
public class OrderController {
    // ...
}
```

### 3. 使用 Lombok 简化代码

```java
@Slf4j
@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrderRepository orderRepository;
    private final StationService stationService;

    @Transactional
    public Order createOrder(OrderCreateRequest request) {
        log.info("Creating order for station: {}", request.getStationId());

        // 业务逻辑

        log.info("Order created successfully: {}", order.getId());
        return order;
    }
}
```

## 📦 依赖版本

- **Spring Boot**: 3.2.5
- **Springdoc OpenAPI**: 2.3.0
- **Lombok**: 1.18.32

## 🌐 浏览器访问

启动应用后，打开浏览器访问：

```
http://localhost:8080/swagger-ui.html
```

即可看到完整的 API 文档页面，支持在线调试接口！
