package com.bucketwater.oms.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConditionalOnProperty(name = "springdoc.swagger-ui.enabled", havingValue = "true", matchIfMissing = false)
public class SwaggerConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("水厂订货管理系统 API")
                        .version("1.0")
                        .description("水厂订货管理系统后端API文档，提供水站管理、订单管理、仓库管理、司机配送、空桶流转、财务对账等接口")
                        .contact(new Contact()
                                .name("水厂管理系统团队")
                                .email("support@bucketwater.com")
                                .url("https://www.bucketwater.com"))
                        .license(new License()
                                .name("Apache 2.0")
                                .url("https://www.apache.org/licenses/LICENSE-2.0.html")));
    }
}
