# CORS 配置说明

## 配置说明

项目已参照 WoventLight 项目实现了 CORS 配置，支持开发和生产环境的灵活配置。

## 配置参数

### 1. cors.enabled
- **功能**: 是否启用 CORS
- **开发环境**: `true` (默认启用)
- **生产环境**: `false` (默认禁用，需要手动配置)
- **类型**: `boolean`

### 2. cors.allowed-origins
- **功能**: 允许的跨域来源
- **开发环境**: `*` (允许所有来源)
- **生产环境**: 空字符串 (配合环境变量控制)
- **类型**: `String`
- **特殊值**:
  - `*`: 允许所有来源（仅建议开发环境使用）
  - 逗号分隔的域名列表: 如 `https://example.com,https://www.example.com`

## 环境配置

### 开发环境 (application.yml)
```yaml
cors:
  enabled: true
  allowed-origins: "*"
```
开发环境默认启用 CORS，并允许所有来源，方便前后端联调。

### 生产环境 (application-prod.yml)
```yaml
cors:
  enabled: ${CORS_ENABLED:false}
  allowed-origins: ${CORS_ALLOWED_ORIGINS:}
```
生产环境默认禁用 CORS，需要通过环境变量或配置中心来启用。

## 生产环境部署

### 方式一：使用环境变量
```bash
# 启用 CORS 并指定允许的域名
export CORS_ENABLED=true
export CORS_ALLOWED_ORIGINS=https://www.yourdomain.com,https://yourdomain.com

# 启动应用
java -jar bucket-water-oms.jar
```

### 方式二：使用 Docker
```bash
docker run -d \
  -e CORS_ENABLED=true \
  -e CORS_ALLOWED_ORIGINS=https://www.yourdomain.com \
  -p 8080:8080 \
  bucket-water-oms:latest
```

### 方式三：使用 Kubernetes
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: bucket-water-oms
spec:
  template:
    spec:
      containers:
      - name: bucket-water-oms
        env:
        - name: CORS_ENABLED
          value: "true"
        - name: CORS_ALLOWED_ORIGINS
          value: "https://www.yourdomain.com,https://yourdomain.com"
```

## 推荐的域名配置

### 前端域名
```
https://www.yourdomain.com
https://yourdomain.com
https://m.yourdomain.com  # 移动端
```

### 子域名示例
```
https://admin.yourdomain.com      # 管理后台
https://station.yourdomain.com    # 水站端
https://driver.yourdomain.com     # 司机端
https://warehouse.yourdomain.com  # 仓库端
```

## 安全建议

### 1. 生产环境禁止使用 `*`
```yaml
# ❌ 错误 - 存在安全风险
cors:
  enabled: true
  allowed-origins: "*"

# ✅ 正确 - 指定具体域名
cors:
  enabled: true
  allowed-origins: https://www.yourdomain.com
```

### 2. 使用 HTTPS
所有跨域请求都应使用 HTTPS，确保 Cookie 和认证信息的安全传输。

### 3. 限制必要的方法
只允许应用实际使用的方法：
```yaml
# 如果只需要 GET 和 POST
allowed-methods: GET,POST
```

### 4. 定期审查域名列表
定期检查并清理不再使用的域名配置。

## 故障排查

### 1. 跨域请求失败
检查浏览器控制台的错误信息：
- `No 'Access-Control-Allow-Origin' header`: 确认 CORS 已启用且域名正确
- `Credentials not supported if origin is '*'`: 生产环境不能使用 `*`
- `Method not allowed`: 检查 allowed-methods 配置

### 2. 预检请求失败
- 确认 `OPTIONS` 方法已在 allowed-methods 中
- 检查防火墙是否允许 OPTIONS 请求

### 3. Cookie 无法传递
- 确认 `allowCredentials` 为 `true`
- 确认 `allowed-origins` 不是 `*`

## 配置示例

### 示例 1: 单域名配置
```yaml
cors:
  enabled: true
  allowed-origins: https://www.yourdomain.com
```

### 示例 2: 多域名配置
```yaml
cors:
  enabled: true
  allowed-origins: https://www.yourdomain.com,https://m.yourdomain.com
```

### 示例 3: 禁用 CORS
```yaml
cors:
  enabled: false
  allowed-origins: ""
```

### 示例 4: 通过环境变量配置
```yaml
cors:
  enabled: ${CORS_ENABLED:false}
  allowed-origins: ${CORS_ALLOWED_ORIGINS:}
```

## 监控和日志

启用 CORS 后，可以在日志中看到跨域请求的详细信息：

```yaml
logging:
  level:
    com.bucketwater.oms.config.CorsConfig: DEBUG
```

这样可以追踪哪些域名在访问你的 API，及时发现异常访问。
