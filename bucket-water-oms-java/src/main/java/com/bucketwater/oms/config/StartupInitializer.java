package com.bucketwater.oms.config;

import com.bucketwater.oms.module.system.service.SystemConfigService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;

@Configuration
@EnableScheduling
public class StartupInitializer implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(StartupInitializer.class);

    @Autowired
    private SystemConfigService systemConfigService;

    @Override
    public void run(ApplicationArguments args) {
        log.info("系统启动初始化...");

        try {
            systemConfigService.initDefaultConfigs();
            log.info("系统配置初始化完成");
        } catch (Exception e) {
            log.warn("系统配置初始化遇到问题: {}", e.getMessage());
        }

        log.info("系统启动完成");
    }
}
