package com.bucketwater.oms.module.admin.service;

import com.bucketwater.oms.common.enums.OrderStatus;
import com.bucketwater.oms.module.admin.dto.AdminDashboardDTO;
import com.bucketwater.oms.module.admin.dto.FinanceOverviewDTO;
import com.bucketwater.oms.module.admin.dto.InventoryOverviewDTO;
import com.bucketwater.oms.module.admin.dto.ReportStatsDTO;
import com.bucketwater.oms.module.admin.dto.StationPageDTO;
import com.bucketwater.oms.module.admin.dto.StationPageQueryDTO;
import com.bucketwater.oms.module.notification.entity.Notification;
import com.bucketwater.oms.module.notification.mapper.NotificationMapper;
import com.bucketwater.oms.module.order.entity.Order;
import com.bucketwater.oms.module.order.entity.OrderItem;
import com.bucketwater.oms.module.order.mapper.OrderItemMapper;
import com.bucketwater.oms.module.order.mapper.OrderMapper;
import com.bucketwater.oms.module.product.entity.Product;
import com.bucketwater.oms.module.product.entity.ProductInventory;
import com.bucketwater.oms.module.product.mapper.ProductInventoryMapper;
import com.bucketwater.oms.module.product.mapper.ProductMapper;
import com.bucketwater.oms.module.station.entity.Station;
import com.bucketwater.oms.module.station.entity.StationAccount;
import com.bucketwater.oms.module.station.mapper.StationAccountMapper;
import com.bucketwater.oms.module.station.mapper.StationMapper;
import com.bucketwater.oms.module.warehouse.entity.Warehouse;
import com.bucketwater.oms.module.warehouse.mapper.WarehouseMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class AdminDashboardService {

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private OrderItemMapper orderItemMapper;

    @Autowired
    private StationMapper stationMapper;

    @Autowired
    private StationAccountMapper stationAccountMapper;

    @Autowired
    private ProductMapper productMapper;

    @Autowired
    private ProductInventoryMapper productInventoryMapper;

    @Autowired
    private WarehouseMapper warehouseMapper;

    @Autowired
    private NotificationMapper notificationMapper;

    public AdminDashboardDTO getDashboardData() {
        AdminDashboardDTO dashboard = new AdminDashboardDTO();
        
        dashboard.setTodayStats(getTodayStats());
        dashboard.setSalesTrend(getSalesTrend());
        dashboard.setNotifications(getNotifications());
        dashboard.setInventoryWarning(getInventoryWarning());
        
        return dashboard;
    }

    private AdminDashboardDTO.TodayStats getTodayStats() {
        AdminDashboardDTO.TodayStats stats = new AdminDashboardDTO.TodayStats();
        
        LocalDateTime startOfToday = LocalDate.now().atStartOfDay();
        LocalDateTime endOfToday = startOfToday.plusDays(1);
        
        LambdaQueryWrapper<Order> todayQuery = new LambdaQueryWrapper<>();
        todayQuery.ge(Order::getCreateTime, startOfToday)
                  .lt(Order::getCreateTime, endOfToday);
        List<Order> todayOrders = orderMapper.selectList(todayQuery);
        
        BigDecimal todaySales = todayOrders.stream()
            .map(Order::getTotalAmount)
            .filter(Objects::nonNull)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        stats.setTodaySales(todaySales);
        stats.setTodayOrders(todayOrders.size());
        
        LocalDateTime startOfYesterday = startOfToday.minusDays(1);
        LambdaQueryWrapper<Order> yesterdayQuery = new LambdaQueryWrapper<>();
        yesterdayQuery.ge(Order::getCreateTime, startOfYesterday)
                      .lt(Order::getCreateTime, startOfToday);
        List<Order> yesterdayOrders = orderMapper.selectList(yesterdayQuery);
        BigDecimal yesterdaySales = yesterdayOrders.stream()
            .map(Order::getTotalAmount)
            .filter(Objects::nonNull)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        if (yesterdaySales.compareTo(BigDecimal.ZERO) > 0) {
            double salesGrowth = todaySales.subtract(yesterdaySales)
                .divide(yesterdaySales, 4, RoundingMode.HALF_UP)
                .multiply(new BigDecimal("100"))
                .doubleValue();
            stats.setSalesGrowthRate(salesGrowth);
        } else {
            stats.setSalesGrowthRate(0.0);
        }
        
        if (yesterdayOrders.size() > 0) {
            double ordersGrowth = ((double) todayOrders.size() - yesterdayOrders.size()) 
                / yesterdayOrders.size() * 100;
            stats.setOrdersGrowthRate(ordersGrowth);
        } else {
            stats.setOrdersGrowthRate(0.0);
        }
        
        LambdaQueryWrapper<Station> stationQuery = new LambdaQueryWrapper<>();
        stationQuery.eq(Station::getStatus, "active");
        long activeStations = stationMapper.selectCount(stationQuery);
        stats.setActiveStations((int) activeStations);
        
        int inventoryAlerts = countInventoryAlerts();
        stats.setInventoryAlerts(inventoryAlerts);
        
        return stats;
    }

    private int countInventoryAlerts() {
        List<Product> products = productMapper.selectList(
            new LambdaQueryWrapper<Product>()
                .eq(Product::getStatus, "active")
        );
        
        int alertCount = 0;
        for (Product product : products) {
            List<ProductInventory> inventories = productInventoryMapper.selectList(
                new LambdaQueryWrapper<ProductInventory>()
                    .eq(ProductInventory::getProductId, product.getId())
            );
            
            int safeStock = getSafeStock();
            for (ProductInventory inv : inventories) {
                if (inv.getQuantity() < safeStock) {
                    alertCount++;
                }
            }
        }
        
        return alertCount;
    }

    private int getSafeStock() {
        return 50;
    }

    private List<AdminDashboardDTO.SalesTrend> getSalesTrend() {
        List<AdminDashboardDTO.SalesTrend> trends = new ArrayList<>();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MM-dd");
        
        for (int i = 6; i >= 0; i--) {
            LocalDate date = LocalDate.now().minusDays(i);
            LocalDateTime startOfDay = date.atStartOfDay();
            LocalDateTime endOfDay = date.plusDays(1).atStartOfDay();
            
            LambdaQueryWrapper<Order> query = new LambdaQueryWrapper<>();
            query.ge(Order::getCreateTime, startOfDay)
                 .lt(Order::getCreateTime, endOfDay);
            List<Order> orders = orderMapper.selectList(query);
            
            BigDecimal totalAmount = orders.stream()
                .map(Order::getTotalAmount)
                .filter(Objects::nonNull)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
            
            AdminDashboardDTO.SalesTrend trend = new AdminDashboardDTO.SalesTrend();
            trend.setDate(date.format(formatter));
            trend.setSalesAmount(totalAmount);
            trend.setOrderCount(orders.size());
            
            trends.add(trend);
        }
        
        return trends;
    }

    private List<AdminDashboardDTO.Notification> getNotifications() {
        LambdaQueryWrapper<Notification> query = new LambdaQueryWrapper<>();
        query.orderByDesc(Notification::getCreateTime)
             .last("LIMIT 10");
        
        List<Notification> notifications = notificationMapper.selectList(query);
        
        return notifications.stream().map(n -> {
            AdminDashboardDTO.Notification dto = new AdminDashboardDTO.Notification();
            dto.setId(n.getId().toString());
            dto.setType(n.getType());
            dto.setTypeText(getNotificationTypeText(n.getType()));
            dto.setContent(n.getContent());
            dto.setTime(formatTimeAgo(n.getCreateTime()));
            return dto;
        }).collect(Collectors.toList());
    }

    private String getNotificationTypeText(String type) {
        if (type == null) return "系统通知";
        return switch (type) {
            case "inventory_warning" -> "库存告警";
            case "statement_dispute" -> "对账单争议";
            case "system_maintenance" -> "系统维护";
            default -> "系统通知";
        };
    }

    private String formatTimeAgo(LocalDateTime dateTime) {
        if (dateTime == null) return "";
        
        LocalDateTime now = LocalDateTime.now();
        long minutes = java.time.Duration.between(dateTime, now).toMinutes();
        
        if (minutes < 60) {
            return minutes + "分钟前";
        } else if (minutes < 1440) {
            return (minutes / 60) + "小时前";
        } else {
            return (minutes / 1440) + "天前";
        }
    }

    private AdminDashboardDTO.InventoryWarning getInventoryWarning() {
        AdminDashboardDTO.InventoryWarning warning = new AdminDashboardDTO.InventoryWarning();
        
        List<Map<String, Object>> warnings = new ArrayList<>();
        List<Product> products = productMapper.selectList(
            new LambdaQueryWrapper<Product>()
                .eq(Product::getStatus, "active")
        );
        
        int totalWarning = 0;
        int safeStock = getSafeStock();
        for (Product product : products) {
            List<ProductInventory> inventories = productInventoryMapper.selectList(
                new LambdaQueryWrapper<ProductInventory>()
                    .eq(ProductInventory::getProductId, product.getId())
            );
            
            for (ProductInventory inv : inventories) {
                if (inv.getQuantity() < safeStock) {
                    totalWarning++;
                    Map<String, Object> w = new HashMap<>();
                    w.put("productId", product.getId().toString());
                    w.put("productName", product.getName());
                    w.put("currentStock", inv.getQuantity());
                    w.put("safeStock", safeStock);
                    w.put("warehouseId", inv.getWarehouseId() != null ? inv.getWarehouseId().toString() : null);
                    warnings.add(w);
                }
            }
        }
        
        warning.setTotalWarningProducts(totalWarning);
        warning.setWarnings(warnings);
        
        return warning;
    }
}
