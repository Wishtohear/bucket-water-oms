package com.bucketwater.oms.module.driver.service;

import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.driver.dto.DriverCheckInRequest;
import com.bucketwater.oms.module.driver.dto.DriverDashboardDTO;
import com.bucketwater.oms.module.driver.dto.DriverInfoDTO;
import com.bucketwater.oms.module.driver.dto.DriverLocationHistoryDTO;
import com.bucketwater.oms.module.driver.dto.BarrelRecordDTO;
import com.bucketwater.oms.module.driver.dto.DriverLocationUpdateRequest;
import com.bucketwater.oms.module.driver.dto.DriverStatusUpdateRequest;
import com.bucketwater.oms.module.driver.dto.RoutePlanningDTO;
import com.bucketwater.oms.module.driver.dto.StationSelectDTO;
import com.bucketwater.oms.module.driver.dto.WarehouseReturnRequest;
import com.bucketwater.oms.module.driver.entity.Driver;
import com.bucketwater.oms.module.driver.entity.DriverLocationHistory;
import com.bucketwater.oms.module.driver.entity.DriverReturn;
import com.bucketwater.oms.module.driver.mapper.DriverMapper;
import com.bucketwater.oms.module.driver.mapper.DriverLocationHistoryMapper;
import com.bucketwater.oms.module.driver.mapper.DriverReturnMapper;
import com.bucketwater.oms.module.driver.mapper.DriverWarehouseMapper;
import com.bucketwater.oms.module.notification.entity.Notification;
import com.bucketwater.oms.module.notification.mapper.NotificationMapper;
import com.bucketwater.oms.module.notification.service.OrderPushService;
import com.bucketwater.oms.module.order.dto.DeliveryRequest;
import com.bucketwater.oms.module.sms.service.SmsService;
import com.bucketwater.oms.module.order.dto.OrderVO;
import com.bucketwater.oms.module.order.entity.Order;
import com.bucketwater.oms.module.order.entity.OrderItem;
import com.bucketwater.oms.module.order.mapper.OrderItemMapper;
import com.bucketwater.oms.module.order.mapper.OrderMapper;
import com.bucketwater.oms.module.station.entity.Station;
import com.bucketwater.oms.module.station.entity.StationAccount;
import com.bucketwater.oms.module.station.mapper.StationAccountMapper;
import com.bucketwater.oms.module.station.mapper.StationMapper;
import com.bucketwater.oms.module.warehouse.entity.Warehouse;
import com.bucketwater.oms.module.warehouse.mapper.WarehouseMapper;
import com.bucketwater.oms.module.bucket.entity.BucketTransaction;
import com.bucketwater.oms.module.bucket.mapper.BucketTransactionMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;


@Service
public class DriverService {

    @Autowired
    private DriverMapper driverMapper;

    @Autowired
    private DriverWarehouseMapper driverWarehouseMapper;

    @Autowired
    private DriverLocationHistoryMapper locationHistoryMapper;

    @Autowired
    private DriverReturnMapper driverReturnMapper;

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private OrderItemMapper orderItemMapper;

    @Autowired
    private WarehouseMapper warehouseMapper;

    @Autowired
    private NotificationMapper notificationMapper;

    @Autowired
    private StationMapper stationMapper;

    @Autowired(required = false)
    private OrderPushService orderPushService;

    @Autowired
    private BucketTransactionMapper bucketTransactionMapper;

    @Autowired
    private StationAccountMapper stationAccountMapper;

    @Autowired(required = false)
    private SmsService smsService;

    private final ObjectMapper objectMapper = new ObjectMapper();

    public DriverInfoDTO getDriverInfo(Long driverId) {
        Driver driver = driverMapper.selectById(driverId);
        if (driver == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "司机不存在");
        }

        DriverInfoDTO info = new DriverInfoDTO();
        info.setId(driver.getId());
        info.setCode(driver.getCode());
        info.setName(driver.getName());
        info.setPhone(driver.getPhone());
        // 如果 vehicleInfo 为空，使用 licensePlate 作为备选
        String vehicleInfo = driver.getVehicleInfo();
        String licensePlate = driver.getLicensePlate();
        if (vehicleInfo != null && !vehicleInfo.isEmpty()) {
            info.setVehicle(vehicleInfo);
        } else if (licensePlate != null && !licensePlate.isEmpty()) {
            info.setVehicle(licensePlate);
        }
        info.setLicensePlate(licensePlate);
        info.setVehicleType(driver.getVehicleType());
        info.setStatus(driver.getStatus());
        info.setOnlineStatus(driver.getOnlineStatus() != null ? driver.getOnlineStatus() : "offline");
        info.setOwedBuckets(driver.getOwedBuckets() != null ? driver.getOwedBuckets() : 0);
        info.setBucketOnWay(driver.getBucketOnWay() != null ? driver.getBucketOnWay() : 0);

        // 使用 driver_warehouse 关联表查询仓库（与PC端一致）
        List<Long> warehouseIds = driverWarehouseMapper.selectWarehouseIdsByDriverId(driverId);
        if (warehouseIds != null && !warehouseIds.isEmpty()) {
            // 取第一个仓库作为主仓库
            Long primaryWarehouseId = warehouseIds.get(0);
            Warehouse warehouse = warehouseMapper.selectById(primaryWarehouseId);
            if (warehouse != null && warehouse.getName() != null) {
                info.setWarehouseName(warehouse.getName());
            } else {
                info.setWarehouseName("仓库#" + primaryWarehouseId);
            }
        } else if (driver.getWarehouseId() != null) {
            // 备用：如果关联表没有，尝试使用 driver.warehouse_id
            Warehouse warehouse = warehouseMapper.selectById(driver.getWarehouseId());
            if (warehouse != null && warehouse.getName() != null) {
                info.setWarehouseName(warehouse.getName());
            } else {
                info.setWarehouseName("仓库#" + driver.getWarehouseId());
            }
        } else {
            info.setWarehouseName("未分配仓库");
        }

        info.setArea(driver.getArea() != null ? driver.getArea() : driver.getRegion());

        LocalDateTime startOfToday = LocalDate.now().atStartOfDay();
        LocalDateTime endOfToday = startOfToday.plusDays(1);

        LambdaQueryWrapper<Order> todayQuery = new LambdaQueryWrapper<Order>()
            .eq(Order::getDriverId, driverId)
            .ge(Order::getCreateTime, startOfToday)
            .lt(Order::getCreateTime, endOfToday)
            .eq(Order::getStatus, "completed");
        long todayCount = orderMapper.selectCount(todayQuery);
        info.setTodayDeliveries((int) todayCount);

        LambdaQueryWrapper<Order> totalQuery = new LambdaQueryWrapper<Order>()
            .eq(Order::getDriverId, driverId)
            .eq(Order::getStatus, "completed");
        long totalCount = orderMapper.selectCount(totalQuery);
        info.setTotalDeliveries((int) totalCount);

        LocalDateTime startOfMonth = LocalDate.now().withDayOfMonth(1).atStartOfDay();
        LambdaQueryWrapper<Order> monthQuery = new LambdaQueryWrapper<Order>()
            .eq(Order::getDriverId, driverId)
            .eq(Order::getStatus, "completed")
            .ge(Order::getDeliveredAt, startOfMonth);
        List<Order> monthOrders = orderMapper.selectList(monthQuery);
        BigDecimal monthIncome = BigDecimal.ZERO;
        for (Order order : monthOrders) {
            if (order.getTotalAmount() != null) {
                monthIncome = monthIncome.add(order.getTotalAmount());
            }
        }
        info.setMonthIncome(monthIncome);

        int owedBuckets = driver.getOwedBuckets() != null ? driver.getOwedBuckets() : 0;
        int bucketOnWay = driver.getBucketOnWay() != null ? driver.getBucketOnWay() : 0;
        int depositBuckets = bucketOnWay;
        info.setDepositBuckets(depositBuckets);

        BigDecimal depositPrice = new BigDecimal("20.00");
        info.setDepositPrice(depositPrice);

        BigDecimal totalOwedAmount = depositPrice.multiply(BigDecimal.valueOf(owedBuckets));
        info.setTotalOwedAmount(totalOwedAmount);

        return info;
    }

    public List<BarrelRecordDTO> getBarrelRecords(Long driverId, String type) {
        LambdaQueryWrapper<BucketTransaction> query = new LambdaQueryWrapper<BucketTransaction>()
            .eq(BucketTransaction::getDriverId, driverId)
            .orderByDesc(BucketTransaction::getCreatedAt)
            .last("LIMIT 100");

        if (type != null && !type.isEmpty()) {
            if ("return".equals(type)) {
                query.eq(BucketTransaction::getType, "return");
            } else if ("pickup".equals(type)) {
                query.eq(BucketTransaction::getType, "deposit");
            } else if ("owed".equals(type)) {
                query.eq(BucketTransaction::getType, "owed");
            }
        }

        List<BucketTransaction> transactions = bucketTransactionMapper.selectList(query);
        List<BarrelRecordDTO> records = new ArrayList<>();

        int runningBalance = 0;

        for (BucketTransaction tx : transactions) {
            BarrelRecordDTO record = new BarrelRecordDTO();
            record.setId(tx.getId());
            record.setCreatedAt(tx.getCreatedAt());
            record.setType(tx.getType());
            record.setQuantity(tx.getQuantity());
            record.setBalance(tx.getBalance() != null ? tx.getBalance() : runningBalance);
            record.setRemark(tx.getRemark());

            runningBalance = record.getBalance();

            if (tx.getType() != null) {
                switch (tx.getType()) {
                    case "return":
                        record.setTypeText("回桶");
                        break;
                    case "deposit":
                        record.setTypeText("领桶");
                        break;
                    case "owed":
                        record.setTypeText("欠桶");
                        break;
                    case "pay":
                        record.setTypeText("补缴");
                        break;
                    case "compensation":
                        record.setTypeText("赔偿");
                        break;
                    default:
                        record.setTypeText(tx.getType());
                }
            }

            if (tx.getCreatedAt() != null) {
                record.setDate(tx.getCreatedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")));
            }

            if (tx.getOrderId() != null) {
                Order order = orderMapper.selectById(tx.getOrderId());
                if (order != null) {
                    record.setOrderNo(order.getOrderNo());
                    record.setOrderId(order.getId());

                    if (order.getStationId() != null) {
                        Station station = stationMapper.selectById(order.getStationId());
                        if (station != null) {
                            record.setStationName(station.getName());
                        }
                    }
                }
            }

            if (tx.getWarehouseId() != null) {
                Warehouse warehouse = warehouseMapper.selectById(tx.getWarehouseId());
                if (warehouse != null) {
                    record.setWarehouseName(warehouse.getName());
                }
            }

            records.add(record);
        }

        return records;
    }

    public DriverDashboardDTO getDashboard(Long driverId) {
        DriverDashboardDTO dashboard = new DriverDashboardDTO();

        LocalDateTime startOfToday = LocalDate.now().atStartOfDay();
        LocalDateTime endOfToday = startOfToday.plusDays(1);

        LambdaQueryWrapper<Order> todayQuery = new LambdaQueryWrapper<Order>()
            .eq(Order::getDriverId, driverId)
            .ge(Order::getCreateTime, startOfToday)
            .lt(Order::getCreateTime, endOfToday);
        List<Order> todayOrders = orderMapper.selectList(todayQuery);
        dashboard.setTodayDeliveries((int) todayOrders.stream()
            .filter(o -> "completed".equals(o.getStatus())).count());

        LambdaQueryWrapper<Order> pendingQuery = new LambdaQueryWrapper<Order>()
            .eq(Order::getDriverId, driverId)
            .in(Order::getStatus, "dispatched", "delivering");
        List<Order> pendingOrders = orderMapper.selectList(pendingQuery);
        dashboard.setPendingDeliveries(pendingOrders.size());

        LambdaQueryWrapper<Order> completedQuery = new LambdaQueryWrapper<Order>()
            .eq(Order::getDriverId, driverId)
            .eq(Order::getStatus, "completed");
        long completedCount = orderMapper.selectCount(completedQuery);
        dashboard.setCompletedDeliveries((int) completedCount);

        Driver driver = driverMapper.selectById(driverId);
        if (driver != null) {
            dashboard.setTotalBucketsOnWay(driver.getBucketOnWay() != null ? driver.getBucketOnWay() : 0);
            dashboard.setOwedBuckets(driver.getOwedBuckets() != null ? driver.getOwedBuckets() : 0);
            dashboard.setBucketThreshold(10);
            dashboard.setDriverName(driver.getName());
            if (driver.getWarehouseId() != null) {
                Warehouse warehouse = warehouseMapper.selectById(driver.getWarehouseId());
                if (warehouse != null) {
                    dashboard.setWarehouseName(warehouse.getName());
                }
            }
        } else {
            dashboard.setTotalBucketsOnWay(0);
            dashboard.setOwedBuckets(0);
            dashboard.setBucketThreshold(10);
        }

        int todayBucketCount = calculateTodayBucketCount(driverId, startOfToday, endOfToday);
        BigDecimal todayEarnings = calculateTodayEarnings(driverId, startOfToday, endOfToday);

        dashboard.setTodayEarnings(todayEarnings);

        LambdaQueryWrapper<Order> recentQuery = new LambdaQueryWrapper<Order>()
            .eq(Order::getDriverId, driverId)
            .orderByDesc(Order::getCreateTime)
            .last("LIMIT 10");
        List<Order> recentOrders = orderMapper.selectList(recentQuery);

        List<DriverDashboardDTO.TaskDTO> taskDTOs = recentOrders.stream()
            .map(order -> {
                Station station = order.getStationId() != null ? stationMapper.selectById(order.getStationId()) : null;
                List<OrderItem> items = orderItemMapper.selectList(
                    new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<OrderItem>()
                        .eq(OrderItem::getOrderId, order.getId())
                );
                int bucketCount = items.stream()
                    .mapToInt(item -> item.getActualQty() != null && item.getActualQty() > 0 ? item.getActualQty() : item.getQuantity())
                    .sum();

                DriverDashboardDTO.TaskDTO task = new DriverDashboardDTO.TaskDTO();
                task.setId(order.getId().toString());
                task.setOrderId(order.getId().toString());
                task.setOrderNo(order.getOrderNo());
                task.setStationId(station != null ? station.getId().toString() : null);
                task.setStationName(station != null ? station.getName() : "未知水站");
                task.setContactName(order.getContactName());
                task.setContactPhone(order.getContactPhone());
                task.setAddress(order.getDeliveryAddress());
                task.setLatitude(station != null && station.getLat() != null ? station.getLat().doubleValue() : null);
                task.setLongitude(station != null && station.getLng() != null ? station.getLng().doubleValue() : null);
                task.setStatus(order.getStatus());
                task.setStatusText(getStatusText(order.getStatus()));
                task.setBucketCount(bucketCount);
                task.setTotalQuantity(bucketCount);
                task.setAmount(order.getTotalAmount() != null ? order.getTotalAmount().doubleValue() : null);
                task.setCreatedAt(order.getCreateTime() != null ? order.getCreateTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) : "");

                return task;
            })
            .collect(Collectors.toList());
        dashboard.setRecentTasks(taskDTOs);

        LambdaQueryWrapper<Notification> notificationQuery = new LambdaQueryWrapper<Notification>()
            .orderByDesc(Notification::getCreateTime)
            .last("LIMIT 5");
        List<Notification> notifications = notificationMapper.selectList(notificationQuery);

        List<DriverDashboardDTO.NotificationDTO> notificationDTOs = notifications.stream()
            .map(n -> new DriverDashboardDTO.NotificationDTO(
                n.getId().toString(),
                getNotificationTitle(n.getType()),
                n.getContent(),
                n.getType(),
                n.getCreateTime() != null ? n.getCreateTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) : ""
            ))
            .collect(Collectors.toList());
        dashboard.setNotifications(notificationDTOs);

        return dashboard;
    }

    private int calculateTodayBucketCount(Long driverId, LocalDateTime startOfToday, LocalDateTime endOfToday) {
        LambdaQueryWrapper<Order> query = new LambdaQueryWrapper<Order>()
            .eq(Order::getDriverId, driverId)
            .eq(Order::getStatus, "completed")
            .ge(Order::getDeliveredAt, startOfToday)
            .lt(Order::getDeliveredAt, endOfToday);
        List<Order> completedOrders = orderMapper.selectList(query);

        int totalBuckets = 0;
        for (Order order : completedOrders) {
            List<OrderItem> items = orderItemMapper.selectList(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<OrderItem>()
                    .eq(OrderItem::getOrderId, order.getId())
            );
            for (OrderItem item : items) {
                int qty = item.getActualQty() != null && item.getActualQty() > 0 ? item.getActualQty() : item.getQuantity();
                totalBuckets += qty;
            }
        }
        return totalBuckets;
    }

    private BigDecimal calculateTodayEarnings(Long driverId, LocalDateTime startOfToday, LocalDateTime endOfToday) {
        LambdaQueryWrapper<Order> query = new LambdaQueryWrapper<Order>()
            .eq(Order::getDriverId, driverId)
            .eq(Order::getStatus, "completed")
            .ge(Order::getDeliveredAt, startOfToday)
            .lt(Order::getDeliveredAt, endOfToday);
        List<Order> completedOrders = orderMapper.selectList(query);

        BigDecimal totalEarnings = BigDecimal.ZERO;
        for (Order order : completedOrders) {
            totalEarnings = totalEarnings.add(order.getTotalAmount() != null ? order.getTotalAmount() : BigDecimal.ZERO);
        }
        return totalEarnings;
    }

    private String getNotificationTitle(String type) {
        if (type == null) return "系统通知";
        return switch (type) {
            case "inventory_warning" -> "库存预警";
            case "statement_dispute" -> "对账单争议";
            case "order_status" -> "订单状态通知";
            case "payment_reminder" -> "付款提醒";
            case "system_notice" -> "系统通知";
            default -> "系统通知";
        };
    }

    public Driver getDriverById(Long driverId) {
        return driverMapper.selectById(driverId);
    }

    public List<OrderVO> getPendingTasks(Long driverId) {
        List<Order> orders = orderMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Order>()
                .eq(Order::getDriverId, driverId)
                .in(Order::getStatus, "dispatched", "delivering")
                .orderByAsc(Order::getDispatchedAt)
        );

        List<OrderVO> result = new ArrayList<>();
        for (Order order : orders) {
            result.add(convertToVO(order));
        }
        return result;
    }

    public RoutePlanningDTO planRoute(Long driverId, List<String> orderIds) {
        List<RoutePlanningDTO.Waypoint> waypoints = new ArrayList<>();

        Warehouse warehouse = warehouseMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Warehouse>()
                .eq(Warehouse::getStatus, "active")
                .last("LIMIT 1")
        );

        if (warehouse != null) {
            waypoints.add(new RoutePlanningDTO.Waypoint(
                "warehouse",
                warehouse.getId().toString(),
                warehouse.getName(),
                warehouse.getLat(),
                warehouse.getLng(),
                "pickup",
                null
            ));
        }

        for (String orderId : orderIds) {
            Order order = orderMapper.selectById(Long.parseLong(orderId));
            if (order != null) {
                waypoints.add(new RoutePlanningDTO.Waypoint(
                    "station",
                    order.getStationId().toString(),
                    "水站",
                    new BigDecimal("25.2800"),
                    new BigDecimal("110.3100"),
                    "deliver",
                    orderId
                ));
            }
        }

        return new RoutePlanningDTO(
            new BigDecimal("45.5"),
            200,
            waypoints.size(),
            waypoints,
            "encoded_polyline_string"
        );
    }

    @Transactional
    public OrderVO startDelivery(Long orderId) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new BusinessException(ResultCode.ORDER_NOT_FOUND);
        }

        if (!"dispatched".equals(order.getStatus())) {
            throw new BusinessException(ResultCode.ORDER_STATUS_NOT_ALLOWED);
        }

        order.setStatus("delivering");
        order.setUpdateTime(LocalDateTime.now());
        orderMapper.updateById(order);

        if (orderPushService != null) {
            orderPushService.pushOrderDelivering(order.getId());
        }

        return convertToVO(order);
    }

    @Transactional
    public OrderVO completeDelivery(Long orderId, DeliveryRequest request) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new BusinessException(ResultCode.ORDER_NOT_FOUND);
        }

        if (!"delivering".equals(order.getStatus())) {
            throw new BusinessException(ResultCode.ORDER_STATUS_NOT_ALLOWED);
        }

        List<OrderItem> items = orderItemMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<OrderItem>()
                .eq(OrderItem::getOrderId, orderId)
        );

        int orderedQty = 0;
        int deliveredQty = 0;

        if (request.getItems() != null && !request.getItems().isEmpty()) {
            for (DeliveryRequest.DeliveryItemDTO deliveryItem : request.getItems()) {
                Long productId = deliveryItem.getProductId();
                for (OrderItem item : items) {
                    if (item.getProductId().equals(productId)) {
                        item.setActualQty(deliveryItem.getActualQty());
                        orderItemMapper.updateById(item);
                        orderedQty += item.getQuantity() != null ? item.getQuantity() : 0;
                        deliveredQty += deliveryItem.getActualQty() != null ? deliveryItem.getActualQty() : 0;
                        break;
                    }
                }
            }
        } else if (request.getActualQty() != null) {
            for (OrderItem item : items) {
                item.setActualQty(request.getActualQty());
                orderItemMapper.updateById(item);
                orderedQty += item.getQuantity() != null ? item.getQuantity() : 0;
                deliveredQty += request.getActualQty();
            }
        } else {
            for (OrderItem item : items) {
                orderedQty += item.getQuantity() != null ? item.getQuantity() : 0;
                deliveredQty += item.getActualQty() != null ? item.getActualQty() : item.getQuantity() != null ? item.getQuantity() : 0;
            }
        }

        order.setSignType(request.getSignType());
        order.setSignTime(LocalDateTime.now());

        if (request.getPhotos() != null && !request.getPhotos().isEmpty()) {
            order.setSignPhotos(String.join(",", request.getPhotos()));
        }

        if (request.getLocation() != null) {
            order.setCheckInLat(BigDecimal.valueOf(request.getLocation().getLat()));
            order.setCheckInLng(BigDecimal.valueOf(request.getLocation().getLng()));
            order.setCheckInAddress(request.getLocation().getAddress());
            order.setCheckInTime(LocalDateTime.now());
        }

        if ("signature".equals(request.getSignType())) {
            if (request.getSignCode() == null || request.getSignCode().isEmpty()) {
                throw new BusinessException(ResultCode.PARAM_MISSING, "签字签收需要提供签字数据");
            }
            order.setSignData(request.getSignCode());
        } else if ("sms_code".equals(request.getSignType())) {
            if (request.getSignCode() == null || request.getSignCode().isEmpty()) {
                throw new BusinessException(ResultCode.PARAM_MISSING, "短信签收需要提供验证码");
            }
            if (order.getContactPhone() != null) {
                boolean isValid = smsService.verifyCode(order.getContactPhone(), "delivery:" + order.getOrderNo(), request.getSignCode());
                if (!isValid) {
                    throw new BusinessException(ResultCode.PARAM_INVALID, "验证码错误或已过期");
                }
            }
            order.setSignData(request.getSignCode());
        } else if ("boss_confirm".equals(request.getSignType())) {
            if (request.getSignCode() == null || request.getSignCode().isEmpty()) {
                throw new BusinessException(ResultCode.PARAM_MISSING, "老板确认签收需要提供确认码");
            }
            String storedCode = order.getSignData();
            if (storedCode == null || !storedCode.equals(request.getSignCode())) {
                throw new BusinessException(ResultCode.PARAM_INVALID, "确认码错误");
            }
            order.setSignData(request.getSignCode());
        }

        if (request.getRemark() != null) {
            order.setRemark(request.getRemark());
        }

        order.setStatus("completed");
        order.setDeliveredAt(LocalDateTime.now());
        order.setUpdateTime(LocalDateTime.now());
        order.setDeliveredQty(deliveredQty);
        orderMapper.updateById(order);

        if (order.getDriverId() != null) {
            Driver driver = driverMapper.selectById(order.getDriverId());
            if (driver != null) {
                int currentBucketOnWay = driver.getBucketOnWay() != null ? driver.getBucketOnWay() : 0;
                currentBucketOnWay = Math.max(0, currentBucketOnWay - orderedQty);

                int owedBuckets = driver.getOwedBuckets() != null ? driver.getOwedBuckets() : 0;
                int newOwed = orderedQty - deliveredQty;
                if (newOwed > 0) {
                    owedBuckets += newOwed;
                }

                driver.setBucketOnWay(currentBucketOnWay);
                driver.setOwedBuckets(owedBuckets);
                driverMapper.updateById(driver);

                BucketTransaction returnTx = new BucketTransaction();
                returnTx.setOrderId(orderId);
                returnTx.setDriverId(driver.getId());
                returnTx.setStationId(order.getStationId());
                returnTx.setWarehouseId(order.getWarehouseId());
                returnTx.setType("return");
                returnTx.setQuantity(deliveredQty);
                returnTx.setBalance(currentBucketOnWay);
                returnTx.setRemark("配送完成回桶");
                returnTx.setCreatedAt(LocalDateTime.now());
                bucketTransactionMapper.insert(returnTx);

                if (newOwed > 0) {
                    BucketTransaction owedTx = new BucketTransaction();
                    owedTx.setOrderId(orderId);
                    owedTx.setDriverId(driver.getId());
                    owedTx.setStationId(order.getStationId());
                    owedTx.setWarehouseId(order.getWarehouseId());
                    owedTx.setType("owed");
                    owedTx.setQuantity(-newOwed);
                    owedTx.setBalance(owedBuckets);
                    owedTx.setRemark("欠桶: " + newOwed + "个");
                    owedTx.setCreatedAt(LocalDateTime.now());
                    bucketTransactionMapper.insert(owedTx);
                }
            }
        }

        return convertToVO(order);
    }

    @Transactional
    public DriverReturn applyWarehouseReturn(Long driverId, WarehouseReturnRequest request) {
        DriverReturn driverReturn = new DriverReturn();
        driverReturn.setDriverId(driverId);
        driverReturn.setWarehouseId(Long.parseLong(request.getWarehouseId()));
        driverReturn.setBucketReturned(request.getBucketReturn());
        driverReturn.setStatus("pending");
        driverReturn.setCreatedAt(LocalDateTime.now());

        Boolean isNewStationDelivery = request.getIsNewStationDelivery();
        driverReturn.setIsNewStationDelivery(isNewStationDelivery);

        if (Boolean.TRUE.equals(isNewStationDelivery) && request.getStationDeliveries() != null && !request.getStationDeliveries().isEmpty()) {
            try {
                List<Map<String, Object>> stationDeliveryList = new ArrayList<>();
                for (WarehouseReturnRequest.StationDeliveryItem item : request.getStationDeliveries()) {
                    Map<String, Object> deliveryItem = new HashMap<>();
                    deliveryItem.put("stationId", Long.parseLong(item.getStationId()));
                    deliveryItem.put("bucketCount", item.getBucketCount());
                    stationDeliveryList.add(deliveryItem);
                }
                String stationDeliveriesJson = objectMapper.writeValueAsString(stationDeliveryList);
                driverReturn.setStationDeliveries(stationDeliveriesJson);

                for (WarehouseReturnRequest.StationDeliveryItem item : request.getStationDeliveries()) {
                    Long stationId = Long.parseLong(item.getStationId());
                    StationAccount account = stationAccountMapper.selectOne(
                        new LambdaQueryWrapper<StationAccount>()
                            .eq(StationAccount::getStationId, stationId)
                    );
                    if (account != null) {
                        int currentOwed = account.getOwedBucketNum() != null ? account.getOwedBucketNum() : 0;
                        int newOwed = currentOwed + item.getBucketCount();
                        account.setOwedBucketNum(newOwed);
                        account.setUpdatedAt(LocalDateTime.now());
                        stationAccountMapper.updateById(account);
                    }
                }
            } catch (JsonProcessingException e) {
                throw new BusinessException(ResultCode.PARAM_ERROR, "水站派送明细序列化失败");
            }
        }

        driverReturnMapper.insert(driverReturn);

        return driverReturn;
    }

    private OrderVO convertToVO(Order order) {
        List<OrderItem> items = orderItemMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<OrderItem>()
                .eq(OrderItem::getOrderId, order.getId())
        );

        List<OrderVO.OrderItemVO> itemVOs = new ArrayList<>();
        int totalQty = 0;
        for (OrderItem item : items) {
            itemVOs.add(new OrderVO.OrderItemVO(
                item.getProductId().toString(),
                "商品",
                item.getQuantity(),
                item.getActualQty(),
                item.getUnitPrice(),
                item.getSubtotal()
            ));
            totalQty += item.getQuantity() != null ? item.getQuantity() : 0;
        }

        Driver driver = order.getDriverId() != null ? driverMapper.selectById(order.getDriverId()) : null;
        OrderVO.DriverInfo driverInfo = null;
        if (driver != null) {
            driverInfo = new OrderVO.DriverInfo(
                driver.getId().toString(),
                driver.getName(),
                driver.getPhone()
            );
        }

        Warehouse warehouse = order.getWarehouseId() != null ? warehouseMapper.selectById(order.getWarehouseId()) : null;
        OrderVO.WarehouseInfo warehouseInfo = null;
        if (warehouse != null) {
            warehouseInfo = new OrderVO.WarehouseInfo(
                warehouse.getId().toString(),
                warehouse.getName()
            );
        }

        Station station = order.getStationId() != null ? stationMapper.selectById(order.getStationId()) : null;
        String stationName = station != null ? station.getName() : null;
        BigDecimal lat = station != null ? station.getLat() : null;
        BigDecimal lng = station != null ? station.getLng() : null;

        OrderVO vo = new OrderVO();
        vo.setOrderId(order.getId().toString());
        vo.setOrderNo(order.getOrderNo());
        vo.setStationId(order.getStationId() != null ? order.getStationId().toString() : null);
        vo.setStationName(stationName);
        vo.setWarehouseId(order.getWarehouseId() != null ? order.getWarehouseId().toString() : null);
        vo.setWarehouseName(warehouse != null ? warehouse.getName() : null);
        vo.setDriverId(order.getDriverId() != null ? order.getDriverId().toString() : null);
        vo.setDriverName(driver != null ? driver.getName() : null);
        vo.setStatus(order.getStatus());
        vo.setStatusText(getStatusText(order.getStatus()));
        vo.setTotalAmount(order.getTotalAmount());
        vo.setTotalBuckets(totalQty);
        vo.setActualBuckets(order.getDeliveredQty());
        vo.setPaymentType(order.getPaymentType());
        vo.setPaymentTypeText(getPaymentTypeText(order.getPaymentType()));
        vo.setCreateTime(order.getCreateTime());
        vo.setItems(itemVOs);
        vo.setDeliveryAddress(order.getDeliveryAddress());
        vo.setContactName(order.getContactName());
        vo.setContactPhone(order.getContactPhone());
        vo.setStationLat(lat);
        vo.setStationLng(lng);
        vo.setLatitude(lat);
        vo.setLongitude(lng);
        vo.setRejectReason(order.getRejectReason());
        vo.setCanModify("pending_review".equals(order.getStatus()));
        vo.setCanCancel("pending_review".equals(order.getStatus()));

        if (driver != null) {
            int owedBuckets = driver.getOwedBuckets() != null ? driver.getOwedBuckets() : 0;
            int bucketOnWay = driver.getBucketOnWay() != null ? driver.getBucketOnWay() : 0;
            OrderVO.BucketReturn bucketReturn = new OrderVO.BucketReturn(0, 0, owedBuckets);
            vo.setBucketReturn(bucketReturn);
        }

        return vo;
    }

    private String getPaymentTypeText(String paymentType) {
        if (paymentType == null) return "未知";
        switch (paymentType) {
            case "prepaid": return "预存金";
            case "credit": return "信用额度";
            case "monthly": return "月结";
            default: return paymentType;
        }
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

    @Transactional
    public Map<String, Object> updateLocation(Long driverId, DriverLocationUpdateRequest request) {
        Driver driver = driverMapper.selectById(driverId);
        if (driver == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "司机不存在");
        }

        LocalDateTime now = LocalDateTime.now();

        driver.setCurrentLat(request.getLat());
        driver.setCurrentLng(request.getLng());
        driver.setLastLocationTime(now);

        if ("offline".equals(driver.getOnlineStatus()) || driver.getOnlineStatus() == null) {
            driver.setOnlineStatus("online");
        }
        driver.setLastOnlineTime(now);

        if (request.getOnlineStatus() != null && !"offline".equals(request.getOnlineStatus())) {
            driver.setOnlineStatus(request.getOnlineStatus());
        } else if ("offline".equals(request.getOnlineStatus())) {
            driver.setOnlineStatus("offline");
        }

        driverMapper.updateById(driver);

        DriverLocationHistory history = new DriverLocationHistory();
        history.setDriverId(driverId);
        history.setLat(request.getLat());
        history.setLng(request.getLng());
        history.setSpeed(request.getSpeed());
        history.setHeading(request.getHeading());
        history.setAddress(request.getAddress());
        history.setRecordTime(now);
        history.setLocationType("normal");
        history.setCreateTime(now);
        locationHistoryMapper.insert(history);

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "位置更新成功");
        result.put("onlineStatus", driver.getOnlineStatus());
        result.put("lat", request.getLat());
        result.put("lng", request.getLng());
        result.put("timestamp", now.format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
        result.put("nextHeartbeat", calculateNextHeartbeat(now));

        return result;
    }

    private String calculateNextHeartbeat(LocalDateTime currentTime) {
        return currentTime.plusMinutes(5).format(DateTimeFormatter.ISO_LOCAL_DATE_TIME);
    }

    @Transactional
    public Map<String, Object> updateOnlineStatus(Long driverId, DriverStatusUpdateRequest request) {
        Driver driver = driverMapper.selectById(driverId);
        if (driver == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "司机不存在");
        }

        String validStatus = switch (request.getOnlineStatus()) {
            case "online", "offline", "break" -> request.getOnlineStatus();
            default -> throw new BusinessException(ResultCode.PARAM_INVALID, "无效的在线状态");
        };

        LocalDateTime now = LocalDateTime.now();
        String previousStatus = driver.getOnlineStatus();

        driver.setOnlineStatus(validStatus);
        driver.setLastOnlineTime(now);

        driverMapper.updateById(driver);

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);

        if (previousStatus != null && previousStatus.equals(validStatus)) {
            result.put("message", "状态已是" + getDriverStatusText(validStatus));
        } else {
            result.put("message", "状态更新成功");
        }

        result.put("onlineStatus", validStatus);
        result.put("previousStatus", previousStatus);
        result.put("lastOnlineTime", now.format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));

        return result;
    }

    @Transactional
    public Map<String, Object> goOnline(Long driverId) {
        Driver driver = driverMapper.selectById(driverId);
        if (driver == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "司机不存在");
        }

        LocalDateTime now = LocalDateTime.now();
        String previousStatus = driver.getOnlineStatus() != null ? driver.getOnlineStatus() : "offline";

        driver.setOnlineStatus("online");
        driver.setLastOnlineTime(now);
        driverMapper.updateById(driver);

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "上线成功，现在可以接收新配送任务");
        result.put("onlineStatus", "online");
        result.put("previousStatus", previousStatus);
        result.put("lastOnlineTime", now.format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
        result.put("nextHeartbeat", calculateNextHeartbeat(now));

        return result;
    }

    @Transactional
    public Map<String, Object> goOffline(Long driverId) {
        Driver driver = driverMapper.selectById(driverId);
        if (driver == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "司机不存在");
        }

        LocalDateTime now = LocalDateTime.now();
        String previousStatus = driver.getOnlineStatus() != null ? driver.getOnlineStatus() : "offline";

        driver.setOnlineStatus("offline");
        driver.setLastOnlineTime(now);
        driverMapper.updateById(driver);

        LambdaQueryWrapper<Order> activeQuery = new LambdaQueryWrapper<Order>()
            .eq(Order::getDriverId, driverId)
            .in(Order::getStatus, "dispatched", "delivering");
        long activeTaskCount = orderMapper.selectCount(activeQuery);

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "下线成功，当前配送任务不受影响");
        result.put("onlineStatus", "offline");
        result.put("previousStatus", previousStatus);
        result.put("lastOnlineTime", now.format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
        result.put("activeTaskCount", activeTaskCount);

        return result;
    }

    @Transactional
    public Map<String, Object> goOnBreak(Long driverId) {
        Driver driver = driverMapper.selectById(driverId);
        if (driver == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "司机不存在");
        }

        LocalDateTime now = LocalDateTime.now();
        String previousStatus = driver.getOnlineStatus() != null ? driver.getOnlineStatus() : "offline";

        driver.setOnlineStatus("break");
        driver.setLastOnlineTime(now);
        driverMapper.updateById(driver);

        LambdaQueryWrapper<Order> activeQuery = new LambdaQueryWrapper<Order>()
            .eq(Order::getDriverId, driverId)
            .in(Order::getStatus, "dispatched", "delivering");
        long activeTaskCount = orderMapper.selectCount(activeQuery);

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "休息模式已开启，当前配送任务不受影响");
        result.put("onlineStatus", "break");
        result.put("previousStatus", previousStatus);
        result.put("lastOnlineTime", now.format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
        result.put("activeTaskCount", activeTaskCount);

        return result;
    }

    private String getDriverStatusText(String status) {
        if (status == null) return "未知";
        return switch (status) {
            case "online" -> "在线";
            case "offline" -> "离线";
            case "break" -> "休息中";
            default -> status;
        };
    }

    public List<StationSelectDTO> getStationsForDelivery(Long driverId) {
        List<Station> stations = stationMapper.selectList(
            new LambdaQueryWrapper<Station>()
                .eq(Station::getStatus, "active")
                .orderByAsc(Station::getName)
        );

        List<StationSelectDTO> result = new ArrayList<>();
        for (Station station : stations) {
            StationSelectDTO dto = new StationSelectDTO();
            dto.setStationId(station.getId());
            dto.setName(station.getName());
            dto.setAddress(station.getAddress());
            dto.setPhone(station.getPhone());

            StationAccount account = stationAccountMapper.selectOne(
                new LambdaQueryWrapper<StationAccount>()
                    .eq(StationAccount::getStationId, station.getId())
            );
            if (account != null) {
                dto.setOwedBucketNum(account.getOwedBucketNum() != null ? account.getOwedBucketNum() : 0);
                dto.setOwedThreshold(account.getOwedThreshold() != null ? account.getOwedThreshold() : 10);
                dto.setBucketDepositPerUnit(account.getBucketDepositPerUnit());
                Boolean isOver = dto.getOwedBucketNum() >= dto.getOwedThreshold();
                dto.setIsOverThreshold(isOver);
            } else {
                dto.setOwedBucketNum(0);
                dto.setOwedThreshold(10);
                dto.setIsOverThreshold(false);
            }

            result.add(dto);
        }

        return result;
    }

    @Transactional
    public Map<String, Object> checkIn(Long driverId, DriverCheckInRequest request) {
        Driver driver = driverMapper.selectById(driverId);
        if (driver == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "司机不存在");
        }

        Order order = orderMapper.selectById(request.getOrderId());
        if (order == null) {
            throw new BusinessException(ResultCode.ORDER_NOT_FOUND);
        }

        if (!driverId.equals(order.getDriverId())) {
            throw new BusinessException(ResultCode.ORDER_STATUS_NOT_ALLOWED, "该订单不属于当前司机");
        }

        if (!"delivering".equals(order.getStatus())) {
            throw new BusinessException(ResultCode.ORDER_STATUS_NOT_ALLOWED, "订单状态不允许打卡");
        }

        LocalDateTime now = LocalDateTime.now();
        if (request.getTimestamp() != null) {
            now = LocalDateTime.ofInstant(
                Instant.ofEpochMilli(request.getTimestamp()),
                ZoneId.systemDefault()
            );
        }

        driver.setCurrentLat(request.getLat());
        driver.setCurrentLng(request.getLng());
        driver.setLastLocationTime(now);
        driverMapper.updateById(driver);

        double distance = 0;
        boolean withinTolerance = false;
        String stationName = "";
        final double DISTANCE_TOLERANCE = 50.0;

        Station station = order.getStationId() != null ? stationMapper.selectById(order.getStationId()) : null;
        if (station != null && station.getLat() != null && station.getLng() != null) {
            distance = calculateDistance(
                request.getLat().doubleValue(),
                request.getLng().doubleValue(),
                station.getLat().doubleValue(),
                station.getLng().doubleValue()
            );
            withinTolerance = distance <= DISTANCE_TOLERANCE;
            stationName = station.getName() != null ? station.getName() : "";
        }

        order.setCheckInLat(request.getLat());
        order.setCheckInLng(request.getLng());
        order.setCheckInTime(now);
        order.setCheckInAddress(request.getAddress() != null ? request.getAddress() : "");
        order.setUpdateTime(now);
        orderMapper.updateById(order);

        Map<String, Object> checkInInfo = new HashMap<>();
        checkInInfo.put("orderId", request.getOrderId());
        checkInInfo.put("orderNo", order.getOrderNo());
        checkInInfo.put("checkInTime", now.format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
        checkInInfo.put("lat", request.getLat());
        checkInInfo.put("lng", request.getLng());
        checkInInfo.put("address", request.getAddress() != null ? request.getAddress() : "");
        checkInInfo.put("accuracy", request.getAccuracy());
        checkInInfo.put("distanceToStation", Math.round(distance * 100) / 100.0);
        checkInInfo.put("stationName", stationName);
        checkInInfo.put("withinTolerance", withinTolerance);
        checkInInfo.put("toleranceDistance", DISTANCE_TOLERANCE);

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", withinTolerance ? "打卡成功（位置在容差范围内）" : "打卡成功（位置超出容差范围）");
        result.put("checkInInfo", checkInInfo);

        return result;
    }

    private double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
        final int R = 6371;
        double latDistance = Math.toRadians(lat2 - lat1);
        double lngDistance = Math.toRadians(lng2 - lng1);
        double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(lngDistance / 2) * Math.sin(lngDistance / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }

    public Map<String, Object> getDriverStatus(Long driverId) {
        Driver driver = driverMapper.selectById(driverId);
        if (driver == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "司机不存在");
        }

        Map<String, Object> status = new HashMap<>();
        status.put("driverId", driver.getId());
        status.put("name", driver.getName());
        status.put("phone", driver.getPhone());
        status.put("onlineStatus", driver.getOnlineStatus() != null ? driver.getOnlineStatus() : "offline");
        status.put("lastOnlineTime", driver.getLastOnlineTime() != null
            ? driver.getLastOnlineTime().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME) : null);
        status.put("currentLat", driver.getCurrentLat());
        status.put("currentLng", driver.getCurrentLng());
        status.put("lastLocationTime", driver.getLastLocationTime() != null
            ? driver.getLastLocationTime().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME) : null);
        status.put("status", driver.getStatus());

        LambdaQueryWrapper<Order> activeQuery = new LambdaQueryWrapper<Order>()
            .eq(Order::getDriverId, driverId)
            .in(Order::getStatus, "dispatched", "delivering");
        status.put("activeTaskCount", orderMapper.selectCount(activeQuery));

        return status;
    }

    public Map<String, Object> getLocationHistory(Long driverId, LocalDateTime startTime, LocalDateTime endTime, String orderId) {
        Driver driver = driverMapper.selectById(driverId);
        if (driver == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "司机不存在");
        }

        List<DriverLocationHistory> historyList;
        if (orderId != null && !orderId.isEmpty()) {
            historyList = locationHistoryMapper.findByOrderId(orderId);
        } else {
            if (startTime == null) {
                startTime = LocalDateTime.now().minusDays(1);
            }
            if (endTime == null) {
                endTime = LocalDateTime.now();
            }
            historyList = locationHistoryMapper.findByDriverIdAndTimeRange(driverId, startTime, endTime);
        }

        List<DriverLocationHistoryDTO> points = historyList.stream()
            .map(DriverLocationHistoryDTO::fromEntity)
            .collect(Collectors.toList());

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("driverId", driverId);
        result.put("driverName", driver.getName());
        result.put("startTime", startTime != null ? startTime.format(DateTimeFormatter.ISO_LOCAL_DATE_TIME) : null);
        result.put("endTime", endTime != null ? endTime.format(DateTimeFormatter.ISO_LOCAL_DATE_TIME) : null);
        result.put("orderId", orderId);
        result.put("totalPoints", points.size());
        result.put("points", points);

        if (points.size() > 1) {
            double totalDistance = 0;
            for (int i = 1; i < points.size(); i++) {
                double lat1 = points.get(i - 1).getLat().doubleValue();
                double lng1 = points.get(i - 1).getLng().doubleValue();
                double lat2 = points.get(i).getLat().doubleValue();
                double lng2 = points.get(i).getLng().doubleValue();
                totalDistance += calculateDistance(lat1, lng1, lat2, lng2);
            }
            result.put("totalDistance", Math.round(totalDistance * 100) / 100.0);
        }

        return result;
    }
}
