package com.bucketwater.oms.module.admin.service;

import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.admin.dto.DriverManagementDTO;
import com.bucketwater.oms.module.driver.entity.Driver;
import com.bucketwater.oms.module.driver.entity.DriverWarehouse;
import com.bucketwater.oms.module.driver.mapper.DriverMapper;
import com.bucketwater.oms.module.driver.mapper.DriverWarehouseMapper;
import com.bucketwater.oms.module.order.entity.Order;
import com.bucketwater.oms.module.order.entity.OrderItem;
import com.bucketwater.oms.module.order.mapper.OrderItemMapper;
import com.bucketwater.oms.module.order.mapper.OrderMapper;
import com.bucketwater.oms.module.user.entity.User;
import com.bucketwater.oms.module.user.mapper.UserMapper;
import com.bucketwater.oms.module.warehouse.entity.Warehouse;
import com.bucketwater.oms.module.warehouse.mapper.WarehouseMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

@Service
public class AdminDriverService {

    private static final Logger log = LoggerFactory.getLogger(AdminDriverService.class);

    @Autowired
    private DriverMapper driverMapper;

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private OrderItemMapper orderItemMapper;

    @Autowired
    private DriverWarehouseMapper driverWarehouseMapper;

    @Autowired
    private WarehouseMapper warehouseMapper;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public List<Driver> getAllDrivers(String status) {
        return getAllDrivers(status, null);
    }

    public List<Driver> getAllDrivers(String status, Long factoryId) {
        var wrapper = new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Driver>();
        if (status != null && !status.isEmpty()) {
            wrapper.eq(Driver::getStatus, status);
        }
        if (factoryId != null) {
            wrapper.eq(Driver::getFactoryId, factoryId);
        }
        wrapper.orderByDesc(Driver::getCreateTime);
        List<Driver> drivers = driverMapper.selectList(wrapper);
        
        for (Driver driver : drivers) {
            driver.setArea(driver.getRegion());
            if (driver.getCode() == null || driver.getCode().isEmpty()) {
                driver.setCode("D" + driver.getId());
            }
            if (driver.getOnlineStatus() == null) {
                driver.setOnlineStatus("offline");
            }
            
            LocalDateTime todayStart = LocalDate.now().atStartOfDay();
            LocalDateTime todayEnd = LocalDate.now().plusDays(1).atStartOfDay();
            var orderWrapper = new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Order>();
            orderWrapper.eq(Order::getDriverId, driver.getId())
                       .eq(Order::getStatus, "completed")
                       .ge(Order::getDeliveredAt, todayStart)
                       .lt(Order::getDeliveredAt, todayEnd);
            long todayDeliveries = orderMapper.selectCount(orderWrapper);
            driver.setBucketOnWay((int) todayDeliveries);
            driver.setOwedBuckets((int) todayDeliveries);
        }
        
        return drivers;
    }

    public Driver getDriverById(Long driverId) {
        return getDriverById(driverId, null);
    }

    public Driver getDriverById(Long driverId, Long factoryId) {
        Driver driver = driverMapper.selectById(driverId);
        if (driver == null) {
            throw new BusinessException(ResultCode.DRIVER_NOT_FOUND);
        }
        if (factoryId != null && !factoryId.equals(driver.getFactoryId())) {
            throw new BusinessException(ResultCode.FORBIDDEN, "无权访问该司机");
        }
        driver.setArea(driver.getRegion());
        if (driver.getCode() == null || driver.getCode().isEmpty()) {
            driver.setCode("D" + driver.getId());
        }

        List<Long> warehouseIds = driverWarehouseMapper.selectWarehouseIdsByDriverId(driverId);
        if (warehouseIds != null && !warehouseIds.isEmpty()) {
            List<Map<String, Object>> warehouseList = new ArrayList<>();
            List<String> warehouseNames = new ArrayList<>();
            for (Long wId : warehouseIds) {
                Warehouse warehouse = warehouseMapper.selectById(wId);
                if (warehouse != null) {
                    Map<String, Object> wMap = new HashMap<>();
                    wMap.put("id", wId.toString());
                    wMap.put("name", warehouse.getName());
                    warehouseList.add(wMap);
                    warehouseNames.add(warehouse.getName());
                }
            }
            driver.setWarehouseIds(warehouseIds);
            if (!warehouseList.isEmpty()) {
                driver.setWarehouseList(warehouseList);
            }
            if (!warehouseNames.isEmpty()) {
                driver.setWarehouseNames(warehouseNames);
            }
        }

        return driver;
    }

    @Transactional
    public Driver createDriver(DriverManagementDTO request, String userPhone) {
        return createDriver(request, userPhone, null);
    }

    @Transactional
    public Driver createDriver(DriverManagementDTO request, String userPhone, Long factoryId) {
        User existingUser = userMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<User>()
                .eq(User::getPhone, userPhone)
        );
        if (existingUser != null) {
            throw new BusinessException(ResultCode.DATA_EXISTS);
        }

        Driver driver = new Driver();
        driver.setCode(generateDriverCode());
        driver.setName(request.getName());
        driver.setPhone(request.getPhone());
        String region = (request.getArea() != null && !request.getArea().isEmpty())
            ? request.getArea() : request.getRegion();
        driver.setRegion(region);
        driver.setArea(region);
        driver.setIdCard(request.getIdCard());
        driver.setVehicleInfo(request.getVehicleInfo());
        driver.setLicensePlate(request.getLicensePlate());
        driver.setVehicleType(request.getVehicleType());
        driver.setEmergencyContact(request.getEmergencyContact());
        driver.setWarehouseId(request.getWarehouseId());
        driver.setFactoryId(factoryId);
        driver.setRemark(request.getRemark());
        driver.setStatus("active");
        driver.setCreateTime(LocalDateTime.now());
        driver.setUpdateTime(LocalDateTime.now());

        driverMapper.insert(driver);

        String rawPassword = (request.getPassword() != null && !request.getPassword().isEmpty())
            ? request.getPassword() : "123456";
        String encodedPassword = passwordEncoder.encode(rawPassword);

        User user = new User();
        user.setPhone(request.getPhone());
        user.setPassword(encodedPassword);
        user.setName(request.getName());
        user.setRole("driver");
        user.setDriverId(driver.getId());
        user.setStatus("active");
        user.setCreateTime(LocalDateTime.now());
        user.setUpdateTime(LocalDateTime.now());

        userMapper.insert(user);

        saveDriverWarehouses(driver.getId(), request.getWarehouseIds(), request.getWarehouseId());

        return driver;
    }

    private void saveDriverWarehouses(Long driverId, List<Long> warehouseIds, Long singleWarehouseId) {
        if (warehouseIds == null || warehouseIds.isEmpty()) {
            if (singleWarehouseId != null) {
                DriverWarehouse dw = new DriverWarehouse();
                dw.setDriverId(driverId);
                dw.setWarehouseId(singleWarehouseId);
                dw.setIsPrimary(true);
                dw.setStatus("active");
                dw.setCreateTime(LocalDateTime.now());
                dw.setUpdateTime(LocalDateTime.now());
                driverWarehouseMapper.insert(dw);
            }
            return;
        }

        for (int i = 0; i < warehouseIds.size(); i++) {
            DriverWarehouse dw = new DriverWarehouse();
            dw.setDriverId(driverId);
            dw.setWarehouseId(warehouseIds.get(i));
            dw.setIsPrimary(i == 0);
            dw.setStatus("active");
            dw.setCreateTime(LocalDateTime.now());
            dw.setUpdateTime(LocalDateTime.now());
            driverWarehouseMapper.insert(dw);
        }
    }

    @Transactional
    public Driver updateDriver(Long driverId, DriverManagementDTO request) {
        return updateDriver(driverId, request, null);
    }

    @Transactional
    public Driver updateDriver(Long driverId, DriverManagementDTO request, Long factoryId) {
        log.info("=== updateDriver 开始 ===");
        log.info("driverId: {}, driverId 类型: {}, request: {}, factoryId: {}", driverId, driverId.getClass().getName(), request, factoryId);

        Driver driver = driverMapper.selectById(driverId);
        log.info("selectById 结果: {}", driver);

        if (driver == null) {
            log.warn("selectById 返回 null，尝试使用 Wrapper 查询...");
            var wrapper = new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Driver>();
            wrapper.eq(Driver::getId, driverId);
            driver = driverMapper.selectOne(wrapper);
            log.info("selectOne 查询结果: {}", driver);

            if (driver == null) {
                log.error("司机不存在: driverId={}", driverId);
                throw new BusinessException(ResultCode.DRIVER_NOT_FOUND);
            }
        }

        if (factoryId != null && !factoryId.equals(driver.getFactoryId())) {
            log.warn("无权修改该司机: driverId={}, factoryId={}, driverFactoryId={}", driverId, factoryId, driver.getFactoryId());
            throw new BusinessException(ResultCode.FORBIDDEN, "无权修改该司机");
        }

        log.info("更新前的司机数据: {}", driver);

        if (request.getName() != null) {
            driver.setName(request.getName());
            log.info("设置姓名: {}", request.getName());
        }
        if (request.getPhone() != null) {
            driver.setPhone(request.getPhone());
            log.info("设置电话: {}", request.getPhone());
        }
        if (request.getRegion() != null || request.getArea() != null) {
            String region = (request.getArea() != null && !request.getArea().isEmpty())
                ? request.getArea() : request.getRegion();
            driver.setRegion(region);
            driver.setArea(region);
            log.info("设置区域: {}", region);
        }
        if (request.getIdCard() != null) {
            driver.setIdCard(request.getIdCard());
            log.info("设置身份证: {}", request.getIdCard());
        }
        if (request.getVehicleInfo() != null) {
            driver.setVehicleInfo(request.getVehicleInfo());
            log.info("设置车辆信息: {}", request.getVehicleInfo());
        }
        if (request.getLicensePlate() != null) {
            driver.setLicensePlate(request.getLicensePlate());
            log.info("设置车牌号: {}", request.getLicensePlate());
        }
        if (request.getVehicleType() != null) {
            driver.setVehicleType(request.getVehicleType());
            log.info("设置车辆类型: {}", request.getVehicleType());
        }
        if (request.getEmergencyContact() != null) {
            driver.setEmergencyContact(request.getEmergencyContact());
            log.info("设置紧急联系人: {}", request.getEmergencyContact());
        }
        if (request.getWarehouseId() != null) {
            driver.setWarehouseId(request.getWarehouseId());
            log.info("设置仓库ID: {}", request.getWarehouseId());
        }
        if (request.getRemark() != null) {
            driver.setRemark(request.getRemark());
            log.info("设置备注: {}", request.getRemark());
        }

        driver.setUpdateTime(LocalDateTime.now());
        log.info("更新后的司机数据: {}", driver);
        log.info("开始执行 updateById...");

        driverMapper.updateById(driver);

        log.info("updateById 执行完成");

        User user = userMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<User>()
                .eq(User::getDriverId, driverId)
        );

        if (user != null) {
            if (request.getName() != null) {
                user.setName(request.getName());
            }
            if (request.getPhone() != null) {
                user.setPhone(request.getPhone());
            }
            if (request.getPassword() != null && !request.getPassword().isEmpty()) {
                user.setPassword(passwordEncoder.encode(request.getPassword()));
            }
            user.setUpdateTime(LocalDateTime.now());
            userMapper.updateById(user);
        }

        if (request.getWarehouseIds() != null || request.getWarehouseId() != null) {
            var deleteWrapper = new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<DriverWarehouse>();
            deleteWrapper.eq(DriverWarehouse::getDriverId, driverId);
            driverWarehouseMapper.delete(deleteWrapper);

            saveDriverWarehouses(driverId, request.getWarehouseIds(), request.getWarehouseId());
        }

        log.info("=== updateDriver 结束 ===");

        return getDriverById(driverId, factoryId);
    }

    @Transactional
    public void updateDriverStatus(Long driverId, String status) {
        updateDriverStatus(driverId, status, null);
    }

    @Transactional
    public void updateDriverStatus(Long driverId, String status, Long factoryId) {
        Driver driver = driverMapper.selectById(driverId);
        if (driver == null) {
            throw new BusinessException(ResultCode.DRIVER_NOT_FOUND);
        }
        if (factoryId != null && !factoryId.equals(driver.getFactoryId())) {
            throw new BusinessException(ResultCode.FORBIDDEN, "无权修改该司机状态");
        }

        driver.setStatus(status);
        driver.setUpdateTime(LocalDateTime.now());
        driverMapper.updateById(driver);

        userMapper.update(null,
            new com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper<User>()
                .eq(User::getDriverId, driverId)
                .set(User::getStatus, status)
        );
    }

    @Transactional
    public void resetDriverPassword(Long driverId) {
        resetDriverPassword(driverId, null);
    }

    @Transactional
    public void resetDriverPassword(Long driverId, Long factoryId) {
        Driver driver = driverMapper.selectById(driverId);
        if (driver == null) {
            throw new BusinessException(ResultCode.DRIVER_NOT_FOUND);
        }
        if (factoryId != null && !factoryId.equals(driver.getFactoryId())) {
            throw new BusinessException(ResultCode.FORBIDDEN, "无权重置该司机密码");
        }

        userMapper.update(null,
            new com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper<User>()
                .eq(User::getDriverId, driverId)
                .set(User::getPassword, passwordEncoder.encode("123456"))
        );
    }

    public Map<String, Object> getDriverStats() {
        return getDriverStats(null);
    }

    public Map<String, Object> getDriverStats(Long factoryId) {
        Map<String, Object> stats = new HashMap<>();

        var wrapper = new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Driver>();
        if (factoryId != null) {
            wrapper.eq(Driver::getFactoryId, factoryId);
        }
        List<Driver> allDrivers = driverMapper.selectList(wrapper);
        stats.put("totalDrivers", allDrivers.size());

        long onlineCount = allDrivers.stream()
            .filter(d -> "online".equals(d.getOnlineStatus()))
            .count();
        stats.put("online", onlineCount);

        long breakCount = allDrivers.stream()
            .filter(d -> "break".equals(d.getOnlineStatus()))
            .count();
        stats.put("break", breakCount);

        long offlineCount = allDrivers.stream()
            .filter(d -> d.getOnlineStatus() == null || "offline".equals(d.getOnlineStatus()))
            .count();
        stats.put("offline", offlineCount);

        long completedToday = 0;
        LocalDateTime todayStart = LocalDate.now().atStartOfDay();
        LocalDateTime todayEnd = LocalDate.now().plusDays(1).atStartOfDay();
        for (Driver driver : allDrivers) {
            var orderWrapper = new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Order>();
            orderWrapper.eq(Order::getDriverId, driver.getId())
                  .eq(Order::getStatus, "completed")
                  .ge(Order::getDeliveredAt, todayStart)
                  .lt(Order::getDeliveredAt, todayEnd);
            completedToday += orderMapper.selectCount(orderWrapper);
        }
        stats.put("completedToday", completedToday);

        return stats;
    }

    public List<Map<String, Object>> getDeliveryReport(String startDate, String endDate, Long driverId) {
        return getDeliveryReport(startDate, endDate, driverId, null);
    }

    public List<Map<String, Object>> getDeliveryReport(String startDate, String endDate, Long driverId, Long factoryId) {
        List<Map<String, Object>> reports = new ArrayList<>();

        var wrapper = new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Driver>();
        if (driverId != null) {
            wrapper.eq(Driver::getId, driverId);
        }
        if (factoryId != null) {
            wrapper.eq(Driver::getFactoryId, factoryId);
        }
        List<Driver> drivers = driverMapper.selectList(wrapper);

        for (Driver driver : drivers) {
            var orderWrapper = new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Order>();
            orderWrapper.eq(Order::getDriverId, driver.getId())
                       .eq(Order::getStatus, "completed");

            if (startDate != null && !startDate.isEmpty()) {
                orderWrapper.ge(Order::getDeliveredAt, LocalDate.parse(startDate).atStartOfDay());
            }
            if (endDate != null && !endDate.isEmpty()) {
                orderWrapper.lt(Order::getDeliveredAt, LocalDate.parse(endDate).plusDays(1).atStartOfDay());
            }

            List<Order> orders = orderMapper.selectList(orderWrapper);

            int totalOrders = orders.size();
            int totalBuckets = 0;
            BigDecimal totalAmount = BigDecimal.ZERO;

            for (Order order : orders) {
                var itemWrapper = new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<OrderItem>();
                itemWrapper.eq(OrderItem::getOrderId, order.getId());
                List<OrderItem> items = orderItemMapper.selectList(itemWrapper);
                for (OrderItem item : items) {
                    totalBuckets += item.getActualQty() != null ? item.getActualQty() : 0;
                }
                if (order.getTotalAmount() != null) {
                    totalAmount = totalAmount.add(order.getTotalAmount());
                }
            }

            String driverCode = driver.getCode();
            if (driverCode == null || driverCode.isEmpty()) {
                driverCode = "D" + driver.getId();
            }

            Map<String, Object> report = new HashMap<>();
            report.put("driverId", driver.getId().toString());
            report.put("driverName", driver.getName());
            report.put("driverCode", driverCode);
            report.put("area", driver.getRegion() != null ? driver.getRegion() : driver.getArea());
            report.put("orders", totalOrders);
            report.put("buckets", totalBuckets);
            report.put("mileage", 0.0);
            report.put("amount", totalAmount);
            report.put("onTimeRate", 1.0);
            reports.add(report);
        }

        return reports;
    }

    public List<Map<String, Object>> getInTransitBuckets() {
        return getInTransitBuckets(null);
    }

    public List<Map<String, Object>> getInTransitBuckets(Long factoryId) {
        List<Map<String, Object>> buckets = new ArrayList<>();

        var driverWrapper = new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Driver>();
        driverWrapper.eq(Driver::getStatus, "active");
        if (factoryId != null) {
            driverWrapper.eq(Driver::getFactoryId, factoryId);
        }
        List<Driver> drivers = driverMapper.selectList(driverWrapper);

        for (Driver driver : drivers) {
            var wrapper = new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Order>();
            wrapper.eq(Order::getDriverId, driver.getId())
                   .in(Order::getStatus, "dispatched", "delivering");

            long inTransitOrders = orderMapper.selectCount(wrapper);

            if (inTransitOrders > 0) {
                String driverCode = driver.getCode();
                if (driverCode == null || driverCode.isEmpty()) {
                    driverCode = "D" + driver.getId();
                }
                
                Map<String, Object> item = new HashMap<>();
                item.put("driverId", driver.getId().toString());
                item.put("driverName", driver.getName());
                item.put("driverCode", driverCode);
                item.put("phone", driver.getPhone());
                item.put("area", driver.getRegion() != null ? driver.getRegion() : driver.getArea());
                item.put("inTransitBuckets", (int)(inTransitOrders * 10));
                item.put("lastReturnTime", driver.getLastOnlineTime());
                buckets.add(item);
            }
        }

        return buckets;
    }

    private String generateDriverCode() {
        return "D" + System.currentTimeMillis();
    }
}
