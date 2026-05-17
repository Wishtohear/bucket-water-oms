package com.bucketwater.oms.common.security;

import com.bucketwater.oms.common.enums.UserRole;
import com.bucketwater.oms.module.user.entity.User;

/**
 * 用户上下文工具类
 * 用于获取当前登录用户的信息和权限
 */
public class UserContext {

    /**
     * 判断当前用户是否是平台管理员
     */
    public static boolean isPlatformAdmin(User user) {
        if (user == null || user.getRole() == null) {
            return false;
        }
        return "PLATFORM_ADMIN".equalsIgnoreCase(user.getRole()) 
            || "platform".equalsIgnoreCase(user.getRole());
    }

    /**
     * 判断当前用户是否是水厂管理员
     */
    public static boolean isFactoryAdmin(User user) {
        if (user == null || user.getRole() == null) {
            return false;
        }
        return "FACTORY_ADMIN".equalsIgnoreCase(user.getRole()) 
            || "admin".equalsIgnoreCase(user.getRole());
    }

    /**
     * 判断当前用户是否可以访问所有数据（平台管理员）
     * 平台管理员可以访问所有水厂的数据
     */
    public static boolean canAccessAllData(User user) {
        return isPlatformAdmin(user);
    }

    /**
     * 获取当前用户的水厂ID
     * 如果是平台管理员，返回null（可以访问所有水厂）
     * 如果是水厂管理员，返回其关联的水厂ID
     */
    public static Long getFactoryId(User user) {
        if (user == null) {
            return null;
        }
        
        if (isPlatformAdmin(user)) {
            return null;
        }
        
        return user.getFactoryId();
    }

    /**
     * 判断用户是否具有指定角色的权限
     * 平台管理员具有所有角色的权限
     */
    public static boolean hasRole(User user, String... roles) {
        if (user == null || user.getRole() == null) {
            return false;
        }
        
        if (isPlatformAdmin(user)) {
            return true;
        }
        
        String userRole = user.getRole().toUpperCase();
        for (String role : roles) {
            if (userRole.equals(role.toUpperCase())) {
                return true;
            }
        }
        return false;
    }
}
