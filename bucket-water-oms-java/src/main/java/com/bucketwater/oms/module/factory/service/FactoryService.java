package com.bucketwater.oms.module.factory.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.driver.entity.Driver;
import com.bucketwater.oms.module.driver.mapper.DriverMapper;
import com.bucketwater.oms.module.factory.dto.FactoryDetailDTO;
import com.bucketwater.oms.module.factory.entity.Factory;
import com.bucketwater.oms.module.factory.mapper.FactoryMapper;
import com.bucketwater.oms.module.order.entity.Order;
import com.bucketwater.oms.module.order.mapper.OrderMapper;
import com.bucketwater.oms.module.station.entity.Station;
import com.bucketwater.oms.module.station.mapper.StationMapper;
import com.bucketwater.oms.module.user.entity.User;
import com.bucketwater.oms.module.user.mapper.UserMapper;
import com.bucketwater.oms.module.warehouse.entity.Warehouse;
import com.bucketwater.oms.module.warehouse.mapper.WarehouseMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class FactoryService {

    @Autowired
    private FactoryMapper factoryMapper;

    @Autowired
    private StationMapper stationMapper;

    @Autowired
    private WarehouseMapper warehouseMapper;

    @Autowired
    private DriverMapper driverMapper;

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private UserMapper userMapper;

    public IPage<Factory> getFactoryPage(String keyword, String status, Integer page, Integer size) {
        Page<Factory> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<Factory> wrapper = new LambdaQueryWrapper<>();
        
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.and(w -> w.like(Factory::getName, keyword)
                   .or()
                   .like(Factory::getCode, keyword));
        }
        
        if (status != null && !status.isEmpty()) {
            wrapper.eq(Factory::getStatus, status);
        }
        
        wrapper.orderByDesc(Factory::getCreateTime);
        return factoryMapper.selectPage(pageParam, wrapper);
    }

    public List<Factory> getAllFactories(String status) {
        LambdaQueryWrapper<Factory> wrapper = new LambdaQueryWrapper<>();
        if (status != null && !status.isEmpty()) {
            wrapper.eq(Factory::getStatus, status);
        }
        wrapper.orderByDesc(Factory::getCreateTime);
        return factoryMapper.selectList(wrapper);
    }

    public Factory getFactoryById(Long id) {
        Factory factory = factoryMapper.selectById(id);
        if (factory == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "水厂不存在");
        }
        return factory;
    }

    public FactoryDetailDTO getFactoryDetail(Long id) {
        Factory factory = getFactoryById(id);
        FactoryDetailDTO dto = new FactoryDetailDTO();

        Map<String, Object> factoryMap = new HashMap<>();
        factoryMap.put("id", factory.getId());
        factoryMap.put("name", factory.getName());
        factoryMap.put("code", factory.getCode());
        factoryMap.put("contact", factory.getContact());
        factoryMap.put("phone", factory.getPhone());
        factoryMap.put("address", factory.getAddress());
        factoryMap.put("status", factory.getStatus());
        factoryMap.put("remark", factory.getRemark());
        factoryMap.put("createTime", factory.getCreateTime());
        factoryMap.put("updateTime", factory.getUpdateTime());
        dto.setFactory(factoryMap);

        FactoryDetailDTO.Stats stats = new FactoryDetailDTO.Stats();
        stats.setStations(stationMapper.selectCount(
                new LambdaQueryWrapper<Station>().eq(Station::getFactoryId, id)));
        stats.setWarehouses(warehouseMapper.selectCount(
                new LambdaQueryWrapper<Warehouse>().eq(Warehouse::getFactoryId, id)));
        stats.setDrivers(driverMapper.selectCount(
                new LambdaQueryWrapper<Driver>().eq(Driver::getFactoryId, id)));
        stats.setOrders(orderMapper.selectCount(
                new LambdaQueryWrapper<Order>().eq(Order::getFactoryId, id)));

        LocalDateTime startOfDay = LocalDate.now().atStartOfDay();
        stats.setTodayOrders(orderMapper.selectCount(
                new LambdaQueryWrapper<Order>()
                        .eq(Order::getFactoryId, id)
                        .ge(Order::getCreateTime, startOfDay)));

        LocalDateTime startOfMonth = LocalDate.now().withDayOfMonth(1).atStartOfDay();
        List<Order> monthOrders = orderMapper.selectList(
                new LambdaQueryWrapper<Order>()
                        .eq(Order::getFactoryId, id)
                        .ge(Order::getCreateTime, startOfMonth));
        BigDecimal monthSales = monthOrders.stream()
                .map(Order::getTotalAmount)
                .filter(java.util.Objects::nonNull)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        stats.setMonthSales(monthSales);
        dto.setStats(stats);

        List<User> admins = userMapper.selectList(
                new LambdaQueryWrapper<User>().eq(User::getFactoryId, id));
        List<Map<String, Object>> adminList = new ArrayList<>();
        for (User u : admins) {
            Map<String, Object> m = new HashMap<>();
            m.put("id", u.getId());
            m.put("name", u.getName());
            m.put("phone", u.getPhone());
            m.put("role", u.getRole());
            m.put("status", u.getStatus());
            m.put("lastLoginTime", u.getLastLoginTime());
            m.put("createTime", u.getCreateTime());
            adminList.add(m);
        }
        dto.setAdmins(adminList);
        return dto;
    }

    public Factory getFactoryByCode(String code) {
        LambdaQueryWrapper<Factory> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Factory::getCode, code);
        return factoryMapper.selectOne(wrapper);
    }

    @Transactional
    public Factory createFactory(Factory factory) {
        if (factory.getCode() == null || factory.getCode().isEmpty()) {
            throw new BusinessException(ResultCode.PARAM_INVALID, "水厂编码不能为空");
        }
        
        Factory existing = getFactoryByCode(factory.getCode());
        if (existing != null) {
            throw new BusinessException(ResultCode.DATA_EXISTS, "水厂编码已存在");
        }
        
        factory.setStatus("active");
        factory.setCreateTime(LocalDateTime.now());
        factory.setUpdateTime(LocalDateTime.now());
        factory.setDeleted(0);
        
        factoryMapper.insert(factory);
        return factory;
    }

    @Transactional
    public Factory updateFactory(Long id, Factory factory) {
        Factory existing = getFactoryById(id);
        
        if (factory.getName() != null) {
            existing.setName(factory.getName());
        }
        if (factory.getContact() != null) {
            existing.setContact(factory.getContact());
        }
        if (factory.getPhone() != null) {
            existing.setPhone(factory.getPhone());
        }
        if (factory.getAddress() != null) {
            existing.setAddress(factory.getAddress());
        }
        if (factory.getLat() != null) {
            existing.setLat(factory.getLat());
        }
        if (factory.getLng() != null) {
            existing.setLng(factory.getLng());
        }
        if (factory.getRemark() != null) {
            existing.setRemark(factory.getRemark());
        }
        
        existing.setUpdateTime(LocalDateTime.now());
        factoryMapper.updateById(existing);
        return existing;
    }

    @Transactional
    public void updateFactoryStatus(Long id, String status) {
        Factory factory = getFactoryById(id);
        factory.setStatus(status);
        factory.setUpdateTime(LocalDateTime.now());
        factoryMapper.updateById(factory);
    }

    @Transactional
    public void deleteFactory(Long id) {
        Factory factory = getFactoryById(id);
        factoryMapper.deleteById(id);
    }
}
