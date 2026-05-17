package com.bucketwater.oms.module.notification.service;

import com.bucketwater.oms.module.notification.entity.Notification;
import com.bucketwater.oms.module.notification.mapper.NotificationMapper;
import com.bucketwater.oms.module.station.entity.Station;
import com.bucketwater.oms.module.station.entity.StationAccount;
import com.bucketwater.oms.module.station.mapper.StationAccountMapper;
import com.bucketwater.oms.module.station.mapper.StationMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;

@Component
public class NotificationTask {

    private static final Logger log = LoggerFactory.getLogger(NotificationTask.class);

    @Autowired
    private NotificationMapper notificationMapper;

    @Autowired
    private StationMapper stationMapper;

    @Autowired
    private StationAccountMapper stationAccountMapper;

    @Autowired
    private NotificationService notificationService;

    @Scheduled(cron = "0 0 9 * * ?")
    public void checkBucketWarnings() {
        log.info("开始检查欠桶预警...");

        List<Station> activeStations = stationMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Station>()
                .eq(Station::getStatus, "active")
        );

        int warnedCount = 0;
        for (Station station : activeStations) {
            try {
                StationAccount account = stationAccountMapper.selectOne(
                    new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StationAccount>()
                        .eq(StationAccount::getStationId, station.getId())
                );

                if (account == null || account.getOwedBucketNum() == null) {
                    continue;
                }

                int owedBuckets = account.getOwedBucketNum();
                int threshold = account.getOwedThreshold() != null ? account.getOwedThreshold() : 10;

                if (owedBuckets >= threshold) {
                    if (owedBuckets > threshold) {
                        notificationService.sendBucketThresholdExceededNotification(
                            station.getId(),
                            owedBuckets,
                            threshold
                        );
                        log.info("水站{}欠桶超限: {}个，已发送超限通知", station.getName(), owedBuckets);
                    } else {
                        if (!hasSentWarningToday(station.getId(), "bucket_warning")) {
                            notificationService.sendBucketWarningNotification(
                                station.getId(),
                                owedBuckets,
                                threshold
                            );
                            log.info("水站{}欠桶预警: {}个，已发送预警通知", station.getName(), owedBuckets);
                        }
                    }
                    warnedCount++;
                }
            } catch (Exception e) {
                log.error("检查水站{}欠桶预警失败: {}", station.getName(), e.getMessage(), e);
            }
        }

        log.info("欠桶预警检查完成，共{}个水站需要关注", warnedCount);
    }

    @Scheduled(cron = "0 0 10 * * ?")
    public void sendDailySummary() {
        log.info("开始发送每日摘要通知...");

        List<Station> activeStations = stationMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Station>()
                .eq(Station::getStatus, "active")
        );

        int notifiedCount = 0;
        for (Station station : activeStations) {
            try {
                StationAccount account = stationAccountMapper.selectOne(
                    new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StationAccount>()
                        .eq(StationAccount::getStationId, station.getId())
                );

                if (account == null) {
                    continue;
                }

                StringBuilder content = new StringBuilder();
                content.append("今日摘要：");

                if (account.getDepositBalance().compareTo(java.math.BigDecimal.valueOf(500)) < 0) {
                    content.append(String.format("预存金余额%.2f元，", account.getDepositBalance()));
                }

                if (account.getOwedBucketNum() >= account.getOwedThreshold()) {
                    content.append(String.format("欠桶%d个，", account.getOwedBucketNum()));
                }

                if (content.length() > 5) {
                    content.append("请及时处理");
                    notificationService.sendSystemNoticeNotification(station.getId(), content.toString());
                    notifiedCount++;
                }
            } catch (Exception e) {
                log.error("发送每日摘要给水站{}失败: {}", station.getName(), e.getMessage(), e);
            }
        }

        log.info("每日摘要通知发送完成，共{}个水站收到通知", notifiedCount);
    }

    private boolean hasSentWarningToday(Long stationId, String type) {
        LocalDateTime today = LocalDateTime.now().withHour(0).withMinute(0).withSecond(0);
        long count = notificationMapper.selectCount(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Notification>()
                .eq(Notification::getUserId, stationId)
                .eq(Notification::getType, type)
                .ge(Notification::getCreateTime, today)
        );
        return count > 0;
    }
}
