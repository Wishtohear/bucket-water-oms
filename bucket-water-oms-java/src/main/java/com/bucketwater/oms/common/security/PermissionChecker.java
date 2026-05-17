package com.bucketwater.oms.common.security;

import com.bucketwater.oms.common.enums.UserRole;
import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.user.entity.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.List;

@Component
public class PermissionChecker {

    private static final Logger log = LoggerFactory.getLogger(PermissionChecker.class);

    public void checkUploadPermission(User user, String uploadType) {
        if (user == null) {
            log.warn("文件上传权限检查失败：用户为空");
            throw new BusinessException(ResultCode.UNAUTHORIZED, "用户未登录");
        }

        String role = user.getRole();
        if (role == null) {
            log.warn("文件上传权限检查失败：用户角色为空, userId={}", user.getId());
            throw new BusinessException(ResultCode.FORBIDDEN, "用户角色未设置");
        }

        boolean hasPermission = switch (uploadType) {
            case "photos" -> canUploadPhotos(role);
            case "signatures" -> canUploadSignatures(role);
            case "documents" -> canUploadDocuments(role);
            case "certs" -> canUploadCerts(role);
            default -> canUploadOther(role);
        };

        if (!hasPermission) {
            log.warn("文件上传权限检查失败：用户角色={} 无权上传类型={}的文件", role, uploadType);
            throw new BusinessException(ResultCode.FORBIDDEN, "无权执行此操作");
        }

        log.debug("文件上传权限检查通过：用户角色={}, 上传类型={}", role, uploadType);
    }

    private boolean canUploadPhotos(String role) {
        if (isPlatformAdmin(role)) {
            return true;
        }
        return switch (role) {
            case "FACTORY_ADMIN", "WAREHOUSE_ADMIN", "DRIVER", "STATION_OWNER", "STATION_CLERK" -> true;
            default -> false;
        };
    }

    private boolean canUploadSignatures(String role) {
        if (isPlatformAdmin(role)) {
            return true;
        }
        return switch (role) {
            case "FACTORY_ADMIN", "WAREHOUSE_ADMIN", "DRIVER", "STATION_OWNER" -> true;
            default -> false;
        };
    }

    private boolean canUploadDocuments(String role) {
        if (isPlatformAdmin(role)) {
            return true;
        }
        return switch (role) {
            case "FACTORY_ADMIN", "WAREHOUSE_ADMIN", "STATION_OWNER" -> true;
            default -> false;
        };
    }

    private boolean canUploadCerts(String role) {
        if (isPlatformAdmin(role)) {
            return true;
        }
        return "FACTORY_ADMIN".equals(role);
    }

    private boolean canUploadOther(String role) {
        if (isPlatformAdmin(role)) {
            return true;
        }
        return switch (role) {
            case "FACTORY_ADMIN", "WAREHOUSE_ADMIN", "DRIVER", "STATION_OWNER", "STATION_CLERK" -> true;
            default -> false;
        };
    }

    public void checkRole(User user, UserRole... allowedRoles) {
        if (user == null) {
            throw new BusinessException(ResultCode.UNAUTHORIZED, "用户未登录");
        }

        String role = user.getRole();
        if (role == null) {
            throw new BusinessException(ResultCode.FORBIDDEN, "用户角色未设置");
        }

        if (isPlatformAdmin(role)) {
            log.debug("平台管理员拥有所有权限");
            return;
        }

        List<UserRole> roleList = Arrays.asList(allowedRoles);
        boolean hasRole = roleList.stream()
            .anyMatch(r -> r.name().equals(role) || r.name().equals(convertFrontendRoleToBackend(role)));

        if (!hasRole) {
            log.warn("角色权限检查失败：用户角色={}，要求角色={}", role, Arrays.toString(allowedRoles));
            throw new BusinessException(ResultCode.FORBIDDEN, "无权执行此操作");
        }
    }

    public void checkRole(User user, String... allowedRoles) {
        if (user == null) {
            throw new BusinessException(ResultCode.UNAUTHORIZED, "用户未登录");
        }

        String role = user.getRole();
        if (role == null) {
            throw new BusinessException(ResultCode.FORBIDDEN, "用户角色未设置");
        }

        if (isPlatformAdmin(role)) {
            log.debug("平台管理员拥有所有权限");
            return;
        }

        boolean hasRole = Arrays.stream(allowedRoles)
            .anyMatch(r -> r.equals(role) || r.equals(convertFrontendRoleToBackend(role)));

        if (!hasRole) {
            log.warn("角色权限检查失败：用户角色={}，要求角色={}", role, Arrays.toString(allowedRoles));
            throw new BusinessException(ResultCode.FORBIDDEN, "无权执行此操作");
        }
    }

    public boolean hasRole(User user, String... allowedRoles) {
        if (user == null) {
            return false;
        }

        String userRole = user.getRole();
        if (userRole == null) {
            return false;
        }

        if (isPlatformAdmin(userRole)) {
            return true;
        }

        return Arrays.stream(allowedRoles)
            .anyMatch(r -> r.equals(userRole) || r.equals(convertFrontendRoleToBackend(userRole)));
    }

    public boolean isPlatformAdmin(User user) {
        if (user == null || user.getRole() == null) {
            return false;
        }
        return isPlatformAdmin(user.getRole());
    }

    private boolean isPlatformAdmin(String role) {
        return "PLATFORM_ADMIN".equalsIgnoreCase(role) || "platform".equalsIgnoreCase(role);
    }

    private String convertFrontendRoleToBackend(String frontendRole) {
        return switch (frontendRole) {
            case "station" -> "STATION_OWNER";
            case "driver" -> "DRIVER";
            case "warehouse" -> "WAREHOUSE_ADMIN";
            case "admin" -> "FACTORY_ADMIN";
            case "clerk", "staff" -> "STATION_CLERK";
            case "platform" -> "PLATFORM_ADMIN";
            default -> frontendRole;
        };
    }
}
