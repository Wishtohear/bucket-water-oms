package com.bucketwater.oms.module.driver.service;

import com.bucketwater.oms.module.driver.entity.Driver;
import com.bucketwater.oms.module.driver.mapper.DriverMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Component
public class DriverStatusCheckTask {

    private static final Logger log = LoggerFactory.getLogger(DriverStatusCheckTask.class);

    private static final int OFFLINE_THRESHOLD_MINUTES = 10;

    @Autowired
    private DriverMapper driverMapper;

    @Scheduled(fixedRate = 60000)
    @Transactional
    public void checkDriverOnlineStatus() {
        LocalDateTime threshold = LocalDateTime.now().minusMinutes(OFFLINE_THRESHOLD_MINUTES);

        List<Driver> onlineDrivers = driverMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Driver>()
                .eq(Driver::getOnlineStatus, "online")
        );

        int offlineCount = 0;
        for (Driver driver : onlineDrivers) {
            LocalDateTime lastActivity = driver.getLastOnlineTime();
            if (lastActivity == null) {
                lastActivity = driver.getLastLocationTime();
            }

            if (lastActivity != null && lastActivity.isBefore(threshold)) {
                driver.setOnlineStatus("offline");
                driver.setLastOnlineTime(LocalDateTime.now());
                driverMapper.updateById(driver);
                offlineCount++;
                log.info("司机[{}]因超过{}分钟未活动，已自动设为离线",
                    driver.getName(), OFFLINE_THRESHOLD_MINUTES);
            }
        }

        if (offlineCount > 0) {
            log.info("本次检查共{}位司机被自动设为离线", offlineCount);
        }
    }
}
