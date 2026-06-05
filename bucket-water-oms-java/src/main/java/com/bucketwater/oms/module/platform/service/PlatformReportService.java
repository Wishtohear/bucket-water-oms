package com.bucketwater.oms.module.platform.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.bucketwater.oms.module.factory.entity.Factory;
import com.bucketwater.oms.module.factory.mapper.FactoryMapper;
import com.bucketwater.oms.module.order.entity.Order;
import com.bucketwater.oms.module.order.mapper.OrderMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

@Service
public class PlatformReportService {

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private FactoryMapper factoryMapper;

    public Map<String, Object> getSalesStats(LocalDate startDate, LocalDate endDate, Long factoryId) {
        Map<String, Object> result = new HashMap<>();
        Map<String, Object> stats = new HashMap<>();

        LambdaQueryWrapper<Order> wrapper = new LambdaQueryWrapper<>();
        if (startDate != null) {
            wrapper.ge(Order::getCreateTime, startDate.atStartOfDay());
        }
        if (endDate != null) {
            wrapper.lt(Order::getCreateTime, endDate.plusDays(1).atStartOfDay());
        }
        if (factoryId != null) {
            wrapper.eq(Order::getFactoryId, factoryId);
        }

        List<Order> orders = orderMapper.selectList(wrapper);
        BigDecimal totalAmount = BigDecimal.ZERO;
        Set<Long> stationSet = new HashSet<>();
        Set<Long> driverSet = new HashSet<>();
        for (Order o : orders) {
            if (o.getTotalAmount() != null) {
                totalAmount = totalAmount.add(o.getTotalAmount());
            }
            if (o.getStationId() != null) stationSet.add(o.getStationId());
            if (o.getDriverId() != null) driverSet.add(o.getDriverId());
        }

        long count = orders.size();
        stats.put("totalAmount", totalAmount);
        stats.put("orderCount", count);
        stats.put("avgOrderAmount", count > 0 ? totalAmount.divide(BigDecimal.valueOf(count), 2, java.math.RoundingMode.HALF_UP) : BigDecimal.ZERO);
        stats.put("customerCount", stationSet.size());

        result.put("stats", stats);

        Map<String, BigDecimal> trend = new LinkedHashMap<>();
        Map<LocalDate, BigDecimal> dailyMap = new TreeMap<>();
        for (Order o : orders) {
            if (o.getCreateTime() != null && o.getTotalAmount() != null) {
                LocalDate d = o.getCreateTime().toLocalDate();
                dailyMap.merge(d, o.getTotalAmount(), BigDecimal::add);
            }
        }
        dailyMap.forEach((k, v) -> trend.put(k.toString(), v));
        result.put("trend", trend);
        return result;
    }

    public Map<String, Object> getOrderStats(LocalDate startDate, LocalDate endDate) {
        Map<String, Object> result = new HashMap<>();
        List<Map<String, Object>> records = new ArrayList<>();

        LambdaQueryWrapper<Order> wrapper = new LambdaQueryWrapper<>();
        if (startDate != null) {
            wrapper.ge(Order::getCreateTime, startDate.atStartOfDay());
        }
        if (endDate != null) {
            wrapper.lt(Order::getCreateTime, endDate.plusDays(1).atStartOfDay());
        }
        List<Order> orders = orderMapper.selectList(wrapper);

        Map<LocalDate, List<Order>> grouped = new TreeMap<>();
        for (Order o : orders) {
            if (o.getCreateTime() != null) {
                grouped.computeIfAbsent(o.getCreateTime().toLocalDate(), k -> new ArrayList<>()).add(o);
            }
        }
        for (Map.Entry<LocalDate, List<Order>> entry : grouped.entrySet()) {
            Map<String, Object> row = new HashMap<>();
            row.put("date", entry.getKey().toString());
            long total = entry.getValue().size();
            long completed = entry.getValue().stream().filter(o -> "COMPLETED".equalsIgnoreCase(o.getStatus()) || "completed".equalsIgnoreCase(o.getStatus())).count();
            long cancelled = entry.getValue().stream().filter(o -> "CANCELLED".equalsIgnoreCase(o.getStatus()) || "cancelled".equalsIgnoreCase(o.getStatus())).count();
            BigDecimal amount = entry.getValue().stream()
                    .map(Order::getTotalAmount)
                    .filter(Objects::nonNull)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
            row.put("orderCount", total);
            row.put("totalAmount", amount);
            row.put("completedCount", completed);
            row.put("cancelledCount", cancelled);
            records.add(row);
        }
        result.put("records", records);
        return result;
    }

    public Map<String, Object> getFactoryComparison(LocalDate startDate, LocalDate endDate) {
        Map<String, Object> result = new HashMap<>();
        List<Map<String, Object>> records = new ArrayList<>();

        LambdaQueryWrapper<Order> wrapper = new LambdaQueryWrapper<>();
        if (startDate != null) {
            wrapper.ge(Order::getCreateTime, startDate.atStartOfDay());
        }
        if (endDate != null) {
            wrapper.lt(Order::getCreateTime, endDate.plusDays(1).atStartOfDay());
        }
        List<Order> orders = orderMapper.selectList(wrapper);

        Map<Long, List<Order>> grouped = new HashMap<>();
        for (Order o : orders) {
            if (o.getFactoryId() != null) {
                grouped.computeIfAbsent(o.getFactoryId(), k -> new ArrayList<>()).add(o);
            }
        }

        List<Map<String, Object>> temp = new ArrayList<>();
        for (Map.Entry<Long, List<Order>> entry : grouped.entrySet()) {
            Map<String, Object> row = new HashMap<>();
            Factory factory = factoryMapper.selectById(entry.getKey());
            row.put("factoryId", entry.getKey());
            row.put("factoryName", factory != null ? factory.getName() : "未知水厂");
            long count = entry.getValue().size();
            BigDecimal amount = entry.getValue().stream()
                    .map(Order::getTotalAmount)
                    .filter(Objects::nonNull)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
            row.put("orderCount", count);
            row.put("totalAmount", amount);
            row.put("avgAmount", count > 0 ? amount.divide(BigDecimal.valueOf(count), 2, java.math.RoundingMode.HALF_UP) : BigDecimal.ZERO);
            temp.add(row);
        }
        temp.sort((a, b) -> Long.compare((long) b.get("orderCount"), (long) a.get("orderCount")));
        for (int i = 0; i < temp.size(); i++) {
            temp.get(i).put("rank", i + 1);
            records.add(temp.get(i));
        }
        result.put("records", records);
        return result;
    }
}
