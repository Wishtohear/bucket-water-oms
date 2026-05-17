package com.bucketwater.oms.config;

import com.bucketwater.oms.common.security.RoleAuthorizationInterceptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Autowired
    private RoleAuthorizationInterceptor roleAuthorizationInterceptor;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(roleAuthorizationInterceptor)
                .addPathPatterns("/admin/**")
                .addPathPatterns("/platform/**")
                .excludePathPatterns(
                        "/admin/auth/**",
                        "/admin/dashboard",
                        "/platform/auth/login",
                        "/platform/auth/refresh"
                );
    }
}
