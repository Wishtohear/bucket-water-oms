package com.bucketwater.oms.module.audit.aspect;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.module.audit.service.AuditLogService;
import com.bucketwater.oms.module.auth.dto.LoginResponse;
import com.bucketwater.oms.module.user.entity.User;
import com.bucketwater.oms.module.user.mapper.UserMapper;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import jakarta.servlet.http.HttpServletRequest;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.reflect.MethodSignature;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import javax.crypto.SecretKey;
import java.lang.reflect.Method;
import java.lang.reflect.Parameter;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;

@Aspect
@Component
public class AuditLogAspect {

    private static final Logger log = LoggerFactory.getLogger(AuditLogAspect.class);

    private final AuditLogService auditLogService;
    private final UserMapper userMapper;
    private final ObjectMapper objectMapper;

    @Value("${jwt.secret:defaultSecretKeyForDevelopment123456789012345678901234567890}")
    private String jwtSecret;

    public AuditLogAspect(AuditLogService auditLogService, UserMapper userMapper, ObjectMapper objectMapper) {
        this.auditLogService = auditLogService;
        this.userMapper = userMapper;
        this.objectMapper = objectMapper;
    }

    @Around("@annotation(auditLog)")
    public Object logAround(ProceedingJoinPoint joinPoint, com.bucketwater.oms.module.audit.annotation.AuditLog auditLog) throws Throwable {
        com.bucketwater.oms.module.audit.entity.AuditLog auditLogRecord = new com.bucketwater.oms.module.audit.entity.AuditLog();
        long startTime = System.currentTimeMillis();

        try {
            HttpServletRequest request = getCurrentRequest();
            if (request != null) {
                auditLogRecord.setRequestUrl(request.getRequestURI());
                auditLogRecord.setRequestMethod(request.getMethod());
                auditLogRecord.setIpAddress(getClientIp(request));
                auditLogRecord.setUserAgent(request.getHeader("User-Agent"));
            }

            User currentUser = getCurrentUser(request);
            if (currentUser != null) {
                auditLogRecord.setUserId(currentUser.getId());
                auditLogRecord.setUsername(currentUser.getName());
                auditLogRecord.setUserRole(currentUser.getRole());
            }

            MethodSignature signature = (MethodSignature) joinPoint.getSignature();
            Method method = signature.getMethod();
            auditLogRecord.setMethod(method.getName());

            String action = determineAction(method, auditLog);
            auditLogRecord.setAction(action);
            auditLogRecord.setModule(auditLog.module());
            auditLogRecord.setEntityType(auditLog.entityType());

            Object[] args = joinPoint.getArgs();
            String entityId = extractParameterValue(args, method, auditLog.entityIdParam());
            String entityName = extractParameterValue(args, method, auditLog.entityNameParam());
            auditLogRecord.setEntityId(entityId);
            auditLogRecord.setEntityName(entityName);

            String params = extractRequestParams(args, method);
            auditLogRecord.setRequestParams(params);

            Object result = joinPoint.proceed();

            long duration = System.currentTimeMillis() - startTime;
            auditLogRecord.setResponseStatus(200);
            auditLogRecord.setCreateTime(LocalDateTime.now());

            log.info("审计日志: user={}, action={}, module={}, entity={}, duration={}ms",
                    auditLogRecord.getUsername(), action, auditLog.module(),
                    entityId != null ? entityId : "N/A", duration);

            auditLogService.saveLog(auditLogRecord);

            return result;

        } catch (Exception e) {
            if (auditLogRecord != null) {
                auditLogRecord.setResponseStatus(500);
                auditLogRecord.setErrorMessage(e.getMessage());
                auditLogRecord.setCreateTime(LocalDateTime.now());
                auditLogService.saveLog(auditLogRecord);
            }

            log.error("审计日志记录失败: {}", e.getMessage(), e);
            throw e;
        }
    }

    @Around("execution(* com.bucketwater.oms.module.admin.controller..*.*(..))")
    public Object logAdminOperations(ProceedingJoinPoint joinPoint) throws Throwable {
        com.bucketwater.oms.module.audit.entity.AuditLog auditLogRecord = new com.bucketwater.oms.module.audit.entity.AuditLog();
        long startTime = System.currentTimeMillis();

        try {
            HttpServletRequest request = getCurrentRequest();
            if (request != null) {
                auditLogRecord.setRequestUrl(request.getRequestURI());
                auditLogRecord.setRequestMethod(request.getMethod());
                auditLogRecord.setIpAddress(getClientIp(request));
                auditLogRecord.setUserAgent(request.getHeader("User-Agent"));
            }

            User currentUser = getCurrentUser(request);
            if (currentUser != null) {
                auditLogRecord.setUserId(currentUser.getId());
                auditLogRecord.setUsername(currentUser.getName());
                auditLogRecord.setUserRole(currentUser.getRole());
            }

            MethodSignature signature = (MethodSignature) joinPoint.getSignature();
            Method method = signature.getMethod();
            String className = joinPoint.getTarget().getClass().getSimpleName();
            auditLogRecord.setMethod(className + "." + method.getName());

            String action = determineActionFromMethod(method);
            auditLogRecord.setAction(action);

            String module = determineModuleFromPath(request);
            auditLogRecord.setModule(module);

            Object[] args = joinPoint.getArgs();
            String params = extractRequestParams(args, method);
            auditLogRecord.setRequestParams(params);

            Object entityId = extractPathVariable(args, method, "id");
            if (entityId != null) {
                auditLogRecord.setEntityId(entityId.toString());
            }

            Object result = joinPoint.proceed();

            long duration = System.currentTimeMillis() - startTime;
            auditLogRecord.setResponseStatus(200);
            auditLogRecord.setCreateTime(LocalDateTime.now());

            log.info("管理操作审计: user={}, action={}, module={}, entity={}, duration={}ms",
                    auditLogRecord.getUsername(), action, module,
                    auditLogRecord.getEntityId() != null ? auditLogRecord.getEntityId() : "N/A", duration);

            auditLogService.saveLog(auditLogRecord);

            return result;

        } catch (Exception e) {
            if (auditLogRecord != null) {
                auditLogRecord.setResponseStatus(500);
                auditLogRecord.setErrorMessage(e.getMessage());
                auditLogRecord.setCreateTime(LocalDateTime.now());
                auditLogService.saveLog(auditLogRecord);
            }

            log.error("管理操作审计日志记录失败: {}", e.getMessage(), e);
            throw e;
        }
    }

    @Around("execution(* com.bucketwater.oms.module.auth.controller..*.*(..))")
    public Object logAuthOperations(ProceedingJoinPoint joinPoint) throws Throwable {
        com.bucketwater.oms.module.audit.entity.AuditLog auditLogRecord = new com.bucketwater.oms.module.audit.entity.AuditLog();
        long startTime = System.currentTimeMillis();
        Object[] args = null;

        try {
            HttpServletRequest request = getCurrentRequest();
            if (request != null) {
                auditLogRecord.setRequestUrl(request.getRequestURI());
                auditLogRecord.setRequestMethod(request.getMethod());
                auditLogRecord.setIpAddress(getClientIp(request));
                auditLogRecord.setUserAgent(request.getHeader("User-Agent"));
            }

            MethodSignature signature = (MethodSignature) joinPoint.getSignature();
            Method method = signature.getMethod();
            String className = joinPoint.getTarget().getClass().getSimpleName();
            auditLogRecord.setMethod(className + "." + method.getName());

            String action = determineActionFromMethod(method);
            auditLogRecord.setAction(action);
            auditLogRecord.setModule("system");

            args = joinPoint.getArgs();
            if (args != null && args.length > 0 && args[0] != null) {
                String params = extractRequestParams(args, method);
                if (params != null && params.contains("password")) {
                    params = params.replaceAll("\"password\"\\s*:\\s*\"[^\"]*\"", "\"password\":\"******\"");
                }
                auditLogRecord.setRequestParams(params);
            }

            Object result = joinPoint.proceed();

            long duration = System.currentTimeMillis() - startTime;
            auditLogRecord.setResponseStatus(200);
            auditLogRecord.setCreateTime(LocalDateTime.now());

            com.bucketwater.oms.module.auth.dto.LoginResponse loginResult = 
                result instanceof Result ? ((Result<?>)result).getData() instanceof LoginResponse ? 
                    (com.bucketwater.oms.module.auth.dto.LoginResponse) ((Result<?>)result).getData() : null : null;
            if (loginResult != null && loginResult.getUser() != null) {
                auditLogRecord.setUsername(loginResult.getUser().getName());
                auditLogRecord.setUserRole(loginResult.getUser().getRole());
            }

            log.info("认证操作审计: action={}, module={}, ip={}, duration={}ms, success={}",
                    action, "system", auditLogRecord.getIpAddress(), duration, result instanceof Result && ((Result<?>)result).isSuccess());

            auditLogService.saveLog(auditLogRecord);

            return result;

        } catch (Exception e) {
            if (auditLogRecord != null) {
                auditLogRecord.setResponseStatus(500);
                auditLogRecord.setErrorMessage(e.getMessage());
                auditLogRecord.setCreateTime(LocalDateTime.now());

                if (args != null && args.length > 0 && args[0] != null) {
                    try {
                        String params = objectMapper.writeValueAsString(args[0]);
                        if (params.contains("password")) {
                            params = params.replaceAll("\"password\"\\s*:\\s*\"[^\"]*\"", "\"password\":\"******\"");
                        }
                        auditLogRecord.setRequestParams(params);
                    } catch (Exception ignored) {}
                }

                log.info("认证操作审计失败: action={}, module={}, ip={}, error={}",
                        auditLogRecord.getAction(), "system", auditLogRecord.getIpAddress(), e.getMessage());

                auditLogService.saveLog(auditLogRecord);
            }

            log.error("认证操作审计日志记录失败: {}", e.getMessage(), e);
            throw e;
        }
    }

    @Around("execution(* com.bucketwater.oms.module.export.controller..*.*(..))")
    public Object logExportOperations(ProceedingJoinPoint joinPoint) throws Throwable {
        com.bucketwater.oms.module.audit.entity.AuditLog auditLogRecord = new com.bucketwater.oms.module.audit.entity.AuditLog();
        long startTime = System.currentTimeMillis();

        try {
            HttpServletRequest request = getCurrentRequest();
            if (request != null) {
                auditLogRecord.setRequestUrl(request.getRequestURI());
                auditLogRecord.setRequestMethod(request.getMethod());
                auditLogRecord.setIpAddress(getClientIp(request));
                auditLogRecord.setUserAgent(request.getHeader("User-Agent"));
            }

            User currentUser = getCurrentUser(request);
            if (currentUser != null) {
                auditLogRecord.setUserId(currentUser.getId());
                auditLogRecord.setUsername(currentUser.getName());
                auditLogRecord.setUserRole(currentUser.getRole());
            }

            MethodSignature signature = (MethodSignature) joinPoint.getSignature();
            Method method = signature.getMethod();
            String className = joinPoint.getTarget().getClass().getSimpleName();
            auditLogRecord.setMethod(className + "." + method.getName());

            String action = determineActionFromMethod(method);
            auditLogRecord.setAction(action);
            auditLogRecord.setModule("report");

            Object[] args = joinPoint.getArgs();
            String params = extractRequestParams(args, method);
            auditLogRecord.setRequestParams(params);

            Object entityId = extractPathVariable(args, method, "statementId");
            if (entityId != null) {
                auditLogRecord.setEntityId(entityId.toString());
                auditLogRecord.setEntityType("statement");
            }

            entityId = extractPathVariable(args, method, "orderId");
            if (entityId != null) {
                auditLogRecord.setEntityId(entityId.toString());
                auditLogRecord.setEntityType("order");
            }

            Object result = joinPoint.proceed();

            long duration = System.currentTimeMillis() - startTime;
            auditLogRecord.setResponseStatus(200);
            auditLogRecord.setCreateTime(LocalDateTime.now());

            log.info("导出操作审计: user={}, action={}, module={}, entity={}, duration={}ms",
                    auditLogRecord.getUsername(), action, "report",
                    auditLogRecord.getEntityId() != null ? auditLogRecord.getEntityId() : "N/A", duration);

            auditLogService.saveLog(auditLogRecord);

            return result;

        } catch (Exception e) {
            if (auditLogRecord != null) {
                auditLogRecord.setResponseStatus(500);
                auditLogRecord.setErrorMessage(e.getMessage());
                auditLogRecord.setCreateTime(LocalDateTime.now());
                auditLogService.saveLog(auditLogRecord);
            }

            log.error("导出操作审计日志记录失败: {}", e.getMessage(), e);
            throw e;
        }
    }

    private String determineAction(Method method, com.bucketwater.oms.module.audit.annotation.AuditLog auditLog) {
        if (!auditLog.action().isEmpty()) {
            return auditLog.action();
        }

        return determineActionFromMethod(method);
    }

    private String determineActionFromMethod(Method method) {
        String methodName = method.getName().toLowerCase();

        if (methodName.startsWith("create") || methodName.startsWith("save")) {
            return "CREATE";
        } else if (methodName.startsWith("update") || methodName.startsWith("edit")) {
            return "UPDATE";
        } else if (methodName.startsWith("delete") || methodName.startsWith("remove")) {
            return "DELETE";
        } else if (methodName.startsWith("get") || methodName.startsWith("find") || methodName.startsWith("query")) {
            return "QUERY";
        } else if (methodName.startsWith("login")) {
            return "LOGIN";
        } else if (methodName.startsWith("logout")) {
            return "LOGOUT";
        } else if (methodName.contains("export")) {
            return "EXPORT";
        } else if (methodName.contains("import")) {
            return "IMPORT";
        } else if (methodName.contains("reset")) {
            return "RESET";
        } else if (methodName.contains("status")) {
            return "UPDATE";
        }

        return "OTHER";
    }

    private String determineModuleFromPath(HttpServletRequest request) {
        if (request == null) {
            return "unknown";
        }

        String uri = request.getRequestURI();
        if (uri.contains("/stations")) {
            return "station";
        } else if (uri.contains("/drivers")) {
            return "driver";
        } else if (uri.contains("/warehouses")) {
            return "warehouse";
        } else if (uri.contains("/products")) {
            return "product";
        } else if (uri.contains("/orders")) {
            return "order";
        } else if (uri.contains("/policies")) {
            return "policy";
        } else if (uri.contains("/system")) {
            return "system";
        } else if (uri.contains("/regions")) {
            return "region";
        } else if (uri.contains("/finance")) {
            return "finance";
        } else if (uri.contains("/reports")) {
            return "report";
        } else if (uri.contains("/inventory")) {
            return "inventory";
        } else if (uri.contains("/audit-logs")) {
            return "audit";
        }

        return "admin";
    }

    private String extractParameterValue(Object[] args, Method method, String paramName) {
        if (paramName == null || paramName.isEmpty() || args == null || args.length == 0) {
            return null;
        }

        Parameter[] parameters = method.getParameters();
        for (int i = 0; i < parameters.length; i++) {
            if (parameters[i].getName().equals(paramName)) {
                Object value = args[i];
                return value != null ? value.toString() : null;
            }
        }

        return null;
    }

    private Object extractPathVariable(Object[] args, Method method, String paramName) {
        if (args == null || args.length == 0) {
            return null;
        }

        Parameter[] parameters = method.getParameters();
        for (int i = 0; i < parameters.length; i++) {
            PathVariable pathVariable = parameters[i].getAnnotation(PathVariable.class);
            if (pathVariable != null && parameters[i].getName().equals(paramName)) {
                return args[i];
            }
        }

        return null;
    }

    private String extractRequestParams(Object[] args, Method method) {
        if (args == null || args.length == 0) {
            return null;
        }

        try {
            Parameter[] parameters = method.getParameters();
            Object paramObj = null;

            for (int i = 0; i < parameters.length; i++) {
                RequestParam requestParam = parameters[i].getAnnotation(RequestParam.class);
                if (requestParam == null && !isPathVariable(parameters[i])) {
                    paramObj = args[i];
                    break;
                }
            }

            if (paramObj != null) {
                String json = objectMapper.writeValueAsString(paramObj);
                if (json.length() > 2000) {
                    json = json.substring(0, 2000) + "...(truncated)";
                }
                return json;
            }
        } catch (Exception e) {
            log.warn("提取请求参数失败: {}", e.getMessage());
        }

        return null;
    }

    private boolean isPathVariable(Parameter parameter) {
        return parameter.getAnnotation(PathVariable.class) != null;
    }

    private HttpServletRequest getCurrentRequest() {
        try {
            ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            return attributes != null ? attributes.getRequest() : null;
        } catch (Exception e) {
            return null;
        }
    }

    private User getCurrentUser(HttpServletRequest request) {
        try {
            if (request == null) {
                return null;
            }

            String authHeader = request.getHeader("Authorization");
            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                return null;
            }

            String token = authHeader.substring(7);
            Claims claims = Jwts.parser()
                    .verifyWith(getSigningKey())
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();

            String userId = claims.getSubject();
            if (userId == null || userId.isEmpty()) {
                return null;
            }

            try {
                Long id = Long.parseLong(userId);
                return userMapper.selectById(id);
            } catch (NumberFormatException e) {
                log.warn("无效的用户ID格式：userId={}", userId);
                return null;
            }
        } catch (Exception e) {
            log.debug("获取当前用户失败: {}", e.getMessage());
            return null;
        }
    }

    private SecretKey getSigningKey() {
        byte[] keyBytes = jwtSecret.getBytes(StandardCharsets.UTF_8);
        return io.jsonwebtoken.security.Keys.hmacShaKeyFor(keyBytes);
    }

    private String getClientIp(HttpServletRequest request) {
        if (request == null) {
            return "unknown";
        }

        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("WL-Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("HTTP_CLIENT_IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("HTTP_X_FORWARDED_FOR");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }

        if (ip != null && ip.contains(",")) {
            ip = ip.split(",")[0].trim();
        }

        return ip;
    }
}
