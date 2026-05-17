package com.bucketwater.oms.module.order.service;

import com.bucketwater.oms.module.order.entity.Order;
import com.bucketwater.oms.module.order.mapper.OrderMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Component
public class OrderTimeoutCheckTask {

    private static final Logger log = LoggerFactory.getLogger(OrderTimeoutCheckTask.class);

    @Autowired
    private OrderMapper orderMapper;

    @Value("${order.timeout.minutes:30}")
    private int orderTimeoutMinutes;

    @Value("${order.auto-cancel-enabled:true}")
    private boolean autoCancelEnabled;

    @Scheduled(fixedRate = 60000)
    @Transactional
    public void checkOrderTimeout() {
        if (!autoCancelEnabled) {
            log.debug("自动取消超时订单功能已禁用");
            return;
        }

        log.info("开始检查超时订单...");

        LocalDateTime timeoutTime = LocalDateTime.now().minusMinutes(orderTimeoutMinutes);

        List<Order> timeoutOrders = orderMapper.selectPendingReviewOrders(timeoutTime);
        
        if (timeoutOrders.isEmpty()) {
            log.info("没有超时未接单的订单");
            return;
        }

        log.info("发现 {} 个超时未接单的订单", timeoutOrders.size());

        for (Order order : timeoutOrders) {
            try {
                cancelTimeoutOrder(order);
            } catch (Exception e) {
                log.error("处理超时订单失败: orderId={}", order.getId(), e);
            }
        }

        log.info("超时订单检查完成");
    }

    private void cancelTimeoutOrder(Order order) {
        log.info("自动取消超时订单: orderId={}, orderNo={}, createTime={}", 
            order.getId(), order.getOrderNo(), order.getCreateTime());

        order.setStatus("cancelled");
        order.setRejectReason("订单超时未接单，系统自动取消");
        order.setUpdateTime(LocalDateTime.now());
        orderMapper.updateById(order);
        
        log.info("超时订单已自动取消: orderId={}", order.getId());
    }
}
