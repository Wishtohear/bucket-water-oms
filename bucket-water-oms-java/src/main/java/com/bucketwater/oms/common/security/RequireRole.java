package com.bucketwater.oms.common.security;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * 权限注解 - 用于控制接口访问权限
 * 
 * 使用示例：
 * @RequireRole({"PLATFORM_ADMIN"}) - 仅平台管理员可访问
 * @RequireRole({"PLATFORM_ADMIN", "FACTORY_ADMIN"}) - 平台管理员或水厂管理员可访问
 */
@Target({ElementType.METHOD, ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
public @interface RequireRole {
    /**
     * 允许访问的角色列表
     * 用户需要具有列表中的任意一个角色即可访问
     */
    String[] value();
    
    /**
     * 是否要求用户必须属于某个水厂
     * 如果为true，当用户是FACTORY_ADMIN时，必须有factoryId才能访问
     * 默认为false，允许平台管理员（无需水厂）访问
     */
    boolean requireFactory() default false;
}
