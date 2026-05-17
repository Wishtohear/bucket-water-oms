package com.bucketwater.oms.module.notification.service;

import com.bucketwater.oms.module.notification.entity.Notification;
import com.bucketwater.oms.module.notification.mapper.NotificationMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
public class NotificationService {

    private static final Logger log = LoggerFactory.getLogger(NotificationService.class);

    @Autowired
    private NotificationMapper notificationMapper;

    @Autowired
    private StringRedisTemplate redisTemplate;

    public List<Notification> getUnreadNotifications(Long userId) {
        return notificationMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Notification>()
                .eq(Notification::getUserId, userId)
                .eq(Notification::getIsRead, false)
                .orderByDesc(Notification::getCreateTime)
                .last("LIMIT 50")
        );
    }

    public List<Notification> getAllNotifications(Long userId, String type, Integer page, Integer size) {
        var wrapper = new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Notification>()
            .eq(Notification::getUserId, userId);

        if (type != null && !type.isBlank()) {
            wrapper.eq(Notification::getType, type);
        }

        int offset = (page - 1) * size;
        return notificationMapper.selectList(wrapper
            .orderByDesc(Notification::getCreateTime)
            .last("LIMIT " + size + " OFFSET " + offset));
    }

    public void markAsRead(Long notificationId) {
        Notification notification = notificationMapper.selectById(notificationId);
        if (notification != null) {
            notification.setIsRead(true);
            notification.setReadTime(LocalDateTime.now());
            notificationMapper.updateById(notification);
        }
    }

    public void markAllAsRead(Long userId) {
        List<Notification> unreadNotifications = getUnreadNotifications(userId);
        for (Notification notification : unreadNotifications) {
            notification.setIsRead(true);
            notification.setReadTime(LocalDateTime.now());
            notificationMapper.updateById(notification);
        }
    }

    public long getUnreadCount(Long userId) {
        return notificationMapper.selectCount(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Notification>()
                .eq(Notification::getUserId, userId)
                .eq(Notification::getIsRead, false)
        );
    }

    public void deleteNotification(Long notificationId) {
        notificationMapper.deleteById(notificationId);
    }

    public void sendNotification(Long userId, String type, String title, String content) {
        sendNotification(userId, type, title, content, null);
    }

    public void sendNotification(Long userId, String type, String title, String content, String relatedId) {
        try {
            Notification notification = new Notification();
            notification.setUserId(userId);
            notification.setType(type);
            notification.setTitle(title);
            notification.setContent(content);
            notification.setRelatedId(relatedId);
            notification.setIsRead(false);
            notification.setCreateTime(LocalDateTime.now());
            notificationMapper.insert(notification);

            String redisKey = "notification:" + userId.toString();
            redisTemplate.convertAndSend(redisKey, content);

            log.info("发送通知成功: userId={}, type={}, title={}", userId, type, title);
        } catch (Exception e) {
            log.error("发送通知失败: userId={}, type={}, error={}", userId, type, e.getMessage(), e);
        }
    }

    public void sendOrderCreatedNotification(Long userId, String orderNo, String warehouseName) {
        String title = "订单已提交";
        String content = String.format("订单%s已提交，等待仓库%s审查", orderNo, warehouseName);
        sendNotification(userId, "order_status", title, content, orderNo);
    }

    public void sendOrderStatusNotification(Long userId, String orderNo, String status) {
        String title = "订单状态更新";
        String content = "订单" + orderNo + "状态已更新为: " + getStatusText(status);
        sendNotification(userId, "order_status", title, content, orderNo);
    }

    public void sendOrderReviewedNotification(Long userId, String orderNo, boolean accepted, String reason) {
        String title;
        String content;
        if (accepted) {
            title = "订单已接单";
            content = "订单" + orderNo + "已被仓库接单，正在备货中";
        } else {
            title = "订单已拒单";
            content = "订单" + orderNo + "已被仓库拒绝，原因：" + (reason != null ? reason : "库存不足");
        }
        sendNotification(userId, "order_status", title, content, orderNo);
    }

    public void sendOrderDispatchedNotification(Long userId, String orderNo, String driverName, String driverPhone) {
        String title = "订单已派单";
        String content = String.format("订单%s已派单给司机%s，请保持电话%s畅通", orderNo, driverName, maskPhone(driverPhone));
        sendNotification(userId, "order_status", title, content, orderNo);
    }

    public void sendOrderDeliveringNotification(Long userId, String orderNo) {
        String title = "订单配送中";
        String content = "订单" + orderNo + "已开始配送，请注意查收";
        sendNotification(userId, "order_status", title, content, orderNo);
    }

    public void sendOrderCompletedNotification(Long userId, String orderNo, int actualQty, int bucketReturned) {
        String title = "订单已完成";
        String content = String.format("订单%s已完成配送，实收%d桶，回桶%d个", orderNo, actualQty, bucketReturned);
        sendNotification(userId, "order_status", title, content, orderNo);
    }

    public void sendOrderCancelledNotification(Long userId, String orderNo, String reason) {
        String title = "订单已取消";
        String content = "订单" + orderNo + "已取消" + (reason != null ? "，原因：" + reason : "");
        sendNotification(userId, "order_status", title, content, orderNo);
    }

    public void sendOrderRejectedNotification(Long userId, String orderNo, String reason) {
        String title = "订单已拒单";
        String content = "订单" + orderNo + "已被仓库拒绝，原因：" + (reason != null ? reason : "库存不足");
        sendNotification(userId, "order_status", title, content, orderNo);
    }

    public void sendStatementNotification(Long userId, String yearMonth) {
        String title = "对账单已生成";
        String content = yearMonth + "月份对账单已生成，请及时查看并确认";
        sendNotification(userId, "statement_ready", title, content, yearMonth);
    }

    public void sendStatementConfirmedNotification(Long userId, String yearMonth) {
        String title = "对账单已确认";
        String content = yearMonth + "月份对账单已确认，感谢您的使用";
        sendNotification(userId, "statement_ready", title, content, yearMonth);
    }

    public void sendBucketWarningNotification(Long userId, int owedBuckets, int threshold) {
        String title = "欠桶预警";
        String content = String.format("当前欠桶数量%d个，已达到阈值%d个，请及时补缴押金以确保正常下单", owedBuckets, threshold);
        sendNotification(userId, "bucket_warning", title, content);
    }

    public void sendBucketThresholdExceededNotification(Long userId, int owedBuckets, int threshold) {
        String title = "欠桶超限";
        String content = String.format("当前欠桶数量%d个，已超过阈值%d个，请立即补缴押金，否则将无法下单", owedBuckets, threshold);
        sendNotification(userId, "bucket_warning", title, content);
    }

    public void sendPaymentReminderNotification(Long userId, String amount) {
        String title = "付款提醒";
        String content = "您的账户余额不足，请及时充值，金额: " + amount + "元";
        sendNotification(userId, "payment_reminder", title, content);
    }

    public void sendBalanceLowNotification(Long userId, String balance, String required) {
        String title = "余额不足提醒";
        String content = String.format("您的预存金余额为%s元，低于订单所需金额%s元，请及时充值", balance, required);
        sendNotification(userId, "payment_reminder", title, content);
    }

    public void sendCreditLowNotification(Long userId, String availableCredit, String required) {
        String title = "信用额度不足";
        String content = String.format("您的可用信用额度为%s元，低于订单所需金额%s元，请及时还款或联系管理员", availableCredit, required);
        sendNotification(userId, "payment_reminder", title, content);
    }

    public void sendAfterSalesCreatedNotification(Long userId, String afterSalesNo, String type) {
        String title = "售后申请已提交";
        String typeText = "补货".equals(type) ? "补货" : "退款";
        String content = "您的售后申请" + afterSalesNo + "(" + typeText + ")已提交，请等待处理";
        sendNotification(userId, "after_sales", title, content, afterSalesNo);
    }

    public void sendAfterSalesProcessedNotification(Long userId, String afterSalesNo, String status, String result) {
        String title = "售后申请已处理";
        String content;
        if ("approved".equals(status)) {
            content = "您的售后申请" + afterSalesNo + "已通过，" + result;
        } else if ("rejected".equals(status)) {
            content = "您的售后申请" + afterSalesNo + "已被拒绝，原因：" + result;
        } else {
            content = "您的售后申请" + afterSalesNo + "状态已更新为：" + status;
        }
        sendNotification(userId, "after_sales", title, content, afterSalesNo);
    }

    public void sendDriverNewTaskNotification(Long userId, String orderNo, String stationName, String address) {
        String title = "新配送任务";
        String content = String.format("您有新的配送任务：订单%s，目的地：%s，请及时接单", orderNo, stationName);
        sendNotification(userId, "driver_task", title, content, orderNo);
    }

    public void sendDriverTaskReminderNotification(Long userId, String orderNo, int minutesRemaining) {
        String title = "配送任务提醒";
        String content = String.format("您有待配送订单%s，请在%d分钟内完成配送", orderNo, minutesRemaining);
        sendNotification(userId, "driver_task", title, content, orderNo);
    }

    public void sendWarehouseNewOrderNotification(Long userId, String orderNo, String stationName) {
        String title = "新订单通知";
        String content = String.format("水站%s提交了新订单%s，请及时处理", stationName, orderNo);
        sendNotification(userId, "warehouse_order", title, content, orderNo);
    }

    public void sendWarehouseDriverReturnNotification(Long userId, String driverName, int bucketCount) {
        String title = "司机回仓通知";
        String content = String.format("司机%s正在办理回仓手续，交回空桶%d个，请准备核对", driverName, bucketCount);
        sendNotification(userId, "warehouse_return", title, content);
    }

    public void sendSystemNoticeNotification(Long userId, String content) {
        String title = "系统通知";
        sendNotification(userId, "system_notice", title, content);
    }

    public void sendBatchNotifications(List<Long> userIds, String type, String title, String content) {
        for (Long userId : userIds) {
            sendNotification(userId, type, title, content);
        }
    }

    public void sendBatchNotificationsByRole(String role, String type, String title, String content) {
        log.info("向所有{}角色用户发送通知: {}", role, title);
    }

    private String getStatusText(String status) {
        return switch (status) {
            case "pending_review" -> "待审查";
            case "reviewed" -> "已接单";
            case "dispatched" -> "已派单";
            case "delivering" -> "配送中";
            case "completed" -> "已完成";
            case "cancelled" -> "已取消";
            case "rejected" -> "已拒单";
            default -> status;
        };
    }

    private String maskPhone(String phone) {
        if (phone == null || phone.length() < 7) {
            return phone;
        }
        return phone.substring(0, 3) + "****" + phone.substring(phone.length() - 4);
    }
}
