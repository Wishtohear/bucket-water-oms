package com.bucketwater.oms.module.notification.service;

import com.bucketwater.oms.module.notification.sse.SseEmitterManager;
import com.bucketwater.oms.module.order.entity.Order;
import com.bucketwater.oms.module.order.mapper.OrderMapper;
import com.bucketwater.oms.module.station.entity.Station;
import com.bucketwater.oms.module.station.mapper.StationMapper;
import com.bucketwater.oms.module.user.entity.User;
import com.bucketwater.oms.module.user.mapper.UserMapper;
import com.bucketwater.oms.module.warehouse.entity.Warehouse;
import com.bucketwater.oms.module.warehouse.mapper.WarehouseMapper;
import com.bucketwater.oms.module.driver.entity.Driver;
import com.bucketwater.oms.module.driver.mapper.DriverMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class OrderPushService {

    private static final Logger log = LoggerFactory.getLogger(OrderPushService.class);
    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    @Autowired
    private SseEmitterManager sseEmitterManager;

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private StationMapper stationMapper;

    @Autowired
    private WarehouseMapper warehouseMapper;

    @Autowired
    private DriverMapper driverMapper;

    public static final String EVENT_ORDER_CREATED = "order_created";
    public static final String EVENT_ORDER_REVIEWED = "order_reviewed";
    public static final String EVENT_ORDER_REJECTED = "order_rejected";
    public static final String EVENT_ORDER_DISPATCHED = "order_dispatched";
    public static final String EVENT_ORDER_DELIVERING = "order_delivering";
    public static final String EVENT_ORDER_COMPLETED = "order_completed";
    public static final String EVENT_ORDER_CANCELLED = "order_cancelled";
    public static final String EVENT_NEW_DELIVERY_TASK = "new_delivery_task";

    @Autowired
    private NotificationService notificationService;

    public void pushOrderCreated(Long orderId) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            log.warn("推送订单创建消息失败: 订单不存在, orderId={}", orderId);
            return;
        }

        Map<String, Object> pushData = buildOrderPushData(order, EVENT_ORDER_CREATED, "订单已提交");
        
        pushToStationOwner(order, pushData);
        
        pushToWarehouse(order, pushData);
        
        log.info("订单创建推送完成: orderId={}, orderNo={}", orderId, order.getOrderNo());
    }

    public void pushOrderReviewed(Long orderId, boolean accepted) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            log.warn("推送订单审查消息失败: 订单不存在, orderId={}", orderId);
            return;
        }

        String eventType = accepted ? EVENT_ORDER_REVIEWED : EVENT_ORDER_REJECTED;
        String title = accepted ? "订单已接单" : "订单已拒单";
        String content = accepted 
            ? "您的订单" + order.getOrderNo() + "已被仓库接单，正在备货中" 
            : "您的订单" + order.getOrderNo() + "已被仓库拒绝";

        Map<String, Object> pushData = buildOrderPushData(order, eventType, title);
        pushData.put("accepted", accepted);

        pushToStationOwner(order, pushData);

        notificationService.sendOrderReviewedNotification(getStationOwnerUserId(order.getStationId()), order.getOrderNo(), accepted, null);

        log.info("订单审查推送完成: orderId={}, accepted={}", orderId, accepted);
    }

    public void pushOrderDispatched(Long orderId) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            log.warn("推送订单派单消息失败: 订单不存在, orderId={}", orderId);
            return;
        }

        Map<String, Object> pushData = buildOrderPushData(order, EVENT_ORDER_DISPATCHED, "订单已派单");

        pushToStationOwner(order, pushData);

        pushToDriver(order, pushData);

        log.info("订单派单推送完成: orderId={}, driverId={}", orderId, order.getDriverId());
    }

    public void pushOrderDelivering(Long orderId) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            log.warn("推送订单配送中消息失败: 订单不存在, orderId={}", orderId);
            return;
        }

        Map<String, Object> pushData = buildOrderPushData(order, EVENT_ORDER_DELIVERING, "订单配送中");

        pushToStationOwner(order, pushData);

        notificationService.sendOrderDeliveringNotification(getStationOwnerUserId(order.getStationId()), order.getOrderNo());

        log.info("订单配送中推送完成: orderId={}", orderId);
    }

    public void pushOrderCompleted(Long orderId, int actualQty, int bucketReturned) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            log.warn("推送订单完成消息失败: 订单不存在, orderId={}", orderId);
            return;
        }

        Map<String, Object> pushData = buildOrderPushData(order, EVENT_ORDER_COMPLETED, "订单已完成");
        pushData.put("actualQty", actualQty);
        pushData.put("bucketReturned", bucketReturned);

        pushToStationOwner(order, pushData);

        notificationService.sendOrderCompletedNotification(getStationOwnerUserId(order.getStationId()), order.getOrderNo(), actualQty, bucketReturned);

        log.info("订单完成推送完成: orderId={}, actualQty={}, bucketReturned={}", orderId, actualQty, bucketReturned);
    }

    public void pushOrderCancelled(Long orderId, String reason) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            log.warn("推送订单取消消息失败: 订单不存在, orderId={}", orderId);
            return;
        }

        Map<String, Object> pushData = buildOrderPushData(order, EVENT_ORDER_CANCELLED, "订单已取消");
        pushData.put("reason", reason);

        pushToStationOwner(order, pushData);

        notificationService.sendOrderCancelledNotification(getStationOwnerUserId(order.getStationId()), order.getOrderNo(), reason);

        log.info("订单取消推送完成: orderId={}, reason={}", orderId, reason);
    }

    public void pushNewDeliveryTask(Long driverId, Long orderId) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            log.warn("推送新配送任务失败: 订单不存在, orderId={}", orderId);
            return;
        }

        Driver driver = driverMapper.selectById(driverId);
        if (driver == null) {
            log.warn("推送新配送任务失败: 司机不存在, driverId={}", driverId);
            return;
        }

        Station station = order.getStationId() != null ? stationMapper.selectById(order.getStationId()) : null;

        Map<String, Object> pushData = new HashMap<>();
        pushData.put("event", EVENT_NEW_DELIVERY_TASK);
        pushData.put("orderId", orderId);
        pushData.put("orderNo", order.getOrderNo());
        pushData.put("stationName", station != null ? station.getName() : "未知水站");
        pushData.put("stationAddress", station != null ? station.getAddress() : "");
        pushData.put("driverId", driverId);
        pushData.put("driverName", driver.getName());
        pushData.put("timestamp", LocalDateTime.now().format(FORMATTER));
        pushData.put("title", "新配送任务");
        pushData.put("content", "您有新的配送任务: 订单" + order.getOrderNo() + ", 目的地: " + (station != null ? station.getName() : "未知"));

        Long driverUserId = getDriverUserId(driverId);
        if (driverUserId != null) {
            sseEmitterManager.sendToUser(driverUserId, EVENT_NEW_DELIVERY_TASK, pushData);
        }

        notificationService.sendDriverNewTaskNotification(driverUserId, order.getOrderNo(), 
            station != null ? station.getName() : "", station != null ? station.getAddress() : "");

        log.info("新配送任务推送完成: driverId={}, orderId={}", driverId, orderId);
    }

    private void pushToStationOwner(Order order, Map<String, Object> pushData) {
        Long userId = getStationOwnerUserId(order.getStationId());
        if (userId != null) {
            sseEmitterManager.sendToUser(userId, (String) pushData.get("event"), pushData);
            log.debug("推送给水站老板: userId={}, stationId={}", userId, order.getStationId());
        }
    }

    private void pushToWarehouse(Order order, Map<String, Object> pushData) {
        if (order.getWarehouseId() != null) {
            Long warehouseUserId = getWarehouseUserId(order.getWarehouseId());
            if (warehouseUserId != null) {
                sseEmitterManager.sendToUser(warehouseUserId, (String) pushData.get("event"), pushData);
                log.info("推送给指定仓库: orderId={}, warehouseId={}", order.getId(), order.getWarehouseId());
            } else {
                sseEmitterManager.sendToAllWarehouses((String) pushData.get("event"), pushData);
                log.info("仓库用户不存在，推送给所有仓库: orderId={}", order.getId());
            }
        } else {
            sseEmitterManager.sendToAllWarehouses((String) pushData.get("event"), pushData);
            log.info("订单未指定仓库，推送给所有仓库: orderId={}", order.getId());
        }
    }

    private void pushToDriver(Order order, Map<String, Object> pushData) {
        if (order.getDriverId() == null) {
            log.warn("订单未分配司机，跳过司机推送: orderId={}", order.getId());
            return;
        }

        Driver driver = driverMapper.selectById(order.getDriverId());
        if (driver == null) {
            log.warn("司机不存在: driverId={}", order.getDriverId());
            return;
        }

        Long driverUserId = getDriverUserId(order.getDriverId());
        if (driverUserId != null) {
            sseEmitterManager.sendToUser(driverUserId, EVENT_NEW_DELIVERY_TASK, pushData);
            log.info("推送给司机: orderId={}, driverId={}, driverUserId={}", order.getId(), driver.getId(), driverUserId);
        } else {
            log.warn("司机用户ID为空，无法推送: driverId={}", driver.getId());
        }
    }

    private Map<String, Object> buildOrderPushData(Order order, String event, String title) {
        Station station = null;
        Warehouse warehouse = null;
        Driver driver = null;

        if (order.getStationId() != null) {
            station = stationMapper.selectById(order.getStationId());
        }
        if (order.getWarehouseId() != null) {
            warehouse = warehouseMapper.selectById(order.getWarehouseId());
        }
        if (order.getDriverId() != null) {
            driver = driverMapper.selectById(order.getDriverId());
        }

        Map<String, Object> data = new HashMap<>();
        data.put("event", event);
        data.put("orderId", order.getId());
        data.put("orderNo", order.getOrderNo());
        data.put("status", order.getStatus());
        data.put("title", title);
        data.put("timestamp", LocalDateTime.now().format(FORMATTER));
        
        if (station != null) {
            data.put("stationName", station.getName());
            data.put("stationId", station.getId());
        }
        if (warehouse != null) {
            data.put("warehouseName", warehouse.getName());
            data.put("warehouseId", warehouse.getId());
        }
        if (driver != null) {
            data.put("driverName", driver.getName());
            data.put("driverId", driver.getId());
        }

        String content = buildOrderContent(order, event);
        data.put("content", content);

        return data;
    }

    private String buildOrderContent(Order order, String event) {
        String orderNo = order.getOrderNo() != null ? order.getOrderNo() : "";
        
        return switch (event) {
            case EVENT_ORDER_CREATED -> "订单" + orderNo + "已提交，等待仓库审查";
            case EVENT_ORDER_REVIEWED -> "订单" + orderNo + "已被仓库接单，正在备货中";
            case EVENT_ORDER_REJECTED -> "订单" + orderNo + "已被仓库拒绝";
            case EVENT_ORDER_DISPATCHED -> "订单" + orderNo + "已派单，正在等待司机取货";
            case EVENT_ORDER_DELIVERING -> "订单" + orderNo + "已开始配送";
            case EVENT_ORDER_COMPLETED -> "订单" + orderNo + "已完成配送";
            case EVENT_ORDER_CANCELLED -> "订单" + orderNo + "已取消";
            default -> "订单" + orderNo + "状态更新";
        };
    }

    private Long getStationOwnerUserId(Long stationId) {
        if (stationId == null) return null;
        User user = userMapper.selectOne(
            new LambdaQueryWrapper<User>()
                .eq(User::getStationId, stationId)
                .eq(User::getStatus, "active")
        );
        return user != null ? user.getId() : null;
    }

    private Long getWarehouseUserId(Long warehouseId) {
        if (warehouseId == null) return null;
        User user = userMapper.selectOne(
            new LambdaQueryWrapper<User>()
                .eq(User::getWarehouseId, warehouseId)
                .eq(User::getStatus, "active")
        );
        return user != null ? user.getId() : null;
    }

    private Long getDriverUserId(Long driverId) {
        if (driverId == null) return null;
        User user = userMapper.selectOne(
            new LambdaQueryWrapper<User>()
                .eq(User::getDriverId, driverId)
                .eq(User::getStatus, "active")
        );
        return user != null ? user.getId() : null;
    }

    public void pushToAdmin(String event, String title, String content, Map<String, Object> extraData) {
        Map<String, Object> pushData = new HashMap<>();
        pushData.put("event", event);
        pushData.put("title", title);
        pushData.put("content", content);
        pushData.put("timestamp", LocalDateTime.now().format(FORMATTER));
        if (extraData != null) {
            pushData.putAll(extraData);
        }

        sseEmitterManager.sendToRole("admin", event, pushData);
        sseEmitterManager.sendToRole("FACTORY_ADMIN", event, pushData);
        
        log.info("推送消息给管理员: event={}, title={}", event, title);
    }
}
