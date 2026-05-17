package com.bucketwater.oms.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

import java.util.Arrays;

@Configuration
public class CorsConfig {

    @Value("${cors.enabled:true}")
    private boolean corsEnabled;

    @Value("${cors.allowed-origins:*}")
    private String allowedOrigins;

    @Bean
    public CorsFilter corsFilter() {
        CorsConfiguration config = new CorsConfiguration();
        
        if (corsEnabled) {
            if ("*".equals(allowedOrigins)) {
                config.setAllowedOriginPatterns(Arrays.asList("*"));
            } else {
                config.setAllowedOriginPatterns(Arrays.asList(allowedOrigins.split(",")));
            }
            config.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
            config.setAllowedHeaders(Arrays.asList("*"));
            config.setAllowCredentials(true);
            config.setMaxAge(3600L);
        } else {
            config.setAllowedOriginPatterns(Arrays.asList());
            config.setAllowedMethods(Arrays.asList());
            config.setAllowedHeaders(Arrays.asList());
            config.setAllowCredentials(false);
            config.setMaxAge(0L);
        }

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return new CorsFilter(source);
    }
}
