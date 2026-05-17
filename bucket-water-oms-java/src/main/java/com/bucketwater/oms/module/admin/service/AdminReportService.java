package com.bucketwater.oms.module.admin.service;

import com.bucketwater.oms.common.enums.OrderStatus;
import com.bucketwater.oms.module.admin.dto.DashboardStatsDTO;
import com.bucketwater.oms.module.admin.dto.ReportStatsDTO;
import com.bucketwater.oms.module.order.entity.Order;
import com.bucketwater.oms.module.order.entity.OrderItem;
import com.bucketwater.oms.module.order.mapper.OrderItemMapper;
import com.bucketwater.oms.module.order.mapper.OrderMapper;
import com.bucketwater.oms.module.product.entity.Product;
import com.bucketwater.oms.module.product.mapper.ProductMapper;
import com.bucketwater.oms.module.station.entity.Station;
import com.bucketwater.oms.module.station.mapper.StationMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.ss.util.CellRangeAddress;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class AdminReportService {

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private OrderItemMapper orderItemMapper;

    @Autowired
    private StationMapper stationMapper;

    @Autowired
    private ProductMapper productMapper;

    /**
     * 获取Dashboard统计数据
     * 用于管理后台首页概览
     */
    public DashboardStatsDTO getDashboardStats() {
        DashboardStatsDTO stats = new DashboardStatsDTO();

        LocalDateTime todayStart = LocalDate.now().atStartOfDay();
        LocalDateTime todayEnd = LocalDate.now().plusDays(1).atStartOfDay();

        LambdaQueryWrapper<Order> todayQuery = new LambdaQueryWrapper<>();
        todayQuery.ge(Order::getCreateTime, todayStart)
                 .lt(Order::getCreateTime, todayEnd);
        List<Order> todayOrders = orderMapper.selectList(todayQuery);

        BigDecimal todaySales = todayOrders.stream()
            .map(Order::getTotalAmount)
            .filter(Objects::nonNull)
            .reduce(BigDecimal.ZERO, BigDecimal::add);

        stats.setTodaySales(todaySales);
        stats.setTodayOrders(todayOrders.size());

        Long activeStations = stationMapper.selectCount(
            new LambdaQueryWrapper<Station>()
                .eq(Station::getStatus, "active")
        );
        stats.setActiveStations(activeStations != null ? activeStations.intValue() : 0);

        stats.setStockWarnings(0);
        stats.setLowStockItems(0);
        stats.setAlerts(0);

        LocalDateTime yesterdayStart = LocalDate.now().minusDays(1).atStartOfDay();
        LocalDateTime yesterdayEnd = LocalDate.now().atStartOfDay();

        LambdaQueryWrapper<Order> yesterdayQuery = new LambdaQueryWrapper<>();
        yesterdayQuery.ge(Order::getCreateTime, yesterdayStart)
                     .lt(Order::getCreateTime, yesterdayEnd);
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
            stats.setSalesGrowth(salesGrowth);
        } else {
            stats.setSalesGrowth(0.0);
        }

        int yesterdayOrderCount = yesterdayOrders.size();
        if (yesterdayOrderCount > 0) {
            double ordersGrowth = ((double) stats.getTodayOrders() - yesterdayOrderCount) / yesterdayOrderCount * 100;
            stats.setOrdersGrowth(ordersGrowth);
        } else {
            stats.setOrdersGrowth(0.0);
        }

        return stats;
    }

    public ReportStatsDTO getReportStats(String reportType, String startMonth, String endMonth) {
        ReportStatsDTO stats = new ReportStatsDTO();
        
        stats.setSalesTrend(getSalesTrend(startMonth, endMonth));
        stats.setProductDistribution(getProductDistribution());
        stats.setStationRankings(getStationRankings());
        stats.setDailyReports(getDailyReports());
        
        return stats;
    }

    private ReportStatsDTO.SalesTrendReport getSalesTrend(String startMonth, String endMonth) {
        ReportStatsDTO.SalesTrendReport report = new ReportStatsDTO.SalesTrendReport();
        
        if (startMonth == null) startMonth = "2026-01";
        if (endMonth == null) endMonth = "2026-04";
        
        report.setStartMonth(startMonth);
        report.setEndMonth(endMonth);
        
        List<ReportStatsDTO.MonthlyData> data = new ArrayList<>();
        
        YearMonth start = YearMonth.parse(startMonth);
        YearMonth end = YearMonth.parse(endMonth);
        
        while (!start.isAfter(end)) {
            ReportStatsDTO.MonthlyData monthly = new ReportStatsDTO.MonthlyData();
            monthly.setMonth(start.format(DateTimeFormatter.ofPattern("yyyy-MM")));
            
            LocalDateTime monthStart = start.atDay(1).atStartOfDay();
            LocalDateTime monthEnd = start.plusMonths(1).atDay(1).atStartOfDay();
            
            LambdaQueryWrapper<Order> query = new LambdaQueryWrapper<>();
            query.ge(Order::getCreateTime, monthStart)
                 .lt(Order::getCreateTime, monthEnd);
            List<Order> orders = orderMapper.selectList(query);
            
            BigDecimal totalAmount = orders.stream()
                .map(Order::getTotalAmount)
                .filter(Objects::nonNull)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
            
            monthly.setSalesAmount(totalAmount);
            monthly.setOrderCount(orders.size());
            
            data.add(monthly);
            start = start.plusMonths(1);
        }
        
        report.setData(data);
        return report;
    }

    private ReportStatsDTO.ProductDistributionReport getProductDistribution() {
        ReportStatsDTO.ProductDistributionReport report = new ReportStatsDTO.ProductDistributionReport();
        
        List<ReportStatsDTO.CategoryDistribution> categories = new ArrayList<>();
        Map<String, Integer> categoryQuantities = new HashMap<>();
        Map<String, String> categoryNames = new HashMap<>();
        
        categoryNames.put("bucket_water", "18L 桶装水");
        categoryNames.put("bottled_water", "瓶装水");
        categoryNames.put("一次性桶装水", "一次性桶");
        
        List<Order> completedOrders = orderMapper.selectList(
            new LambdaQueryWrapper<Order>()
                .eq(Order::getStatus, OrderStatus.COMPLETED.name())
                .ge(Order::getDeliveredAt, LocalDateTime.now().minusMonths(1))
        );
        
        int totalQuantity = 0;
        
        for (Order order : completedOrders) {
            List<OrderItem> items = orderItemMapper.selectList(
                new LambdaQueryWrapper<OrderItem>()
                    .eq(OrderItem::getOrderId, order.getId())
            );
            
            for (OrderItem item : items) {
                Product product = productMapper.selectById(item.getProductId());
                if (product != null) {
                    String category = product.getCategory();
                    categoryQuantities.merge(category, item.getActualQty(), Integer::sum);
                    totalQuantity += item.getActualQty();
                }
            }
        }
        

        
        for (Map.Entry<String, Integer> entry : categoryQuantities.entrySet()) {
            ReportStatsDTO.CategoryDistribution cat = new ReportStatsDTO.CategoryDistribution();
            cat.setCategory(entry.getKey());
            cat.setCategoryText(categoryNames.getOrDefault(entry.getKey(), entry.getKey()));
            cat.setQuantity(entry.getValue());
            cat.setPercentage(
                new BigDecimal(entry.getValue())
                    .divide(new BigDecimal(totalQuantity), 4, RoundingMode.HALF_UP)
                    .multiply(new BigDecimal("100"))
                    .doubleValue()
            );
            categories.add(cat);
        }
        
        categories.sort((a, b) -> Double.compare(b.getPercentage(), a.getPercentage()));
        
        report.setTotalQuantity(totalQuantity);
        report.setCategories(categories);
        
        return report;
    }

    private List<ReportStatsDTO.StationRanking> getStationRankings() {
        List<ReportStatsDTO.StationRanking> rankings = new ArrayList<>();
        
        List<Station> stations = stationMapper.selectList(
            new LambdaQueryWrapper<Station>()
                .eq(Station::getStatus, "active")
        );
        
        Map<Long, BigDecimal> stationAmounts = new HashMap<>();
        BigDecimal totalAmount = BigDecimal.ZERO;
        
        for (Station station : stations) {
            LambdaQueryWrapper<Order> query = new LambdaQueryWrapper<>();
            query.eq(Order::getStationId, station.getId())
                 .eq(Order::getStatus, OrderStatus.COMPLETED.name())
                 .ge(Order::getDeliveredAt, LocalDateTime.now().minusMonths(1));
            
            List<Order> orders = orderMapper.selectList(query);
            
            BigDecimal stationTotal = orders.stream()
                .map(Order::getTotalAmount)
                .filter(Objects::nonNull)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
            
            if (stationTotal.compareTo(BigDecimal.ZERO) > 0) {
                stationAmounts.put(station.getId(), stationTotal);
                totalAmount = totalAmount.add(stationTotal);
            }
        }
        

        
        List<Map.Entry<Long, BigDecimal>> sortedEntries = stationAmounts.entrySet()
            .stream()
            .sorted(Map.Entry.<Long, BigDecimal>comparingByValue().reversed())
            .limit(5)
            .collect(Collectors.toList());
        
        int rank = 1;
        for (Map.Entry<Long, BigDecimal> entry : sortedEntries) {
            Station station = stationMapper.selectById(entry.getKey());
            
            ReportStatsDTO.StationRanking r = new ReportStatsDTO.StationRanking();
            r.setRank(rank);
            r.setStationId(entry.getKey().toString());
            r.setStationName(station != null ? station.getName() : "");
            r.setTotalAmount(entry.getValue());
            
            if (totalAmount.compareTo(BigDecimal.ZERO) > 0) {
                r.setPercentage(
                    entry.getValue()
                        .divide(totalAmount, 4, RoundingMode.HALF_UP)
                        .multiply(new BigDecimal("100"))
                        .doubleValue()
                );
            }
            
            rankings.add(r);
            rank++;
        }
        
        return rankings;
    }

    private List<ReportStatsDTO.DailySalesReport> getDailyReports() {
        List<ReportStatsDTO.DailySalesReport> reports = new ArrayList<>();
        
        for (int i = 3; i >= 0; i--) {
            LocalDate date = LocalDate.now().minusDays(i);
            
            LocalDateTime startOfDay = date.atStartOfDay();
            LocalDateTime endOfDay = date.plusDays(1).atStartOfDay();
            
            LambdaQueryWrapper<Order> query = new LambdaQueryWrapper<>();
            query.ge(Order::getCreateTime, startOfDay)
                 .lt(Order::getCreateTime, endOfDay);
            List<Order> orders = orderMapper.selectList(query);
            
            int totalBuckets = 0;
            BigDecimal totalAmount = BigDecimal.ZERO;
            
            for (Order order : orders) {
                totalAmount = totalAmount.add(order.getTotalAmount());
                
                if (OrderStatus.COMPLETED.name().equals(order.getStatus())) {
                    List<OrderItem> items = orderItemMapper.selectList(
                        new LambdaQueryWrapper<OrderItem>()
                            .eq(OrderItem::getOrderId, order.getId())
                    );
                    
                    for (OrderItem item : items) {
                        totalBuckets += item.getActualQty();
                    }
                }
            }
            
            ReportStatsDTO.DailySalesReport report = new ReportStatsDTO.DailySalesReport();
            report.setDate(date.toString());
            report.setDateText(date.format(DateTimeFormatter.ofPattern("yyyy-MM-dd")) + (i == 0 ? " (今日)" : ""));
            report.setOrderQuantity(totalBuckets);
            report.setBucketReturned((int) (report.getOrderQuantity() * 0.95));
            report.setSalesAmount(totalAmount);
            report.setNewStations(0);
            
            reports.add(report);
        }

        return reports;
    }

    public List<Map<String, Object>> getSalesTrend(String startDate, String endDate, String type) {
        List<Map<String, Object>> trend = new ArrayList<>();

        LocalDate start = startDate != null ? LocalDate.parse(startDate) : LocalDate.now().minusDays(30);
        LocalDate end = endDate != null ? LocalDate.parse(endDate) : LocalDate.now();

        if ("week".equals(type)) {
            // 按周统计
            LocalDate weekStart = start;
            while (!weekStart.isAfter(end)) {
                LocalDate weekEnd = weekStart.plusDays(6);
                if (weekEnd.isAfter(end)) weekEnd = end;

                BigDecimal amount = calculateAmountForPeriod(weekStart, weekEnd.plusDays(1));
                int orders = countOrdersForPeriod(weekStart, weekEnd.plusDays(1));

                Map<String, Object> item = new HashMap<>();
                item.put("date", weekStart.toString());
                item.put("amount", amount);
                item.put("orders", orders);
                trend.add(item);

                weekStart = weekEnd.plusDays(1);
            }
        } else if ("month".equals(type)) {
            // 按月统计
            YearMonth monthStart = YearMonth.from(start);
            YearMonth monthEnd = YearMonth.from(end);

            while (!monthStart.isAfter(monthEnd)) {
                LocalDate monthStartDate = monthStart.atDay(1);
                LocalDate monthEndDate = monthStart.atEndOfMonth();
                if (monthEndDate.isAfter(end)) monthEndDate = end;

                BigDecimal amount = calculateAmountForPeriod(monthStartDate, monthEndDate.plusDays(1));
                int orders = countOrdersForPeriod(monthStartDate, monthEndDate.plusDays(1));

                Map<String, Object> item = new HashMap<>();
                item.put("date", monthStart.toString());
                item.put("amount", amount);
                item.put("orders", orders);
                trend.add(item);

                monthStart = monthStart.plusMonths(1);
            }
        } else {
            // 按日统计
            LocalDate date = start;
            while (!date.isAfter(end)) {
                BigDecimal amount = calculateAmountForPeriod(date, date.plusDays(1));
                int orders = countOrdersForPeriod(date, date.plusDays(1));

                Map<String, Object> item = new HashMap<>();
                item.put("date", date.toString());
                item.put("amount", amount);
                item.put("orders", orders);
                trend.add(item);

                date = date.plusDays(1);
            }
        }

        return trend;
    }

    private BigDecimal calculateAmountForPeriod(LocalDate start, LocalDate end) {
        LambdaQueryWrapper<Order> query = new LambdaQueryWrapper<>();
        query.ge(Order::getCreateTime, start.atStartOfDay())
             .lt(Order::getCreateTime, end.atStartOfDay());
        List<Order> orders = orderMapper.selectList(query);

        return orders.stream()
            .map(Order::getTotalAmount)
            .filter(Objects::nonNull)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private int countOrdersForPeriod(LocalDate start, LocalDate end) {
        LambdaQueryWrapper<Order> query = new LambdaQueryWrapper<>();
        query.ge(Order::getCreateTime, start.atStartOfDay())
             .lt(Order::getCreateTime, end.atStartOfDay());
        return orderMapper.selectCount(query).intValue();
    }

    public List<Map<String, Object>> getProductSales(String startDate, String endDate) {
        List<Map<String, Object>> sales = new ArrayList<>();

        LambdaQueryWrapper<Product> productQuery = new LambdaQueryWrapper<>();
        productQuery.eq(Product::getStatus, "active");
        List<Product> products = productMapper.selectList(productQuery);

        for (Product product : products) {
            // 通过订单关联查询商品销售数据
            LambdaQueryWrapper<Order> orderQuery = new LambdaQueryWrapper<>();
            orderQuery.eq(Order::getStatus, OrderStatus.COMPLETED.name());

            if (startDate != null && !startDate.isEmpty()) {
                orderQuery.ge(Order::getDeliveredAt, LocalDate.parse(startDate).atStartOfDay());
            }
            if (endDate != null && !endDate.isEmpty()) {
                orderQuery.lt(Order::getDeliveredAt, LocalDate.parse(endDate).plusDays(1).atStartOfDay());
            }

            List<Order> orders = orderMapper.selectList(orderQuery);

            // 查询所有订单项
            Set<Long> orderIds = orders.stream().map(Order::getId).collect(Collectors.toSet());
            if (orderIds.isEmpty()) {
                Map<String, Object> item = new HashMap<>();
                item.put("productId", product.getId().toString());
                item.put("productName", product.getName());
                item.put("quantity", 0);
                item.put("amount", BigDecimal.ZERO);
                sales.add(item);
                continue;
            }

            LambdaQueryWrapper<OrderItem> itemQuery = new LambdaQueryWrapper<>();
            itemQuery.eq(OrderItem::getProductId, product.getId())
                     .in(OrderItem::getOrderId, orderIds);
            List<OrderItem> items = orderItemMapper.selectList(itemQuery);

            int quantity = items.stream()
                .mapToInt(OrderItem::getActualQty)
                .sum();

            BigDecimal amount = items.stream()
                .map(item -> {
                    BigDecimal unitPrice = item.getUnitPrice() != null ? item.getUnitPrice() : BigDecimal.ZERO;
                    return unitPrice.multiply(new BigDecimal(item.getActualQty() != null ? item.getActualQty() : 0));
                })
                .reduce(BigDecimal.ZERO, BigDecimal::add);

            Map<String, Object> item = new HashMap<>();
            item.put("productId", product.getId().toString());
            item.put("productName", product.getName());
            item.put("quantity", quantity);
            item.put("amount", amount);
            sales.add(item);
        }

        return sales;
    }

    public List<Map<String, Object>> getStationRanking(Integer limit, String startDate, String endDate) {
        List<Map<String, Object>> rankings = new ArrayList<>();

        LambdaQueryWrapper<Station> stationQuery = new LambdaQueryWrapper<>();
        stationQuery.eq(Station::getStatus, "active");
        List<Station> stations = stationMapper.selectList(stationQuery);

        Map<Long, BigDecimal> stationAmounts = new HashMap<>();
        Map<Long, Integer> stationOrders = new HashMap<>();

        for (Station station : stations) {
            LambdaQueryWrapper<Order> orderQuery = new LambdaQueryWrapper<>();
            orderQuery.eq(Order::getStationId, station.getId())
                     .eq(Order::getStatus, OrderStatus.COMPLETED.name());

            if (startDate != null && !startDate.isEmpty()) {
                orderQuery.ge(Order::getDeliveredAt, LocalDate.parse(startDate).atStartOfDay());
            }
            if (endDate != null && !endDate.isEmpty()) {
                orderQuery.lt(Order::getDeliveredAt, LocalDate.parse(endDate).plusDays(1).atStartOfDay());
            }

            List<Order> orders = orderMapper.selectList(orderQuery);

            BigDecimal total = orders.stream()
                .map(Order::getTotalAmount)
                .filter(Objects::nonNull)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

            if (total.compareTo(BigDecimal.ZERO) > 0) {
                stationAmounts.put(station.getId(), total);
                stationOrders.put(station.getId(), orders.size());
            }
        }

        // 排序
        List<Map.Entry<Long, BigDecimal>> sorted = stationAmounts.entrySet().stream()
            .sorted(Map.Entry.<Long, BigDecimal>comparingByValue().reversed())
            .limit(limit != null ? limit : 10)
            .collect(Collectors.toList());

        int rank = 1;
        for (Map.Entry<Long, BigDecimal> entry : sorted) {
            Station station = stationMapper.selectById(entry.getKey());
            Map<String, Object> item = new HashMap<>();
            item.put("stationId", entry.getKey().toString());
            item.put("stationName", station != null ? station.getName() : "");
            item.put("totalAmount", entry.getValue());
            item.put("totalOrders", stationOrders.get(entry.getKey()));
            item.put("rank", rank);
            rankings.add(item);
            rank++;
        }

        return rankings;
    }

    public List<Map<String, Object>> getDailySales(String startDate, String endDate) {
        List<Map<String, Object>> sales = new ArrayList<>();

        LocalDate start = startDate != null ? LocalDate.parse(startDate) : LocalDate.now().minusDays(7);
        LocalDate end = endDate != null ? LocalDate.parse(endDate) : LocalDate.now();

        LocalDate date = start;
        while (!date.isAfter(end)) {
            LambdaQueryWrapper<Order> query = new LambdaQueryWrapper<>();
            query.ge(Order::getCreateTime, date.atStartOfDay())
                 .lt(Order::getCreateTime, date.plusDays(1).atStartOfDay());
            List<Order> orders = orderMapper.selectList(query);

            int buckets = 0;
            BigDecimal amount = BigDecimal.ZERO;
            int newStations = 0;

            for (Order order : orders) {
                if (order.getTotalAmount() != null) {
                    amount = amount.add(order.getTotalAmount());
                }
                if (OrderStatus.COMPLETED.name().equals(order.getStatus())) {
                    List<OrderItem> items = orderItemMapper.selectList(
                        new LambdaQueryWrapper<OrderItem>().eq(OrderItem::getOrderId, order.getId())
                    );
                    buckets += items.stream().mapToInt(OrderItem::getActualQty).sum();
                }
            }

            Map<String, Object> item = new HashMap<>();
            item.put("date", date.toString());
            item.put("buckets", buckets);
            item.put("returned", (int)(buckets * 0.95));
            item.put("amount", amount);
            item.put("newStations", newStations);
            sales.add(item);

            date = date.plusDays(1);
        }

        return sales;
    }

    public Map<String, Object> getStationPurchaseReport(String startDate, String endDate, Long stationId,
            String area, Integer page, Integer size) {
        Map<String, Object> result = new HashMap<>();

        LambdaQueryWrapper<Station> stationQuery = new LambdaQueryWrapper<>();
        if (stationId != null) {
            stationQuery.eq(Station::getId, stationId);
        }
        if (area != null && !area.isEmpty()) {
            stationQuery.eq(Station::getArea, area);
        }
        stationQuery.eq(Station::getStatus, "active");

        List<Station> stations = stationMapper.selectList(stationQuery);

        List<Map<String, Object>> records = new ArrayList<>();
        int total = 0;

        for (Station station : stations) {
            LambdaQueryWrapper<Order> orderQuery = new LambdaQueryWrapper<>();
            orderQuery.eq(Order::getStationId, station.getId())
                     .eq(Order::getStatus, OrderStatus.COMPLETED.name());

            if (startDate != null && !startDate.isEmpty()) {
                orderQuery.ge(Order::getDeliveredAt, LocalDate.parse(startDate).atStartOfDay());
            }
            if (endDate != null && !endDate.isEmpty()) {
                orderQuery.lt(Order::getDeliveredAt, LocalDate.parse(endDate).plusDays(1).atStartOfDay());
            }

            List<Order> orders = orderMapper.selectList(orderQuery);

            int bucketWaterQty = 0;
            BigDecimal bucketWaterAmount = BigDecimal.ZERO;
            int bottleWaterQty = 0;
            BigDecimal bottleWaterAmount = BigDecimal.ZERO;
            BigDecimal otherAmount = BigDecimal.ZERO;

            for (Order order : orders) {
                List<OrderItem> items = orderItemMapper.selectList(
                    new LambdaQueryWrapper<OrderItem>().eq(OrderItem::getOrderId, order.getId())
                );

                for (OrderItem item : items) {
                    Product product = productMapper.selectById(item.getProductId());
                    if (product != null) {
                        if ("bucket_water".equals(product.getCategory())) {
                            bucketWaterQty += item.getActualQty();
                            bucketWaterAmount = bucketWaterAmount.add(
                                product.getPrice().multiply(new BigDecimal(item.getActualQty()))
                            );
                        } else if ("bottled_water".equals(product.getCategory())) {
                            bottleWaterQty += item.getActualQty();
                            bottleWaterAmount = bottleWaterAmount.add(
                                product.getPrice().multiply(new BigDecimal(item.getActualQty()))
                            );
                        } else {
                            otherAmount = otherAmount.add(
                                product.getPrice().multiply(new BigDecimal(item.getActualQty()))
                            );
                        }
                    }
                }
            }

            BigDecimal totalAmount = bucketWaterAmount.add(bottleWaterAmount).add(otherAmount);

            Map<String, Object> record = new HashMap<>();
            record.put("stationId", station.getId().toString());
            record.put("stationName", station.getName());
            record.put("stationCode", station.getId().toString()); // 水站编码使用ID代替
            record.put("area", station.getArea());
            record.put("bucketWaterQty", bucketWaterQty);
            record.put("bucketWaterAmount", bucketWaterAmount);
            record.put("bottleWaterQty", bottleWaterQty);
            record.put("bottleWaterAmount", bottleWaterAmount);
            record.put("otherAmount", otherAmount);
            record.put("totalAmount", totalAmount);
            records.add(record);

            total++;
        }

        result.put("records", records);
        result.put("total", total);
        result.put("page", page);
        result.put("size", size);

        return result;
    }

    public byte[] exportStationPurchaseReport(String startDate, String endDate, Long stationId, String area) {
        Map<String, Object> report = getStationPurchaseReport(startDate, endDate, stationId, area, 1, 10000);
        List<Map<String, Object>> records = (List<Map<String, Object>>) report.get("records");

        StringBuilder sb = new StringBuilder();
        sb.append("水站ID,水站名称,水站编码,区域,桶装水数量,桶装水金额,瓶装水数量,瓶装水金额,其他金额,总金额\n");

        for (Map<String, Object> record : records) {
            sb.append(record.get("stationId")).append(",");
            sb.append(record.get("stationName")).append(",");
            sb.append(record.get("stationCode")).append(",");
            sb.append(record.get("area")).append(",");
            sb.append(record.get("bucketWaterQty")).append(",");
            sb.append(record.get("bucketWaterAmount")).append(",");
            sb.append(record.get("bottleWaterQty")).append(",");
            sb.append(record.get("bottleWaterAmount")).append(",");
            sb.append(record.get("otherAmount")).append(",");
            sb.append(record.get("totalAmount")).append("\n");
        }

        return sb.toString().getBytes();
    }

    public Map<String, Object> getDriverDeliveryReport(String startDate, String endDate, Long driverId,
            Integer page, Integer size) {
        Map<String, Object> result = new HashMap<>();
        result.put("records", new ArrayList<Map<String, Object>>());
        result.put("total", 0);
        result.put("page", page);
        result.put("size", size);
        return result;
    }

    public Map<String, Object> getDriverStatsSummary(String startDate, String endDate) {
        Map<String, Object> summary = new HashMap<>();
        summary.put("totalOrders", 0);
        summary.put("totalBuckets", 0);
        summary.put("totalMileage", 0.0);
        summary.put("avgMileage", 0.0);
        summary.put("onTimeRate", 0.0);
        return summary;
    }

    public byte[] exportDriverDeliveryReport(String startDate, String endDate, Long driverId) {
        try (Workbook workbook = new XSSFWorkbook();
             ByteArrayOutputStream out = new ByteArrayOutputStream()) {

            Sheet sheet = workbook.createSheet("司机配送报表");

            CellStyle headerStyle = createHeaderStyle(workbook);
            CellStyle moneyStyle = createMoneyStyle(workbook);

            int rowNum = 0;
            Row titleRow = sheet.createRow(rowNum++);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("司机配送报表");
            titleCell.setCellStyle(headerStyle);
            sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, 6));

            rowNum++;
            Row infoRow = sheet.createRow(rowNum++);
            if (startDate != null && !startDate.isEmpty()) {
                infoRow.createCell(0).setCellValue("日期范围: " + startDate + " 至 " + (endDate != null ? endDate : "至今"));
            } else {
                infoRow.createCell(0).setCellValue("日期范围: 全部");
            }

            rowNum++;
            Row headerRow = sheet.createRow(rowNum++);
            String[] headers = {"日期", "订单号", "水站名称", "商品明细", "桶数", "金额", "状态"};
            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
            }

            List<Order> orders = getOrdersByDateRange(startDate, endDate, driverId);
            int totalBuckets = 0;
            double totalAmount = 0;

            for (Order order : orders) {
                Row dataRow = sheet.createRow(rowNum++);
                dataRow.createCell(0).setCellValue(order.getCreateTime() != null ? order.getCreateTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd")) : "");

                dataRow.createCell(1).setCellValue(order.getOrderNo());
                dataRow.createCell(2).setCellValue(getStationName(order.getStationId()));

                List<OrderItem> items = orderItemMapper.selectList(
                    new LambdaQueryWrapper<OrderItem>()
                        .eq(OrderItem::getOrderId, order.getId())
                );
                StringBuilder itemDesc = new StringBuilder();
                int bucketCount = 0;
                for (OrderItem item : items) {
                    if (itemDesc.length() > 0) itemDesc.append("; ");
                    itemDesc.append(getProductName(item.getProductId())).append("×").append(item.getQuantity());
                    if (isBucketProduct(item.getProductId())) {
                        bucketCount += item.getQuantity();
                    }
                }
                dataRow.createCell(3).setCellValue(itemDesc.toString());
                dataRow.createCell(4).setCellValue(bucketCount);
                totalBuckets += bucketCount;

                Cell amountCell = dataRow.createCell(5);
                amountCell.setCellValue(order.getTotalAmount() != null ? order.getTotalAmount().doubleValue() : 0);
                amountCell.setCellStyle(moneyStyle);
                if (order.getTotalAmount() != null) totalAmount += order.getTotalAmount().doubleValue();

                dataRow.createCell(6).setCellValue(getStatusText(order.getStatus()));
            }

            rowNum++;
            Row totalRow = sheet.createRow(rowNum++);
            totalRow.createCell(3).setCellValue("合计:");
            totalRow.createCell(4).setCellValue(totalBuckets);
            Cell totalAmountCell = totalRow.createCell(5);
            totalAmountCell.setCellValue(totalAmount);
            totalAmountCell.setCellStyle(moneyStyle);

            for (int i = 0; i < headers.length; i++) {
                sheet.setColumnWidth(i, 4000);
            }

            workbook.write(out);
            return out.toByteArray();

        } catch (IOException e) {
            throw new RuntimeException("导出司机配送报表失败: " + e.getMessage());
        }
    }

    public Map<String, Object> getBucketStatsSummary() {
        Map<String, Object> summary = new HashMap<>();
        summary.put("owedBucketsTotal", 0);
        summary.put("owedStations", 0);
        summary.put("warehouseStock", 0);
        summary.put("inTransit", 0);
        summary.put("transitDrivers", 0);
        return summary;
    }

    public List<Map<String, Object>> getStationBucketReport() {
        List<Map<String, Object>> report = new ArrayList<>();
        return report;
    }

    public List<Map<String, Object>> getWarehouseBucketReport() {
        List<Map<String, Object>> report = new ArrayList<>();
        return report;
    }

    public List<Map<String, Object>> getInTransitBuckets() {
        List<Map<String, Object>> buckets = new ArrayList<>();
        return buckets;
    }

    public byte[] exportInTransitBuckets() {
        try (Workbook workbook = new XSSFWorkbook();
             ByteArrayOutputStream out = new ByteArrayOutputStream()) {

            Sheet sheet = workbook.createSheet("在途桶装报表");

            CellStyle headerStyle = createHeaderStyle(workbook);

            int rowNum = 0;
            Row titleRow = sheet.createRow(rowNum++);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("在途桶装报表");
            titleCell.setCellStyle(headerStyle);
            sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, 5));

            rowNum++;
            Row headerRow = sheet.createRow(rowNum++);
            String[] headers = {"司机ID", "司机名称", "工号", "联系电话", "负责区域", "在途桶数"};
            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
            }

            rowNum++;
            Row emptyRow = sheet.createRow(rowNum++);
            Cell emptyCell = emptyRow.createCell(0);
            emptyCell.setCellValue("暂无在途数据");

            for (int i = 0; i < headers.length; i++) {
                sheet.setColumnWidth(i, 4000);
            }

            workbook.write(out);
            return out.toByteArray();

        } catch (IOException e) {
            throw new RuntimeException("导出在途桶装报表失败: " + e.getMessage());
        }
    }

    private List<Order> getOrdersByDateRange(String startDate, String endDate, Long driverId) {
        LambdaQueryWrapper<Order> wrapper = new LambdaQueryWrapper<>();

        if (startDate != null && !startDate.isEmpty()) {
            wrapper.ge(Order::getCreateTime, LocalDate.parse(startDate).atStartOfDay());
        }
        if (endDate != null && !endDate.isEmpty()) {
            wrapper.le(Order::getCreateTime, LocalDate.parse(endDate).atTime(23, 59, 59));
        }
        if (driverId != null) {
            wrapper.eq(Order::getDriverId, driverId);
        }
        wrapper.eq(Order::getStatus, "completed");
        wrapper.orderByDesc(Order::getCreateTime);

        return orderMapper.selectList(wrapper);
    }

    private String getStationName(Long stationId) {
        if (stationId == null) return "";
        Station station = stationMapper.selectById(stationId);
        return station != null ? station.getName() : "";
    }

    private String getProductName(Long productId) {
        if (productId == null) return "";
        Product product = productMapper.selectById(productId);
        return product != null ? product.getName() : "";
    }

    private boolean isBucketProduct(Long productId) {
        if (productId == null) return false;
        Product product = productMapper.selectById(productId);
        return product != null && "bucket_water".equals(product.getCategory());
    }

    private String getStatusText(String status) {
        if (status == null) return "";
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

    private CellStyle createHeaderStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        Font font = workbook.createFont();
        font.setBold(true);
        font.setFontHeightInPoints((short) 12);
        style.setFont(font);
        style.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);
        style.setAlignment(HorizontalAlignment.CENTER);
        return style;
    }

    private CellStyle createMoneyStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        style.setDataFormat(workbook.createDataFormat().getFormat("¥#,##0.00"));
        style.setAlignment(HorizontalAlignment.RIGHT);
        return style;
    }
}
