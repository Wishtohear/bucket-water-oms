package com.bucketwater.oms.module.warehouse.service;

import com.bucketwater.oms.common.exception.BusinessException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.driver.entity.Driver;
import com.bucketwater.oms.module.driver.entity.DriverReturn;
import com.bucketwater.oms.module.driver.mapper.DriverMapper;
import com.bucketwater.oms.module.driver.mapper.DriverReturnMapper;
import com.bucketwater.oms.module.notification.entity.Notification;
import com.bucketwater.oms.module.notification.mapper.NotificationMapper;
import com.bucketwater.oms.module.order.dto.OrderVO;
import com.bucketwater.oms.module.order.entity.Order;
import com.bucketwater.oms.module.order.entity.OrderItem;
import com.bucketwater.oms.module.order.mapper.OrderItemMapper;
import com.bucketwater.oms.module.order.mapper.OrderMapper;
import com.bucketwater.oms.module.product.entity.Product;
import com.bucketwater.oms.module.product.entity.ProductInventory;
import com.bucketwater.oms.module.product.mapper.ProductInventoryMapper;
import com.bucketwater.oms.module.product.mapper.ProductMapper;
import com.bucketwater.oms.module.station.entity.Station;
import com.bucketwater.oms.module.station.mapper.StationMapper;
import com.bucketwater.oms.module.warehouse.dto.RecommendedDriverDTO;
import com.bucketwater.oms.module.warehouse.dto.WarehouseDashboardDTO;
import com.bucketwater.oms.module.warehouse.dto.WarehouseInventoryDTO;
import com.bucketwater.oms.module.warehouse.dto.WarehouseReturnCheckRequest;
import com.bucketwater.oms.module.warehouse.entity.Warehouse;
import com.bucketwater.oms.module.warehouse.mapper.WarehouseMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class WarehouseService {

    private static final Logger log = LoggerFactory.getLogger(WarehouseService.class);

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private OrderItemMapper orderItemMapper;

    @Autowired
    private DriverReturnMapper driverReturnMapper;

    @Autowired
    private ProductInventoryMapper productInventoryMapper;

    @Autowired
    private ProductMapper productMapper;

    @Autowired
    private NotificationMapper notificationMapper;

    @Autowired
    private StationMapper stationMapper;

    @Autowired
    private WarehouseMapper warehouseMapper;

    @Autowired
    private DriverMapper driverMapper;

    public WarehouseDashboardDTO getDashboard(Long warehouseId) {
        WarehouseDashboardDTO dashboard = new WarehouseDashboardDTO();

        Warehouse warehouse = warehouseMapper.selectById(warehouseId);
        if (warehouse != null) {
            dashboard.setWarehouseName(warehouse.getName());
            dashboard.setWarehouseId(warehouseId);
        }

        LocalDateTime startOfToday = LocalDate.now().atStartOfDay();
        LocalDateTime endOfToday = startOfToday.plusDays(1);

        LambdaQueryWrapper<Order> todayInboundQuery = new LambdaQueryWrapper<Order>()
            .eq(Order::getWarehouseId, warehouseId)
            .ge(Order::getCreateTime, startOfToday)
            .lt(Order::getCreateTime, endOfToday)
            .eq(Order::getStatus, "reviewed");
        long todayInbound = orderMapper.selectCount(todayInboundQuery);
        dashboard.setTodayInbound((int) todayInbound);

        LambdaQueryWrapper<Order> todayOutboundQuery = new LambdaQueryWrapper<Order>()
            .eq(Order::getWarehouseId, warehouseId)
            .ge(Order::getCreateTime, startOfToday)
            .lt(Order::getCreateTime, endOfToday)
            .eq(Order::getStatus, "dispatched");
        long todayOutbound = orderMapper.selectCount(todayOutboundQuery);
        dashboard.setTodayOutbound((int) todayOutbound);

        LambdaQueryWrapper<ProductInventory> inventoryQuery = new LambdaQueryWrapper<ProductInventory>()
            .eq(ProductInventory::getWarehouseId, warehouseId);
        List<ProductInventory> inventories = productInventoryMapper.selectList(inventoryQuery);
        int totalInventory = inventories.stream()
            .mapToInt(ProductInventory::getQuantity)
            .sum();
        dashboard.setTotalInventory(totalInventory);

        int lowStockWarnings = 0;
        List<WarehouseDashboardDTO.InventoryWarningDTO> warnings = new ArrayList<>();
        for (ProductInventory inv : inventories) {
            Product product = productMapper.selectById(inv.getProductId());
            if (product != null) {
                int safeStock = product.getSafeStock() != null ? product.getSafeStock() : 50;
                if (inv.getQuantity() < safeStock) {
                    lowStockWarnings++;
                    warnings.add(new WarehouseDashboardDTO.InventoryWarningDTO(
                        product.getId().toString(),
                        product.getName(),
                        inv.getQuantity(),
                        safeStock,
                        "中心仓库"
                    ));
                }
            }
        }
        dashboard.setLowStockWarnings(lowStockWarnings);
        dashboard.setInventoryWarnings(warnings);

        LambdaQueryWrapper<Order> recentQuery = new LambdaQueryWrapper<Order>()
            .eq(Order::getWarehouseId, warehouseId)
            .orderByDesc(Order::getCreateTime)
            .last("LIMIT 10");
        List<Order> recentOrders = orderMapper.selectList(recentQuery);

        List<WarehouseDashboardDTO.TaskDTO> taskDTOs = recentOrders.stream()
            .map(order -> new WarehouseDashboardDTO.TaskDTO(
                order.getId().toString(),
                order.getOrderNo(),
                "order",
                "订单",
                order.getStatus(),
                getStatusText(order.getStatus()),
                order.getContactName(),
                order.getItems() != null ? order.getItems().stream()
                    .mapToInt(OrderItem::getQuantity).sum() : 0,
                order.getCreateTime() != null ? order.getCreateTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) : ""
            ))
            .collect(Collectors.toList());
        dashboard.setRecentTasks(taskDTOs);

        LambdaQueryWrapper<Notification> notificationQuery = new LambdaQueryWrapper<Notification>()
            .orderByDesc(Notification::getCreateTime)
            .last("LIMIT 5");
        List<Notification> notifications = notificationMapper.selectList(notificationQuery);

        List<WarehouseDashboardDTO.NotificationDTO> notificationDTOs = notifications.stream()
            .map(n -> new WarehouseDashboardDTO.NotificationDTO(
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

    public List<OrderVO> getPendingOrders(Long warehouseId, String sortBy) {
        com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Order> queryWrapper =
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Order>()
                .and(wrapper -> wrapper
                    .eq(Order::getWarehouseId, warehouseId)
                    .or()
                    .isNull(Order::getWarehouseId)
                )
                .eq(Order::getStatus, "pending_review")
                .orderByAsc(Order::getCreateTime);

        List<Order> orders = orderMapper.selectList(queryWrapper);

        if ("distance".equals(sortBy)) {
            Warehouse warehouse = warehouseMapper.selectById(warehouseId);
            if (warehouse != null && warehouse.getLat() != null && warehouse.getLng() != null) {
                orders.sort((o1, o2) -> {
                    double dist1 = calculateDistance(warehouse, o1.getStationId());
                    double dist2 = calculateDistance(warehouse, o2.getStationId());
                    return Double.compare(dist1, dist2);
                });
            }
        }

        List<OrderVO> result = new ArrayList<>();
        for (Order order : orders) {
            result.add(convertToVO(order));
        }
        return result;
    }

    public List<OrderVO> getPendingOrders(Long warehouseId) {
        return getPendingOrders(warehouseId, null);
    }

    public List<DriverReturn> getPendingReturns(Long warehouseId) {
        return driverReturnMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<DriverReturn>()
                .eq(DriverReturn::getWarehouseId, warehouseId)
                .eq(DriverReturn::getStatus, "pending")
                .orderByAsc(DriverReturn::getCreatedAt)
        );
    }

    @Transactional
    public DriverReturn checkReturn(Long returnId, WarehouseReturnCheckRequest request) {
        DriverReturn driverReturn = driverReturnMapper.selectById(returnId);
        if (driverReturn == null) {
            throw new BusinessException(ResultCode.RETURN_NOT_FOUND);
        }

        int reportedQty = driverReturn.getBucketReturned() != null ? driverReturn.getBucketReturned() : 0;
        int actualQty = request.getActualBucketQty() != null ? request.getActualBucketQty() : 0;
        int difference = reportedQty - actualQty;

        driverReturn.setActualBucketQty(actualQty);
        driverReturn.setDifference(difference);
        driverReturn.setDifferenceReason(request.getDifferenceReason());
        driverReturn.setStatus("checked");
        driverReturn.setCheckedAt(LocalDateTime.now());
        driverReturnMapper.updateById(driverReturn);

        if (difference != 0) {
            Driver driver = driverMapper.selectById(driverReturn.getDriverId());
            if (driver != null) {
                int currentOwed = driver.getOwedBuckets() != null ? driver.getOwedBuckets() : 0;
                driver.setOwedBuckets(currentOwed + Math.abs(difference));
                driverMapper.updateById(driver);
            }
        }

        ProductInventory inventory = productInventoryMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<ProductInventory>()
                .eq(ProductInventory::getWarehouseId, driverReturn.getWarehouseId())
                .last("ORDER BY id LIMIT 1")
        );
        if (inventory != null) {
            inventory.setQuantity(inventory.getQuantity() + actualQty);
            productInventoryMapper.updateById(inventory);
        }

        return driverReturn;
    }

    /**
     * 获取可用司机列表（兼容旧接口）
     * 只返回绑定当前仓库的司机
     */
    public List<Driver> getAvailableDrivers(Long warehouseId) {
        List<Driver> drivers = driverMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Driver>()
                .eq(Driver::getStatus, "active")
                .eq(Driver::getWarehouseId, warehouseId)
        );
        return drivers;
    }

    /**
     * 获取所有平台可用司机（用于派单）
     * 绑定当前仓库的司机靠前显示
     */
    public List<RecommendedDriverDTO> getAllAvailableDrivers(Long warehouseId) {
        Warehouse warehouse = warehouseId != null ? warehouseMapper.selectById(warehouseId) : null;

        // 查询所有平台可用司机
        List<Driver> allDrivers = driverMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Driver>()
                .eq(Driver::getStatus, "active")
        );

        // 如果没有可用司机，返回空列表
        if (allDrivers.isEmpty()) {
            return new ArrayList<>();
        }

        // 如果仓库不存在，仍然返回所有司机
        if (warehouse == null) {
            log.warn("仓库不存在，warehouseId={}，仍返回所有可用司机", warehouseId);
        }

        // 构建司机推荐DTO
        List<RecommendedDriverDTO> result = new ArrayList<>();
        for (Driver driver : allDrivers) {
            RecommendedDriverDTO dto = buildDriverRecommendation(driver, warehouse, null, warehouseId);
            result.add(dto);
        }

        // 排序：绑定当前仓库的司机优先
        result.sort((d1, d2) -> {
            Boolean bound1 = d1.getBoundToCurrentWarehouse();
            Boolean bound2 = d2.getBoundToCurrentWarehouse();
            if (bound1 != null && bound2 != null && bound1 && !bound2) {
                return -1;
            }
            if (bound1 != null && bound2 != null && !bound1 && bound2) {
                return 1;
            }
            return 0;
        });

        return result;
    }

    public List<Driver> getDriverList(Long warehouseId) {
        List<Driver> drivers = driverMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Driver>()
                .eq(Driver::getWarehouseId, warehouseId)
                .orderByDesc(Driver::getCreateTime)
        );
        return drivers;
    }

    public List<OrderVO> getAllOrders(Long warehouseId, String status, Integer page, Integer size) {
        com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Order> queryWrapper =
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Order>()
                .and(wrapper -> wrapper
                    .eq(Order::getWarehouseId, warehouseId)
                    .or()
                    .isNull(Order::getWarehouseId)
                )
                .orderByDesc(Order::getCreateTime);

        if (status != null && !status.isEmpty()) {
            if ("preparing".equals(status)) {
                queryWrapper.eq(Order::getStatus, "reviewed");
            } else if ("dispatched".equals(status)) {
                queryWrapper.eq(Order::getStatus, "dispatched");
            } else if ("pending".equals(status)) {
                queryWrapper.eq(Order::getStatus, "pending_review");
            } else {
                queryWrapper.eq(Order::getStatus, status);
            }
        }

        queryWrapper.last("LIMIT " + size + " OFFSET " + ((page - 1) * size));

        List<Order> orders = orderMapper.selectList(queryWrapper);
        List<OrderVO> result = new ArrayList<>();
        for (Order order : orders) {
            result.add(convertToVO(order));
        }
        return result;
    }

    public List<Driver> getRecommendedDrivers(Long warehouseId, Long orderId) {
        Warehouse warehouse = warehouseMapper.selectById(warehouseId);
        Order order = orderId != null ? orderMapper.selectById(orderId) : null;

        List<Driver> allDrivers = driverMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Driver>()
                .eq(Driver::getStatus, "active")
                .eq(Driver::getWarehouseId, warehouseId)
        );

        if (warehouse == null || allDrivers.isEmpty()) {
            return allDrivers;
        }

        return allDrivers.stream()
            .map(driver -> {
                double score = calculateDriverScore(driver, warehouse, order);
                driver.setOnlineStatus(String.valueOf(score));
                return driver;
            })
            .sorted((d1, d2) -> Double.compare(
                Double.parseDouble(d2.getOnlineStatus()),
                Double.parseDouble(d1.getOnlineStatus())
            ))
            .limit(10)
            .collect(java.util.stream.Collectors.toList());
    }

    private double calculateDriverScore(Driver driver, Warehouse warehouse, Order order) {
        double score = 100.0;

        double distanceScore = calculateDistanceScore(driver, warehouse, order);
        score += distanceScore * 0.4;

        double taskScore = calculateTaskScore(driver);
        score += taskScore * 0.3;

        double onlineScore = calculateOnlineScore(driver);
        score += onlineScore * 0.2;

        return score;
    }

    private double calculateDistanceScore(Driver driver, Warehouse warehouse, Order order) {
        if (warehouse.getLat() == null || warehouse.getLng() == null ||
            driver.getCurrentLat() == null || driver.getCurrentLng() == null) {
            return 0;
        }

        double distance = haversineDistance(
            warehouse.getLat().doubleValue(),
            warehouse.getLng().doubleValue(),
            driver.getCurrentLat().doubleValue(),
            driver.getCurrentLng().doubleValue()
        );

        if (distance <= 5) return 100;
        if (distance <= 10) return 80;
        if (distance <= 20) return 60;
        if (distance <= 50) return 40;
        return 20;
    }

    private double calculateTaskScore(Driver driver) {
        int taskCount = driver.getBucketOnWay() != null ? driver.getBucketOnWay() : 0;

        if (taskCount == 0) return 100;
        if (taskCount <= 3) return 80;
        if (taskCount <= 5) return 60;
        if (taskCount <= 10) return 40;
        return 20;
    }

    private double calculateOnlineScore(Driver driver) {
        String onlineStatus = driver.getOnlineStatus();
        if ("online".equals(onlineStatus)) return 100;
        if ("break".equals(onlineStatus)) return 50;
        return 0;
    }

    public List<WarehouseInventoryDTO> getInventory(Long warehouseId) {
        List<ProductInventory> inventories = productInventoryMapper.selectList(
            new LambdaQueryWrapper<ProductInventory>()
                .eq(ProductInventory::getWarehouseId, warehouseId)
        );

        List<WarehouseInventoryDTO> result = new ArrayList<>();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

        for (ProductInventory inv : inventories) {
            WarehouseInventoryDTO dto = new WarehouseInventoryDTO();
            dto.setId(inv.getId());
            dto.setWarehouseId(inv.getWarehouseId());
            dto.setProductId(inv.getProductId());
            dto.setQuantity(inv.getQuantity());
            dto.setSafeStock(inv.getSafeStock());
            dto.setUpdatedAt(inv.getUpdatedAt() != null ? inv.getUpdatedAt().format(formatter) : null);

            if (inv.getProductId() != null) {
                Product product = productMapper.selectById(inv.getProductId());
                if (product != null) {
                    dto.setProductName(product.getName());
                    dto.setCategory(product.getCategory());
                }
            }

            result.add(dto);
        }

        return result;
    }

    @Transactional
    public void calibrateInventory(Long warehouseId, Long inventoryId, Integer newQuantity, String reason) {
        ProductInventory inventory = productInventoryMapper.selectOne(
            new LambdaQueryWrapper<ProductInventory>()
                .eq(ProductInventory::getId, inventoryId)
                .eq(ProductInventory::getWarehouseId, warehouseId)
        );

        if (inventory == null) {
            throw new BusinessException(ResultCode.DATA_NOT_FOUND, "库存记录不存在");
        }

        Integer oldQuantity = inventory.getQuantity();
        inventory.setQuantity(newQuantity);
        inventory.setUpdatedAt(LocalDateTime.now());
        productInventoryMapper.updateById(inventory);

        log.info("库存校准成功: warehouseId={}, productId={}, oldQuantity={}, newQuantity={}, reason={}",
            warehouseId, inventory.getProductId(), oldQuantity, newQuantity, reason);
    }

    @Transactional
    public void updateInventory(Long warehouseId, Long productId, Integer quantity) {
        ProductInventory inventory = productInventoryMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<ProductInventory>()
                .eq(ProductInventory::getWarehouseId, warehouseId)
                .eq(ProductInventory::getProductId, productId)
        );

        if (inventory == null) {
            inventory = new ProductInventory();
            inventory.setWarehouseId(warehouseId);
            inventory.setProductId(productId);
            inventory.setQuantity(quantity);
            inventory.setUpdatedAt(LocalDateTime.now());
            productInventoryMapper.insert(inventory);
        } else {
            inventory.setQuantity(inventory.getQuantity() + quantity);
            inventory.setUpdatedAt(LocalDateTime.now());
            productInventoryMapper.updateById(inventory);
        }
    }

    private OrderVO convertToVO(Order order) {
        List<OrderItem> items = orderItemMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<OrderItem>()
                .eq(OrderItem::getOrderId, order.getId())
        );

        List<OrderVO.OrderItemVO> itemVOs = new ArrayList<>();
        int totalBuckets = 0;
        for (OrderItem item : items) {
            String productName = getProductName(item.getProductId());
            itemVOs.add(new OrderVO.OrderItemVO(
                item.getProductId().toString(),
                productName,
                item.getQuantity(),
                item.getActualQty(),
                item.getUnitPrice(),
                item.getSubtotal()
            ));
            totalBuckets += item.getQuantity() != null ? item.getQuantity() : 0;
        }

        String stationName = null;
        BigDecimal stationLat = null;
        BigDecimal stationLng = null;
        if (order.getStationId() != null) {
            Station station = stationMapper.selectById(order.getStationId());
            if (station != null) {
                stationName = station.getName();
                stationLat = station.getLat();
                stationLng = station.getLng();
            }
        }

        String warehouseName = null;
        if (order.getWarehouseId() != null) {
            Warehouse warehouse = warehouseMapper.selectById(order.getWarehouseId());
            if (warehouse != null) {
                warehouseName = warehouse.getName();
            }
        }

        String driverName = null;
        if (order.getDriverId() != null) {
            Driver driver = driverMapper.selectById(order.getDriverId());
            if (driver != null) {
                driverName = driver.getName();
            }
        }

        String paymentTypeText = getPaymentTypeText(order.getPaymentType());

        return new OrderVO(
            order.getId().toString(),
            order.getOrderNo(),
            order.getStationId() != null ? order.getStationId().toString() : null,
            stationName,
            order.getWarehouseId() != null ? order.getWarehouseId().toString() : null,
            warehouseName,
            order.getDriverId() != null ? order.getDriverId().toString() : null,
            driverName,
            order.getStatus(),
            getStatusText(order.getStatus()),
            null,
            order.getTotalAmount(),
            totalBuckets,
            order.getDeliveredQty(),
            order.getPaymentType(),
            paymentTypeText,
            order.getCreateTime(),
            itemVOs,
            order.getDeliveryAddress(),
            order.getContactName(),
            order.getContactPhone(),
            stationLat,
            stationLng,
            order.getRejectReason(),
            null,
            "pending_review".equals(order.getStatus()),
            "pending_review".equals(order.getStatus())
        );
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

    private String getProductName(Long productId) {
        if (productId == null) return "未知商品";
        Product product = productMapper.selectById(productId);
        return product != null ? product.getName() : "未知商品";
    }

    private double calculateDistance(Warehouse warehouse, Long stationId) {
        if (stationId == null) return Double.MAX_VALUE;
        Station station = stationMapper.selectById(stationId);
        if (station == null || station.getLat() == null || station.getLng() == null) {
            return Double.MAX_VALUE;
        }
        return haversineDistance(
            warehouse.getLat().doubleValue(),
            warehouse.getLng().doubleValue(),
            station.getLat().doubleValue(),
            station.getLng().doubleValue()
        );
    }

    /**
     * 获取推荐司机列表（增强版）
     * 返回所有平台可用司机，绑定当前仓库的司机靠前显示
     */
    public List<RecommendedDriverDTO> getRecommendedDriversWithDetails(Long warehouseId, Long orderId) {
        Warehouse warehouse = warehouseId != null ? warehouseMapper.selectById(warehouseId) : null;
        Order order = orderId != null ? orderMapper.selectById(orderId) : null;

        // 查询所有平台可用司机（不只是绑定当前仓库的）
        List<Driver> allDrivers = driverMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Driver>()
                .eq(Driver::getStatus, "active")
        );

        // 如果没有可用司机，返回空列表
        if (allDrivers.isEmpty()) {
            return new ArrayList<>();
        }

        // 如果仓库不存在，仍然返回所有司机（只是没有仓库绑定信息）
        if (warehouse == null) {
            log.warn("仓库不存在，warehouseId={}，仍返回所有可用司机", warehouseId);
        } else {
            log.info("获取司机列表，warehouseId={}, 仓库名称={}, 司机数量={}", warehouseId, warehouse.getName(), allDrivers.size());
        }

        // 计算每个司机的得分和详细信息
        List<RecommendedDriverDTO> result = new ArrayList<>();
        for (Driver driver : allDrivers) {
            RecommendedDriverDTO dto = buildDriverRecommendation(driver, warehouse, order, warehouseId);
            log.debug("司机ID={}, 姓名={}, warehouseId={}, 当前仓库ID={}, 绑定状态={}",
                driver.getId(), driver.getName(), driver.getWarehouseId(), warehouseId, dto.getBoundToCurrentWarehouse());
            result.add(dto);
        }

        // 按推荐得分排序（绑定当前仓库的司机优先）
        result.sort((d1, d2) -> {
            // 绑定当前仓库的优先
            Boolean bound1 = d1.getBoundToCurrentWarehouse();
            Boolean bound2 = d2.getBoundToCurrentWarehouse();
            if (bound1 != null && bound2 != null && bound1 && !bound2) {
                return -1;
            }
            if (bound1 != null && bound2 != null && !bound1 && bound2) {
                return 1;
            }
            // 同类型按推荐得分排序
            return Double.compare(
                d2.getRecommendScore() != null ? d2.getRecommendScore() : 0,
                d1.getRecommendScore() != null ? d1.getRecommendScore() : 0
            );
        });

        // 返回所有司机
        return result;
    }

    private RecommendedDriverDTO buildDriverRecommendation(Driver driver, Warehouse warehouse, Order order, Long currentWarehouseId) {
        RecommendedDriverDTO dto = new RecommendedDriverDTO();
        dto.setDriverId(driver.getId().toString());
        dto.setCode(driver.getCode());
        dto.setName(driver.getName());
        dto.setPhone(driver.getPhone());
        dto.setCurrentLat(driver.getCurrentLat());
        dto.setCurrentLng(driver.getCurrentLng());
        dto.setOnlineStatus(driver.getOnlineStatus());
        dto.setOnlineStatusText(getOnlineStatusText(driver.getOnlineStatus()));
        dto.setCurrentTaskCount(driver.getBucketOnWay() != null ? driver.getBucketOnWay() : 0);
        dto.setTodayCompletedCount(getTodayCompletedCount(driver.getId()));
        dto.setRating(95); // 默认评分，后续可以从司机评分表获取
        dto.setTotalDeliveries(0); // 默认，后续可以从统计表获取

        // 标记是否绑定当前仓库
        boolean isBoundToCurrentWarehouse = driver.getWarehouseId() != null
            && driver.getWarehouseId().equals(currentWarehouseId);
        dto.setBoundToCurrentWarehouse(isBoundToCurrentWarehouse);

        // 如果不是绑定当前仓库的司机，获取其所属仓库名称
        if (!isBoundToCurrentWarehouse && driver.getWarehouseId() != null) {
            Warehouse driverWarehouse = warehouseMapper.selectById(driver.getWarehouseId());
            if (driverWarehouse != null) {
                dto.setWarehouseName(driverWarehouse.getName());
            }
        }

        // 计算距离
        double distance = 0;
        if (warehouse != null && warehouse.getLat() != null && warehouse.getLng() != null
            && driver.getCurrentLat() != null && driver.getCurrentLng() != null) {
            distance = haversineDistance(
                warehouse.getLat().doubleValue(),
                warehouse.getLng().doubleValue(),
                driver.getCurrentLat().doubleValue(),
                driver.getCurrentLng().doubleValue()
            );
        }
        dto.setDistanceToWarehouse(distance);

        // 计算各项得分（绑定当前仓库的司机得分更高）
        double distanceScore = calculateDistanceScore(driver, warehouse, order);
        double taskScore = calculateTaskScore(driver);
        double onlineScore = calculateOnlineScore(driver);
        double ratingScore = 95; // 默认评分得分

        // 综合得分 (距离40% + 任务数30% + 在线20% + 评分10%)
        // 如果是绑定当前仓库的司机，增加基础分
        double baseScore = isBoundToCurrentWarehouse ? 20 : 0;
        double totalScore = baseScore + distanceScore * 0.4 + taskScore * 0.3 + onlineScore * 0.2 + ratingScore * 0.1;
        dto.setRecommendScore(totalScore);

        // 确定推荐原因
        String reason = determineRecommendReason(distanceScore, taskScore, onlineScore);
        if (isBoundToCurrentWarehouse) {
            reason = "bound";
        }
        dto.setRecommendReason(reason);
        dto.setRecommendReasonText(getRecommendReasonText(reason));

        return dto;
    }

    private String determineRecommendReason(double distanceScore, double taskScore, double onlineScore) {
        // 找出得分最高的因素作为推荐原因
        if (distanceScore >= taskScore && distanceScore >= onlineScore) {
            return "distance";
        } else if (taskScore >= distanceScore && taskScore >= onlineScore) {
            return "min_tasks";
        } else {
            return "online";
        }
    }

    private String getRecommendReasonText(String reason) {
        if (reason == null) return "";
        return switch (reason) {
            case "distance" -> "距离最近";
            case "min_tasks" -> "任务最少";
            case "online" -> "在线优先";
            case "bound" -> "绑定仓库";
            default -> reason;
        };
    }

    private String getOnlineStatusText(String status) {
        if (status == null) return "离线";
        return switch (status) {
            case "online" -> "在线";
            case "offline" -> "离线";
            case "break" -> "休息中";
            default -> status;
        };
    }

    private int getTodayCompletedCount(Long driverId) {
        // 简化实现，实际应查询今日完成的订单数
        return 0;
    }

    private double haversineDistance(double lat1, double lon1, double lat2, double lon2) {
        final double R = 6371;
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                   Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                   Math.sin(dLon / 2) * Math.sin(dLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }
}
