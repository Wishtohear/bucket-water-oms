package com.bucketwater.oms.module.admin.service;

import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.admin.dto.WarehouseManagementDTO;
import com.bucketwater.oms.module.admin.dto.WarehouseStaffDTO;
import com.bucketwater.oms.module.warehouse.entity.Warehouse;
import com.bucketwater.oms.module.warehouse.mapper.WarehouseMapper;
import com.bucketwater.oms.module.user.entity.User;
import com.bucketwater.oms.module.user.mapper.UserMapper;
import com.bucketwater.oms.module.factory.entity.Factory;
import com.bucketwater.oms.module.factory.mapper.FactoryMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
public class AdminWarehouseService {

    @Autowired
    private WarehouseMapper warehouseMapper;

    @Autowired
    private UserMapper userMapper;

    @Autowired(required = false)
    private FactoryMapper factoryMapper;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public List<Warehouse> getAllWarehouses(String status) {
        return getAllWarehouses(status, null);
    }

    public List<Warehouse> getAllWarehouses(String status, Long factoryId) {
        var wrapper = new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Warehouse>();
        if (status != null && !status.isEmpty()) {
            wrapper.eq(Warehouse::getStatus, status);
        }
        if (factoryId != null) {
            wrapper.eq(Warehouse::getFactoryId, factoryId);
        }
        wrapper.orderByDesc(Warehouse::getCreateTime);
        List<Warehouse> warehouses = warehouseMapper.selectList(wrapper);
        
        for (Warehouse warehouse : warehouses) {
            if (warehouse.getPhone() == null || warehouse.getPhone().isEmpty()) {
                warehouse.setPhone(warehouse.getContactPhone());
            }
        }
        
        return warehouses;
    }

    public Warehouse getWarehouseById(Long warehouseId) {
        return getWarehouseById(warehouseId, null);
    }

    public Warehouse getWarehouseById(Long warehouseId, Long factoryId) {
        Warehouse warehouse = warehouseMapper.selectById(warehouseId);
        if (warehouse == null) {
            throw new BusinessException(ResultCode.WAREHOUSE_NOT_FOUND);
        }
        if (factoryId != null && !factoryId.equals(warehouse.getFactoryId())) {
            throw new BusinessException(ResultCode.FORBIDDEN, "无权访问该仓库");
        }
        if (warehouse.getPhone() == null || warehouse.getPhone().isEmpty()) {
            warehouse.setPhone(warehouse.getContactPhone());
        }
        return warehouse;
    }

    @Transactional
    public Warehouse createWarehouse(WarehouseManagementDTO request, String userPhone) {
        return createWarehouse(request, userPhone, null);
    }

    @Transactional
    public Warehouse createWarehouse(WarehouseManagementDTO request, String userPhone, Long factoryId) {
        User existingUser = userMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<User>()
                .eq(User::getPhone, userPhone)
        );
        if (existingUser != null) {
            throw new BusinessException(ResultCode.DATA_EXISTS);
        }

        Warehouse warehouse = new Warehouse();
        warehouse.setName(request.getName());
        warehouse.setAddress(request.getAddress());
        warehouse.setContact(request.getContact());
        warehouse.setContactPhone(request.getContactPhone());
        if (request.getPhone() != null) {
            warehouse.setPhone(request.getPhone());
        } else {
            warehouse.setPhone(request.getContactPhone());
        }
        warehouse.setLat(request.getLat());
        warehouse.setLng(request.getLng());
        warehouse.setCoverageArea(request.getCoverageArea());
        if (request.getType() != null) {
            warehouse.setType(request.getType());
        } else {
            warehouse.setType("branch");
        }
        if (request.getDefaultSafeStock() != null) {
            warehouse.setDefaultSafeStock(request.getDefaultSafeStock());
        } else {
            warehouse.setDefaultSafeStock(10);
        }
        if (request.getInventoryAlertEnabled() != null) {
            warehouse.setInventoryAlertEnabled(request.getInventoryAlertEnabled());
        } else {
            warehouse.setInventoryAlertEnabled(true);
        }
        if (request.getLowStockAlertPercent() != null) {
            warehouse.setLowStockAlertPercent(request.getLowStockAlertPercent());
        } else {
            warehouse.setLowStockAlertPercent(20);
        }
        if (request.getRemark() != null) {
            warehouse.setRemark(request.getRemark());
        }
        warehouse.setFactoryId(factoryId);
        warehouse.setStatus("active");
        warehouse.setCreateTime(LocalDateTime.now());
        warehouse.setUpdateTime(LocalDateTime.now());

        warehouseMapper.insert(warehouse);

        String rawPassword = (request.getPassword() != null && !request.getPassword().isEmpty())
            ? request.getPassword() : "123456";
        String encodedPassword = passwordEncoder.encode(rawPassword);

        User user = new User();
        user.setPhone(request.getContactPhone());
        user.setPassword(encodedPassword);
        user.setName(request.getName() + "管理员");
        user.setRole("warehouse");
        user.setWarehouseId(warehouse.getId());
        user.setStatus("active");
        user.setCreateTime(LocalDateTime.now());
        user.setUpdateTime(LocalDateTime.now());

        userMapper.insert(user);

        return warehouse;
    }

    @Transactional
    public Warehouse updateWarehouse(Long warehouseId, WarehouseManagementDTO request) {
        return updateWarehouse(warehouseId, request, null);
    }

    @Transactional
    public Warehouse updateWarehouse(Long warehouseId, WarehouseManagementDTO request, Long factoryId) {
        Warehouse warehouse = warehouseMapper.selectById(warehouseId);
        if (warehouse == null) {
            throw new BusinessException(ResultCode.WAREHOUSE_NOT_FOUND);
        }
        if (factoryId != null && !factoryId.equals(warehouse.getFactoryId())) {
            throw new BusinessException(ResultCode.FORBIDDEN, "无权修改该仓库");
        }

        if (request.getName() != null) {
            warehouse.setName(request.getName());
        }
        if (request.getAddress() != null) {
            warehouse.setAddress(request.getAddress());
        }
        if (request.getContact() != null) {
            warehouse.setContact(request.getContact());
        }
        if (request.getContactPhone() != null) {
            warehouse.setContactPhone(request.getContactPhone());
        }
        if (request.getPhone() != null) {
            warehouse.setPhone(request.getPhone());
        }
        if (request.getLat() != null) {
            warehouse.setLat(request.getLat());
        }
        if (request.getLng() != null) {
            warehouse.setLng(request.getLng());
        }
        if (request.getCoverageArea() != null) {
            warehouse.setCoverageArea(request.getCoverageArea());
        }
        if (request.getType() != null) {
            warehouse.setType(request.getType());
        }
        if (request.getDefaultSafeStock() != null) {
            warehouse.setDefaultSafeStock(request.getDefaultSafeStock());
        }
        if (request.getInventoryAlertEnabled() != null) {
            warehouse.setInventoryAlertEnabled(request.getInventoryAlertEnabled());
        }
        if (request.getLowStockAlertPercent() != null) {
            warehouse.setLowStockAlertPercent(request.getLowStockAlertPercent());
        }
        if (request.getRemark() != null) {
            warehouse.setRemark(request.getRemark());
        }

        warehouse.setUpdateTime(LocalDateTime.now());
        warehouseMapper.updateById(warehouse);

        User user = userMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<User>()
                .eq(User::getWarehouseId, warehouseId)
        );

        if (user != null) {
            if (request.getName() != null) {
                user.setName(request.getName() + "管理员");
            }
            if (request.getContactPhone() != null) {
                user.setPhone(request.getContactPhone());
            }
            if (request.getPassword() != null && !request.getPassword().isEmpty()) {
                user.setPassword(passwordEncoder.encode(request.getPassword()));
            }
            user.setUpdateTime(LocalDateTime.now());
            userMapper.updateById(user);
        }

        return warehouse;
    }

    @Transactional
    public void updateWarehouseStatus(Long warehouseId, String status) {
        updateWarehouseStatus(warehouseId, status, null);
    }

    @Transactional
    public void updateWarehouseStatus(Long warehouseId, String status, Long factoryId) {
        Warehouse warehouse = warehouseMapper.selectById(warehouseId);
        if (warehouse == null) {
            throw new BusinessException(ResultCode.WAREHOUSE_NOT_FOUND);
        }
        if (factoryId != null && !factoryId.equals(warehouse.getFactoryId())) {
            throw new BusinessException(ResultCode.FORBIDDEN, "无权修改该仓库状态");
        }

        warehouse.setStatus(status);
        warehouse.setUpdateTime(LocalDateTime.now());
        warehouseMapper.updateById(warehouse);

        userMapper.update(null,
            new com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper<User>()
                .eq(User::getWarehouseId, warehouseId)
                .set(User::getStatus, status)
        );
    }

    public List<WarehouseStaffDTO> getWarehouseStaffs(Long warehouseId) {
        return getWarehouseStaffs(warehouseId, null);
    }

    public List<WarehouseStaffDTO> getWarehouseStaffs(Long warehouseId, Long factoryId) {
        Warehouse warehouse = warehouseMapper.selectById(warehouseId);
        if (warehouse == null) {
            throw new BusinessException(ResultCode.WAREHOUSE_NOT_FOUND);
        }
        if (factoryId != null && !factoryId.equals(warehouse.getFactoryId())) {
            throw new BusinessException(ResultCode.FORBIDDEN, "无权访问该仓库员工");
        }

        List<WarehouseStaffDTO> result = new ArrayList<>();

        var wrapper = new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<User>();
        wrapper.eq(User::getWarehouseId, warehouseId);
        List<User> users = userMapper.selectList(wrapper);

        for (User user : users) {
            WarehouseStaffDTO dto = new WarehouseStaffDTO();
            dto.setId(String.valueOf(user.getId()));
            dto.setName(user.getName());
            dto.setRole(user.getRole() != null && user.getRole().equals("warehouse") ? "admin" : "staff");
            dto.setOnlineStatus(user.getStatus() != null && user.getStatus().equals("active") ? "online" : "offline");
            result.add(dto);
        }

        return result;
    }
}
