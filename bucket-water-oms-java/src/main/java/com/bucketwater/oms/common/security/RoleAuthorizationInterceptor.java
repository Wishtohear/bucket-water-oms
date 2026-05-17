package com.bucketwater.oms.common.security;

import com.bucketwater.oms.common.enums.UserRole;
import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.user.entity.User;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.method.HandlerMethod;
import org.springframework.web.servlet.HandlerInterceptor;

import java.lang.reflect.Method;
import java.util.Arrays;
import java.util.Optional;

/**
 * 角色权限拦截器
 * 用于检查用户是否具有访问接口所需的角色权限
 */
@Component
public class RoleAuthorizationInterceptor implements HandlerInterceptor {

    private static final Logger log = LoggerFactory.getLogger(RoleAuthorizationInterceptor.class);

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        if (!(handler instanceof HandlerMethod)) {
            return true;
        }

        HandlerMethod handlerMethod = (HandlerMethod) handler;
        Method method = handlerMethod.getMethod();
        
        RequireRole methodAnnotation = method.getAnnotation(RequireRole.class);
        RequireRole classAnnotation = handlerMethod.getBeanType().getAnnotation(RequireRole.class);
        
        RequireRole requireRole = methodAnnotation != null ? methodAnnotation : classAnnotation;
        
        if (requireRole == null) {
            return true;
        }

        Optional<User> currentUserOpt = JwtAuthenticationFilter.getCurrentUser(request);
        if (currentUserOpt.isEmpty()) {
            log.warn("用户未登录，接口: {}", request.getRequestURI());
            throw new BusinessException(ResultCode.UNAUTHORIZED, "请先登录");
        }

        User user = currentUserOpt.get();
        
        request.setAttribute("currentUserRole", user.getRole());
        request.setAttribute("currentUserFactoryId", user.getFactoryId());
        request.setAttribute("isPlatformAdmin", UserContext.isPlatformAdmin(user));
        String userRole = user.getRole();

        if (userRole == null) {
            log.warn("用户角色为空，userId: {}", user.getId());
            throw new BusinessException(ResultCode.FORBIDDEN, "用户角色未设置");
        }

        String[] allowedRoles = requireRole.value();
        boolean hasRole = Arrays.stream(allowedRoles)
                .anyMatch(role -> matchRole(role, userRole));

        if (!hasRole) {
            log.warn("用户角色不匹配，userRole: {}, requiredRoles: {}", userRole, Arrays.toString(allowedRoles));
            throw new BusinessException(ResultCode.FORBIDDEN, "您没有权限访问此接口");
        }

        if (requireRole.requireFactory()) {
            if (isFactoryAdmin(userRole) && user.getFactoryId() == null) {
                log.warn("水厂管理员缺少水厂ID，userId: {}", user.getId());
                throw new BusinessException(ResultCode.FORBIDDEN, "水厂管理员必须关联水厂");
            }
        }

        log.debug("权限验证通过，userId: {}, role: {}, interface: {}", user.getId(), userRole, request.getRequestURI());
        return true;
    }

    private boolean matchRole(String requiredRole, String userRole) {
        if (requiredRole.equalsIgnoreCase(userRole)) {
            return true;
        }

        UserRole required = UserRole.valueOf(requiredRole.toUpperCase());
        UserRole actual = UserRole.valueOf(userRole.toUpperCase());

        if (required == UserRole.PLATFORM_ADMIN) {
            return actual == UserRole.PLATFORM_ADMIN;
        }

        if (required == UserRole.FACTORY_ADMIN) {
            return actual == UserRole.FACTORY_ADMIN || actual == UserRole.PLATFORM_ADMIN;
        }

        if (required == UserRole.WAREHOUSE_ADMIN) {
            return actual == UserRole.WAREHOUSE_ADMIN || actual == UserRole.FACTORY_ADMIN || actual == UserRole.PLATFORM_ADMIN;
        }

        if (required == UserRole.DRIVER) {
            return actual == UserRole.DRIVER || actual == UserRole.FACTORY_ADMIN || actual == UserRole.PLATFORM_ADMIN;
        }

        if (required == UserRole.STATION_OWNER || required == UserRole.STATION_CLERK) {
            return actual == UserRole.STATION_OWNER || actual == UserRole.STATION_CLERK 
                    || actual == UserRole.FACTORY_ADMIN || actual == UserRole.PLATFORM_ADMIN;
        }

        return false;
    }

    private boolean isFactoryAdmin(String role) {
        return "FACTORY_ADMIN".equalsIgnoreCase(role) || "admin".equalsIgnoreCase(role);
    }
}
