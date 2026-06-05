package com.bucketwater.oms.module.platform.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.bucketwater.oms.module.driver.entity.Driver;
import com.bucketwater.oms.module.driver.mapper.DriverMapper;
import com.bucketwater.oms.module.factory.entity.Factory;
import com.bucketwater.oms.module.factory.mapper.FactoryMapper;
import com.bucketwater.oms.module.order.entity.Order;
import com.bucketwater.oms.module.order.mapper.OrderMapper;
import com.bucketwater.oms.module.platform.dto.PlatformDashboardDTO;
import com.bucketwater.oms.module.station.entity.Station;
import com.bucketwater.oms.module.station.mapper.StationMapper;
import com.bucketwater.oms.module.warehouse.entity.Warehouse;
import com.bucketwater.oms.module.warehouse.mapper.WarehouseMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class PlatformDashboardService {

    @Autowired
    private FactoryMapper factoryMapper;

    @Autowired
    private StationMapper stationMapper;

    @Autowired
    private DriverMapper driverMapper;

    @Autowired
    private WarehouseMapper warehouseMapper;

    @Autowired
    private OrderMapper orderMapper;

    public PlatformDashboardDTO getDashboardData() {
        PlatformDashboardDTO dto = new PlatformDashboardDTO();
        PlatformDashboardDTO.Stats stats = new PlatformDashboardDTO.Stats();

        stats.setTotalFactories(factoryMapper.selectCount(null));
        stats.setTotalStations(stationMapper.selectCount(null));
        stats.setTotalDrivers(driverMapper.selectCount(null));
        stats.setTotalWarehouses(warehouseMapper.selectCount(null));
        stats.setTotalOrders(orderMapper.selectCount(null));

        LocalDateTime startOfDay = LocalDate.now().atStartOfDay();
        LocalDateTime endOfDay = startOfDay.plusDays(1);
        stats.setTodayOrders(orderMapper.selectCount(
                new LambdaQueryWrapper<Order>().ge(Order::getCreateTime, startOfDay).lt(Order::getCreateTime, endOfDay)));

        List<Map<String, Object>> sumList = orderMapper.selectMaps(
                new LambdaQueryWrapper<Order>().select(Order::getTotalAmount)
                        .ge(Order::getCreateTime, startOfDay).lt(Order::getCreateTime, endOfDay));
        BigDecimal todaySales = BigDecimal.ZERO;
        if (sumList != null) {
            for (Map<String, Object> m : sumList) {
                Object v = m.get("totalAmount");
                if (v != null) {
                    todaySales = todaySales.add(new BigDecimal(v.toString()));
                }
            }
        }
        stats.setTodaySales(todaySales);
        dto.setStats(stats);

        List<Factory> factories = factoryMapper.selectList(
                new LambdaQueryWrapper<Factory>().orderByDesc(Factory::getCreateTime).last("LIMIT 10"));
        List<Map<String, Object>> factoryList = factories.stream().map(f -> {
            Map<String, Object> m = new HashMap<>();
            m.put("id", f.getId());
            m.put("name", f.getName());
            m.put("code", f.getCode());
            m.put("contact", f.getContact());
            m.put("phone", f.getPhone());
            m.put("address", f.getAddress());
            m.put("status", f.getStatus());
            m.put("createTime", f.getCreateTime());
            return m;
        }).collect(Collectors.toList());
        dto.setFactories(factoryList);
        return dto;
    }
}
