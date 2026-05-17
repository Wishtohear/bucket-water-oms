package com.bucketwater.oms.module.audit.annotation;

import java.lang.annotation.*;

@Target({ElementType.METHOD, ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface AuditLog {
    String action() default "";
    String module() default "";
    String entityType() default "";
    String entityIdParam() default "";
    String entityNameParam() default "";
}
