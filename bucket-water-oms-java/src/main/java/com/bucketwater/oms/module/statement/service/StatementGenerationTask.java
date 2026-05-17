package com.bucketwater.oms.module.statement.service;

import com.bucketwater.oms.module.notification.service.NotificationService;
import com.bucketwater.oms.module.order.entity.Order;
import com.bucketwater.oms.module.order.mapper.OrderMapper;
import com.bucketwater.oms.module.station.entity.Station;
import com.bucketwater.oms.module.station.entity.StationAccount;
import com.bucketwater.oms.module.station.mapper.StationMapper;
import com.bucketwater.oms.module.station.mapper.StationAccountMapper;
import com.bucketwater.oms.module.statement.entity.MonthlyStatement;
import com.bucketwater.oms.module.statement.mapper.MonthlyStatementMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Component
public class StatementGenerationTask {

    private static final Logger log = LoggerFactory.getLogger(StatementGenerationTask.class);

    @Autowired
    private MonthlyStatementMapper statementMapper;

    @Autowired
    private StationMapper stationMapper;

    @Autowired
    private StationAccountMapper stationAccountMapper;

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private NotificationService notificationService;

    @Scheduled(cron = "0 0 2 1 * ?")
    @Transactional
    public void generateMonthlyStatements() {
        log.info("开始自动生成上月对账单...");

        LocalDate today = LocalDate.now();
        LocalDate lastMonth = today.minusMonths(1);
        String yearMonth = String.format("%04d-%02d", lastMonth.getYear(), lastMonth.getMonthValue());
        LocalDate startDate = lastMonth.withDayOfMonth(1);
        LocalDate endDate = lastMonth.withDayOfMonth(lastMonth.lengthOfMonth());

        List<Station> stations = stationMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Station>()
                .eq(Station::getStatus, "active")
        );

        int generatedCount = 0;
        for (Station station : stations) {
            try {
                MonthlyStatement existingStatement = statementMapper.selectOne(
                    new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<MonthlyStatement>()
                        .eq(MonthlyStatement::getStationId, station.getId())
                        .eq(MonthlyStatement::getYearMonth, yearMonth)
                );

                if (existingStatement != null) {
                    log.info("水站{}的{}月份对账单已存在，跳过", station.getName(), yearMonth);
                    continue;
                }

                StationAccount account = stationAccountMapper.selectOne(
                    new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StationAccount>()
                        .eq(StationAccount::getStationId, station.getId())
                );

                List<Order> monthOrders = orderMapper.selectList(
                    new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Order>()
                        .eq(Order::getStationId, station.getId())
                        .ge(Order::getCreateTime, startDate.atStartOfDay())
                        .le(Order::getCreateTime, endDate.atTime(23, 59, 59))
                        .in(Order::getStatus, "completed", "rejected")
                );

                BigDecimal totalAmount = monthOrders.stream()
                    .map(Order::getTotalAmount)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

                BigDecimal openingBalance = account != null ? account.getDepositBalance() : BigDecimal.ZERO;
                BigDecimal closingBalance = openingBalance.subtract(totalAmount);

                MonthlyStatement statement = new MonthlyStatement();
                statement.setStationId(station.getId());
                statement.setYearMonth(yearMonth);
                statement.setStartDate(startDate);
                statement.setEndDate(endDate);
                statement.setOpeningBalance(openingBalance);
                statement.setTotalAmount(totalAmount);
                statement.setPaymentReceived(BigDecimal.ZERO);
                statement.setClosingBalance(closingBalance);
                statement.setStatus("generated");
                statement.setGeneratedAt(LocalDateTime.now());

                statementMapper.insert(statement);

                notificationService.sendStatementNotification(station.getId(), yearMonth);

                generatedCount++;
                log.info("成功生成水站{}的{}月份对账单，金额:{}", station.getName(), yearMonth, totalAmount);

            } catch (Exception e) {
                log.error("生成水站{}的对账单失败: {}", station.getName(), e.getMessage(), e);
            }
        }

        log.info("对账单自动生成完成，共生成{}份", generatedCount);
    }

    @Scheduled(cron = "0 0 9 * * ?")
    public void sendOrderTimeoutReminders() {
        log.info("检查超时未接单订单...");

        List<Order> pendingOrders = orderMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Order>()
                .eq(Order::getStatus, "pending_review")
                .lt(Order::getCreateTime, LocalDateTime.now().minusHours(2))
        );

        for (Order order : pendingOrders) {
            log.warn("订单{}已超时2小时未处理", order.getOrderNo());
        }
    }
}
