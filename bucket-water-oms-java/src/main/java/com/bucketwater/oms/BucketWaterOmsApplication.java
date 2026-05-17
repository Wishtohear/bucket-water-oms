package com.bucketwater.oms;

import lombok.extern.slf4j.Slf4j;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.info.BuildProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.scheduling.annotation.EnableScheduling;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Slf4j
@SpringBootApplication
@MapperScan("com.bucketwater.oms.module.*.mapper")
@EnableScheduling
public class BucketWaterOmsApplication implements CommandLineRunner {

    private BuildProperties buildProperties;

    @Autowired(required = false)
    public void setBuildProperties(BuildProperties buildProperties) {
        this.buildProperties = buildProperties;
    }

    public static void main(String[] args) {
        SpringApplication.run(BucketWaterOmsApplication.class, args);
    }

    @Override
    public void run(String... args) throws Exception {
        String appName = buildProperties != null ? buildProperties.getName() : "Bucket Water OMS";
        String version = buildProperties != null ? buildProperties.getVersion() : "1.0.0";

        String banner = """

                ╔═══════════════════════════════════════════════════════════╗
                ║                                                           ║
                ║              💧 水厂订货管理系统 (Bucket Water OMS)        ║
                ║                                                           ║
                ╠═══════════════════════════════════════════════════════════╣
                ║                                                           ║
                ║  ✅ Application:    {}                                   ║
                ║  📦 Version:        {}                                    ║
                ║  🕐 Start Time:     {}                                   ║
                ║  🌐 Server Port:    8080                                 ║
                ║  📚 API Docs:       http://localhost:8080/swagger-ui.html ║
                ║                                                           ║
                ║  🔐 角色说明:                                              ║
                ║     • 水厂管理员 - 开户管理、定价策略、全量报表             ║
                ║     • 仓库管理员 - 接单/拒单、备货、派单给司机             ║
                ║     • 配送司机   - 接单、配送签收、录入回桶/欠桶           ║
                ║     • 水站老板   - 下单、查看订单、对账、空桶往来         ║
                ║     • 水站店员   - 仅查看库存、协助收货确认                 ║
                ║                                                           ║
                ╚═══════════════════════════════════════════════════════════╝
                """;

        String startTime = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

        log.info(banner, appName, version, startTime);

        log.info("✨ Application started successfully!");
        log.info("📖 API Documentation: http://localhost:8080/api/swagger-ui.html");
        log.info("🔧 Actuator Health: http://localhost:8080/api/actuator/health");
    }
}
