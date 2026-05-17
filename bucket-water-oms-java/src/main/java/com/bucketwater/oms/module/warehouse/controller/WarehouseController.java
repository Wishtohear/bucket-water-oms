package com.bucketwater.oms.module.warehouse.controller;

import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.driver.entity.Driver;
import com.bucketwater.oms.module.driver.entity.DriverReturn;
import com.bucketwater.oms.module.driver.mapper.DriverMapper;
import com.bucketwater.oms.module.driver.mapper.DriverReturnMapper;
import com.bucketwater.oms.module.notification.entity.Notification;
import com.bucketwater.oms.module.notification.mapper.NotificationMapper;
import com.bucketwater.oms.module.order.dto.OrderVO;
import com.bucketwater.oms.module.bucket.entity.BucketTransaction;
import com.bucketwater.oms.module.bucket.mapper.BucketTransactionMapper;
import com.bucketwater.oms.module.order.entity.Order;
import com.bucketwater.oms.module.order.entity.OrderItem;
import com.bucketwater.oms.module.order.mapper.OrderItemMapper;
import com.bucketwater.oms.module.order.mapper.OrderMapper;
import com.bucketwater.oms.module.order.service.OrderService;
import com.bucketwater.oms.module.product.entity.ProductInventory;
import com.bucketwater.oms.module.product.mapper.ProductInventoryMapper;
import com.bucketwater.oms.module.user.entity.User;
import com.bucketwater.oms.module.user.mapper.UserMapper;
import com.bucketwater.oms.module.warehouse.dto.RecommendedDriverDTO;
import com.bucketwater.oms.module.warehouse.dto.WarehouseDashboardDTO;
import com.bucketwater.oms.module.warehouse.dto.WarehouseCalibrateRequest;
import com.bucketwater.oms.module.warehouse.dto.WarehouseInventoryDTO;
import com.bucketwater.oms.module.warehouse.dto.WarehouseReturnCheckRequest;
import com.bucketwater.oms.module.warehouse.entity.Warehouse;
import com.bucketwater.oms.module.warehouse.mapper.WarehouseMapper;
import com.bucketwater.oms.module.warehouse.service.WarehouseService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


@RestController
@RequestMapping("/warehouses")
@Tag(name = "仓库模块", description = "仓库接单，回仓核对、库存管理")
public class WarehouseController {

    @Autowired
    private WarehouseService warehouseService;

    @Autowired
    private OrderService orderService;

    @Autowired
    private DriverReturnMapper driverReturnMapper;

    @Autowired
    private DriverMapper driverMapper;

    @Autowired
    private ProductInventoryMapper productInventoryMapper;

    @Autowired
    private WarehouseMapper warehouseMapper;

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private NotificationMapper notificationMapper;

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private OrderItemMapper orderItemMapper;

    @Autowired
    private BucketTransactionMapper bucketTransactionMapper;

    @GetMapping("/dashboard")
    @Operation(summary = "获取仓库Dashboard", description = "获取仓库专属的Dashboard数据，包括库存统计、任务、通知等")
    public Result<WarehouseDashboardDTO> getDashboard(
            @RequestHeader("X-Warehouse-Id") @Parameter(description = "仓库ID") Long warehouseId) {
        WarehouseDashboardDTO dashboard = warehouseService.getDashboard(warehouseId);
        return Result.ok(dashboard);
    }

    @GetMapping("/orders")
    @Operation(summary = "获取待处理订单", description = "获取仓库待接单订单列表")
    public Result<List<OrderVO>> getPendingOrders(
            @RequestHeader("X-Warehouse-Id") @Parameter(description = "仓库ID") Long warehouseId,
            @RequestParam(required = false, defaultValue = "time") @Parameter(description = "排序方式: distance/time") String sortBy) {
        List<OrderVO> orders = warehouseService.getPendingOrders(warehouseId, sortBy);
        return Result.ok(orders);
    }

    @GetMapping("/returns")
    @Operation(summary = "获取司机回仓列表", description = "获取待核对回仓申请列表")
    public Result<List<DriverReturn>> getPendingReturns(
            @RequestHeader("X-Warehouse-Id") @Parameter(description = "仓库ID") Long warehouseId) {
        List<DriverReturn> returns = warehouseService.getPendingReturns(warehouseId);
        return Result.ok(returns);
    }

    @GetMapping("/returns/{returnId}")
    @Operation(summary = "获取回仓详情", description = "获取回仓核对详细信息")
    public Result<Map<String, Object>> getReturnDetail(
            @PathVariable @Parameter(description = "回仓ID") Long returnId) {
        DriverReturn driverReturn = driverReturnMapper.selectById(returnId);
        if (driverReturn == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "回仓记录不存在");
        }

        Map<String, Object> result = new HashMap<>();
        result.put("id", driverReturn.getId());
        result.put("driverId", driverReturn.getDriverId());
        result.put("warehouseId", driverReturn.getWarehouseId());
        result.put("bucketReturned", driverReturn.getBucketReturned());
        result.put("actualBucketQty", driverReturn.getActualBucketQty());
        result.put("difference", driverReturn.getDifference());
        result.put("differenceReason", driverReturn.getDifferenceReason());
        result.put("status", driverReturn.getStatus());
        result.put("replenishment", driverReturn.getReplenishment());
        result.put("createTime", driverReturn.getCreatedAt());
        result.put("checkedAt", driverReturn.getCheckedAt());

        Driver driver = driverMapper.selectById(driverReturn.getDriverId());
        if (driver != null) {
            result.put("driverName", driver.getName());
            result.put("driverCode", driver.getCode());
        }

        return Result.ok(result);
    }

    @PostMapping("/returns/{returnId}/check")
    @Operation(summary = "空桶核对确认", description = "仓库核对司机回仓数量")
    public Result<DriverReturn> checkReturn(
            @PathVariable @Parameter(description = "回仓ID") Long returnId,
            @Valid @RequestBody WarehouseReturnCheckRequest request) {
        DriverReturn result = warehouseService.checkReturn(returnId, request);
        return Result.ok(result);
    }

    @PostMapping("/returns/{returnId}/confirm")
    @Operation(summary = "确认回仓", description = "仓库确认回仓核对完成")
    public Result<DriverReturn> confirmReturn(
            @PathVariable @Parameter(description = "回仓ID") Long returnId,
            @RequestBody Map<String, Object> request) {
        DriverReturn driverReturn = driverReturnMapper.selectById(returnId);
        if (driverReturn == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "回仓记录不存在");
        }

        Integer actualBuckets = request.get("actualBuckets") != null
            ? ((Number) request.get("actualBuckets")).intValue()
            : driverReturn.getBucketReturned();
        String remark = request.get("remark") != null
            ? (String) request.get("remark")
            : driverReturn.getDifferenceReason();

        int reportedQty = driverReturn.getBucketReturned() != null ? driverReturn.getBucketReturned() : 0;
        int actualQty = actualBuckets != null ? actualBuckets : 0;
        int difference = reportedQty - actualQty;

        driverReturn.setActualBucketQty(actualQty);
        driverReturn.setDifference(difference);
        driverReturn.setDifferenceReason(remark);
        driverReturn.setStatus("checked");
        driverReturn.setCheckedAt(LocalDateTime.now());
        driverReturnMapper.updateById(driverReturn);

        Driver driver = driverMapper.selectById(driverReturn.getDriverId());
        if (driver != null) {
            int currentOwed = driver.getOwedBuckets() != null ? driver.getOwedBuckets() : 0;
            int currentBucketOnWay = driver.getBucketOnWay() != null ? driver.getBucketOnWay() : 0;

            if (difference > 0) {
                currentOwed += Math.abs(difference);
                driver.setOwedBuckets(currentOwed);
            }

            currentBucketOnWay = Math.max(0, currentBucketOnWay - actualQty);
            driver.setBucketOnWay(currentBucketOnWay);
            driverMapper.updateById(driver);

            BucketTransaction tx = new BucketTransaction();
            tx.setDriverId(driver.getId());
            tx.setWarehouseId(driverReturn.getWarehouseId());
            tx.setType("return");
            tx.setQuantity(actualQty);
            tx.setBalance(currentBucketOnWay);
            tx.setRemark("仓库回仓确认: " + (remark != null ? remark : "核对完成"));
            tx.setCreatedAt(LocalDateTime.now());
            bucketTransactionMapper.insert(tx);

            if (difference != 0) {
                BucketTransaction owedTx = new BucketTransaction();
                owedTx.setDriverId(driver.getId());
                owedTx.setWarehouseId(driverReturn.getWarehouseId());
                owedTx.setType("owed");
                owedTx.setQuantity(-Math.abs(difference));
                owedTx.setBalance(currentOwed);
                owedTx.setRemark("回仓差异: 欠桶 " + Math.abs(difference) + " 个");
                owedTx.setCreatedAt(LocalDateTime.now());
                bucketTransactionMapper.insert(owedTx);
            }
        }

        ProductInventory inventory = productInventoryMapper.selectOne(
            new LambdaQueryWrapper<ProductInventory>()
                .eq(ProductInventory::getWarehouseId, driverReturn.getWarehouseId())
                .last("ORDER BY id LIMIT 1")
        );
        if (inventory != null) {
            inventory.setQuantity(inventory.getQuantity() + actualQty);
            inventory.setUpdatedAt(LocalDateTime.now());
            productInventoryMapper.updateById(inventory);
        }

        return Result.ok(driverReturn);
    }

    @PostMapping("/returns/{returnId}/discrepancy")
    @Operation(summary = "记录差异", description = "记录回仓核对差异")
    public Result<DriverReturn> recordDiscrepancy(
            @PathVariable @Parameter(description = "回仓ID") Long returnId,
            @RequestBody Map<String, Object> request) {
        DriverReturn driverReturn = driverReturnMapper.selectById(returnId);
        if (driverReturn == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "回仓记录不存在");
        }

        Integer actualBuckets = request.get("actualBuckets") != null
            ? ((Number) request.get("actualBuckets")).intValue()
            : driverReturn.getBucketReturned();
        String remark = request.get("remark") != null
            ? (String) request.get("remark")
            : driverReturn.getDifferenceReason();

        int reportedQty = driverReturn.getBucketReturned() != null ? driverReturn.getBucketReturned() : 0;
        int actualQty = actualBuckets != null ? actualBuckets : 0;
        int difference = reportedQty - actualQty;

        driverReturn.setActualBucketQty(actualQty);
        driverReturn.setDifference(difference);
        driverReturn.setDifferenceReason(remark);
        driverReturn.setStatus("discrepancy");
        driverReturn.setCheckedAt(LocalDateTime.now());
        driverReturnMapper.updateById(driverReturn);

        if (difference > 0) {
            Driver driver = driverMapper.selectById(driverReturn.getDriverId());
            if (driver != null) {
                int currentOwed = driver.getOwedBuckets() != null ? driver.getOwedBuckets() : 0;
                driver.setOwedBuckets(currentOwed + Math.abs(difference));
                driverMapper.updateById(driver);
            }
        }

        return Result.ok(driverReturn);
    }

    @GetMapping("/inventory")
    @Operation(summary = "获取仓库库存", description = "获取仓库商品库存")
    public Result<List<WarehouseInventoryDTO>> getInventory(
            @RequestHeader("X-Warehouse-Id") @Parameter(description = "仓库ID") Long warehouseId) {
        List<WarehouseInventoryDTO> inventory = warehouseService.getInventory(warehouseId);
        return Result.ok(inventory);
    }

    @PutMapping("/inventory/{inventoryId}/calibrate")
    @Operation(summary = "校准库存", description = "校准指定商品的库存数量")
    public Result<Void> calibrateInventory(
            @RequestHeader("X-Warehouse-Id") @Parameter(description = "仓库ID") Long warehouseId,
            @PathVariable @Parameter(description = "库存ID") Long inventoryId,
            @RequestBody @Parameter(description = "校准请求") WarehouseCalibrateRequest request) {
        warehouseService.calibrateInventory(warehouseId, inventoryId, request.getQuantity(), request.getReason());
        return Result.ok();
    }

    @GetMapping("/drivers")
    @Operation(summary = "获取可用司机列表", description = "获取仓库可用的司机列表，用于派单")
    public Result<List<Driver>> getAvailableDrivers(
            @RequestHeader("X-Warehouse-Id") @Parameter(description = "仓库ID") Long warehouseId) {
        List<Driver> drivers = warehouseService.getAvailableDrivers(warehouseId);
        return Result.ok(drivers);
    }

    @GetMapping("/drivers/recommend")
    @Operation(summary = "获取推荐司机列表", description = "根据距离、任务数、在线状态智能推荐最适合的司机")
    public Result<List<Driver>> getRecommendedDrivers(
            @RequestHeader("X-Warehouse-Id") @Parameter(description = "仓库ID") Long warehouseId,
            @RequestParam(required = false) @Parameter(description = "订单ID，用于计算水站距离") Long orderId) {
        List<Driver> drivers = warehouseService.getRecommendedDrivers(warehouseId, orderId);
        return Result.ok(drivers);
    }

    @GetMapping("/drivers/recommend/details")
    @Operation(summary = "获取推荐司机详情列表", description = "获取详细的推荐司机信息，包括推荐原因、距离、评分等，绑定当前仓库的司机靠前显示")
    public Result<List<RecommendedDriverDTO>> getRecommendedDriversWithDetails(
            @RequestHeader("X-Warehouse-Id") @Parameter(description = "仓库ID") Long warehouseId,
            @RequestParam(required = false) @Parameter(description = "订单ID，用于计算水站距离") Long orderId) {
        List<RecommendedDriverDTO> drivers = warehouseService.getRecommendedDriversWithDetails(warehouseId, orderId);
        return Result.ok(drivers);
    }

    @GetMapping("/drivers/all")
    @Operation(summary = "获取所有可用司机", description = "获取平台所有可用司机列表，绑定当前仓库的司机靠前显示")
    public Result<List<RecommendedDriverDTO>> getAllAvailableDrivers(
            @RequestHeader("X-Warehouse-Id") @Parameter(description = "仓库ID") Long warehouseId) {
        List<RecommendedDriverDTO> drivers = warehouseService.getAllAvailableDrivers(warehouseId);
        return Result.ok(drivers);
    }

    @GetMapping("/orders/all")
    @Operation(summary = "获取所有订单", description = "获取仓库所有订单列表，支持状态筛选")
    public Result<List<OrderVO>> getAllOrders(
            @RequestHeader("X-Warehouse-Id") @Parameter(description = "仓库ID") Long warehouseId,
            @RequestParam(required = false) @Parameter(description = "订单状态") String status,
            @RequestParam(defaultValue = "1") @Parameter(description = "页码") Integer page,
            @RequestParam(defaultValue = "20") @Parameter(description = "每页数量") Integer size) {
        List<OrderVO> orders = warehouseService.getAllOrders(warehouseId, status, page, size);
        return Result.ok(orders);
    }

    @GetMapping("/orders/preparing")
    @Operation(summary = "获取备货订单列表", description = "获取仓库备货中的订单列表，包含商品明细和备货进度")
    public Result<List<OrderVO>> getPreparingOrders(
            @RequestHeader("X-Warehouse-Id") @Parameter(description = "仓库ID") Long warehouseId,
            @RequestParam(required = false) @Parameter(description = "订单状态: preparing/prepared/dispatched") String status,
            @RequestParam(defaultValue = "1") @Parameter(description = "页码") Integer page,
            @RequestParam(defaultValue = "20") @Parameter(description = "每页数量") Integer size) {
        List<OrderVO> orders = orderService.getPreparingOrders(warehouseId, status, page, size);
        return Result.ok(orders);
    }

    @GetMapping("/drivers/list")
    @Operation(summary = "获取仓库司机列表", description = "获取仓库所有司机的详细信息")
    public Result<List<Driver>> getDriverList(
            @RequestHeader("X-Warehouse-Id") @Parameter(description = "仓库ID") Long warehouseId) {
        List<Driver> drivers = warehouseService.getDriverList(warehouseId);
        return Result.ok(drivers);
    }

    @GetMapping("/info")
    @Operation(summary = "获取仓库信息", description = "获取当前登录仓库账号的仓库信息")
    public Result<Map<String, Object>> getWarehouseInfo(
            @RequestHeader("X-Warehouse-Id") @Parameter(description = "仓库ID") Long warehouseId) {
        Warehouse warehouse = warehouseMapper.selectById(warehouseId);
        if (warehouse == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "仓库不存在");
        }

        Map<String, Object> result = new HashMap<>();
        result.put("id", warehouse.getId());
        result.put("name", warehouse.getName());
        result.put("address", warehouse.getAddress());
        result.put("contact", warehouse.getContact());
        result.put("contactPhone", warehouse.getContactPhone());
        result.put("type", warehouse.getType());
        result.put("coverageArea", warehouse.getCoverageArea());
        result.put("lat", warehouse.getLat());
        result.put("lng", warehouse.getLng());
        result.put("status", warehouse.getStatus());
        result.put("createTime", warehouse.getCreateTime());

        return Result.ok(result);
    }

    @PutMapping("/info")
    @Operation(summary = "更新仓库信息", description = "更新当前登录仓库账号的仓库信息")
    public Result<Warehouse> updateWarehouseInfo(
            @RequestHeader("X-Warehouse-Id") @Parameter(description = "仓库ID") Long warehouseId,
            @RequestBody Map<String, Object> request) {
        Warehouse warehouse = warehouseMapper.selectById(warehouseId);
        if (warehouse == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "仓库不存在");
        }

        if (request.get("name") != null) {
            warehouse.setName((String) request.get("name"));
        }
        if (request.get("address") != null) {
            warehouse.setAddress((String) request.get("address"));
        }
        if (request.get("contact") != null) {
            warehouse.setContact((String) request.get("contact"));
        }
        if (request.get("contactPhone") != null) {
            warehouse.setContactPhone((String) request.get("contactPhone"));
        }
        if (request.get("coverageArea") != null) {
            warehouse.setCoverageArea((String) request.get("coverageArea"));
        }

        warehouse.setUpdateTime(LocalDateTime.now());
        warehouseMapper.updateById(warehouse);

        return Result.ok(warehouse);
    }

    @GetMapping("/profile")
    @Operation(summary = "获取个人信息", description = "获取当前登录仓库账号的个人信息")
    public Result<Map<String, Object>> getProfile(
            @RequestHeader(value = "X-User-Id", required = false) Long userId,
            @RequestHeader(value = "X-Warehouse-Id", required = false) Long warehouseId) {
        User user = null;
        
        if (userId != null) {
            user = userMapper.selectById(userId);
        } else if (warehouseId != null) {
            LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(User::getWarehouseId, warehouseId);
            wrapper.eq(User::getRole, "warehouse");
            wrapper.last("LIMIT 1");
            user = userMapper.selectOne(wrapper);
        }
        
        if (user == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "用户不存在");
        }

        Map<String, Object> result = new HashMap<>();
        result.put("id", user.getId());
        result.put("name", user.getName());
        result.put("phone", user.getPhone());
        result.put("role", user.getRole());
        result.put("status", user.getStatus());

        if (user.getWarehouseId() != null) {
            Warehouse warehouse = warehouseMapper.selectById(user.getWarehouseId());
            if (warehouse != null) {
                result.put("warehouseId", warehouse.getId());
                result.put("warehouseName", warehouse.getName());
            }
        }

        return Result.ok(result);
    }

    @PutMapping("/profile")
    @Operation(summary = "更新个人信息", description = "更新当前登录仓库账号的个人信息")
    public Result<User> updateProfile(
            @RequestHeader(value = "X-User-Id", required = false) Long userId,
            @RequestHeader(value = "X-Warehouse-Id", required = false) Long warehouseId,
            @RequestBody Map<String, Object> request) {
        User user = null;
        
        if (userId != null) {
            user = userMapper.selectById(userId);
        } else if (warehouseId != null) {
            LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(User::getWarehouseId, warehouseId);
            wrapper.eq(User::getRole, "warehouse");
            wrapper.last("LIMIT 1");
            user = userMapper.selectOne(wrapper);
        }
        
        if (user == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "用户不存在");
        }

        if (request.get("name") != null) {
            user.setName((String) request.get("name"));
        }
        if (request.get("phone") != null) {
            user.setPhone((String) request.get("phone"));
        }

        user.setUpdateTime(LocalDateTime.now());
        userMapper.updateById(user);

        return Result.ok(user);
    }

    @PostMapping("/change-password")
    @Operation(summary = "修改密码", description = "修改当前仓库账号的登录密码")
    public Result<Void> changePassword(
            @RequestHeader(value = "X-User-Id", required = false) Long userId,
            @RequestHeader(value = "X-Warehouse-Id", required = false) Long warehouseId,
            @RequestBody Map<String, String> request) {
        User user = null;
        
        if (userId != null) {
            user = userMapper.selectById(userId);
        } else if (warehouseId != null) {
            LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(User::getWarehouseId, warehouseId);
            wrapper.eq(User::getRole, "warehouse");
            wrapper.last("LIMIT 1");
            user = userMapper.selectOne(wrapper);
        }
        
        if (user == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "用户不存在");
        }

        String oldPassword = request.get("oldPassword");
        String newPassword = request.get("newPassword");

        if (oldPassword == null || oldPassword.isEmpty()) {
            throw new BusinessException(ResultCode.PARAM_ERROR, "旧密码不能为空");
        }
        if (newPassword == null || newPassword.isEmpty()) {
            throw new BusinessException(ResultCode.PARAM_ERROR, "新密码不能为空");
        }
        if (newPassword.length() < 6) {
            throw new BusinessException(ResultCode.PARAM_ERROR, "新密码长度不能少于6位");
        }

        if (!oldPassword.equals(user.getPassword())) {
            throw new BusinessException(ResultCode.PARAM_ERROR, "旧密码错误");
        }

        user.setPassword(newPassword);
        user.setUpdateTime(LocalDateTime.now());
        userMapper.updateById(user);

        return Result.ok(null);
    }

    @GetMapping("/notification-settings")
    @Operation(summary = "获取通知设置", description = "获取当前仓库账号的通知设置")
    public Result<Map<String, Object>> getNotificationSettings(
            @RequestHeader("X-User-Id") @Parameter(description = "用户ID") Long userId) {
        Map<String, Object> settings = new HashMap<>();
        settings.put("newOrder", true);
        settings.put("lowStock", true);
        settings.put("driverReturn", true);
        return Result.ok(settings);
    }

    @PutMapping("/notification-settings")
    @Operation(summary = "更新通知设置", description = "更新当前仓库账号的通知设置")
    public Result<Map<String, Object>> updateNotificationSettings(
            @RequestHeader("X-User-Id") @Parameter(description = "用户ID") Long userId,
            @RequestBody Map<String, Boolean> settings) {
        Map<String, Object> result = new HashMap<>();
        result.put("newOrder", settings.getOrDefault("newOrder", true));
        result.put("lowStock", settings.getOrDefault("lowStock", true));
        result.put("driverReturn", settings.getOrDefault("driverReturn", true));
        return Result.ok(result);
    }
}
