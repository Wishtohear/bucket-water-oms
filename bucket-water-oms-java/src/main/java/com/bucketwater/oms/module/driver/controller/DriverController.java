package com.bucketwater.oms.module.driver.controller;

import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.driver.dto.DriverCheckInRequest;
import com.bucketwater.oms.module.driver.dto.DriverDashboardDTO;
import com.bucketwater.oms.module.driver.dto.DriverInfoDTO;
import com.bucketwater.oms.module.driver.dto.BarrelRecordDTO;
import com.bucketwater.oms.module.driver.dto.DriverLocationUpdateRequest;
import com.bucketwater.oms.module.driver.dto.DriverStatusUpdateRequest;
import com.bucketwater.oms.module.driver.dto.RoutePlanningDTO;
import com.bucketwater.oms.module.driver.dto.StationSelectDTO;
import com.bucketwater.oms.module.driver.dto.WarehouseReturnRequest;
import com.bucketwater.oms.module.driver.entity.DriverReturn;
import com.bucketwater.oms.module.driver.service.DriverService;
import com.bucketwater.oms.module.order.dto.DeliveryRequest;
import com.bucketwater.oms.module.order.dto.OrderVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/drivers")
@Tag(name = "司机模块", description = "司机任务、路线规划、配送签收、回仓、位置管理")
public class DriverController {

    @Autowired
    private DriverService driverService;

    @GetMapping("/dashboard")
    @Operation(summary = "获取司机Dashboard", description = "获取司机专属的Dashboard数据，包括任务统计、订单、通知等")
    public Result<DriverDashboardDTO> getDashboard(
            @RequestHeader(value = "X-Driver-Id", required = false) @Parameter(description = "司机ID") String driverIdStr) {
        Long driverId = parseDriverId(driverIdStr);
        DriverDashboardDTO dashboard = driverService.getDashboard(driverId);
        return Result.ok(dashboard);
    }

    @GetMapping("/tasks")
    @Operation(summary = "获取待配送任务", description = "获取司机待配送订单列表")
    public Result<List<OrderVO>> getPendingTasks(
            @RequestHeader(value = "X-Driver-Id", required = false) @Parameter(description = "司机ID") String driverIdStr) {
        Long driverId = parseDriverId(driverIdStr);
        List<OrderVO> tasks = driverService.getPendingTasks(driverId);
        return Result.ok(tasks);
    }

    @GetMapping("/route-planning")
    @Operation(summary = "获取配送路线", description = "获取最优配送路线")
    public Result<RoutePlanningDTO> getRoutePlanning(
            @RequestHeader(value = "X-Driver-Id", required = false) @Parameter(description = "司机ID") String driverIdStr,
            @RequestParam @Parameter(description = "订单ID列表") List<String> orderIds) {
        Long driverId = parseDriverId(driverIdStr);
        RoutePlanningDTO route = driverService.planRoute(driverId, orderIds);
        return Result.ok(route);
    }

    @PostMapping("/{orderId}/start-delivery")
    @Operation(summary = "开始配送", description = "司机开始配送订单")
    public Result<OrderVO> startDelivery(
            @PathVariable @Parameter(description = "订单ID") Long orderId) {
        OrderVO order = driverService.startDelivery(orderId);
        return Result.ok(order);
    }

    @PostMapping("/{orderId}/deliver")
    @Operation(summary = "配送签收", description = "司机完成配送签收")
    public Result<OrderVO> deliverOrder(
            @PathVariable @Parameter(description = "订单ID") Long orderId,
            @Valid @RequestBody DeliveryRequest request) {
        OrderVO order = driverService.completeDelivery(orderId, request);
        return Result.ok(order);
    }

    @PostMapping("/warehouse-return")
    @Operation(summary = "中途回仓申请", description = "司机申请中途回仓交空桶或补货")
    public Result<DriverReturn> warehouseReturn(
            @RequestHeader(value = "X-Driver-Id", required = false) @Parameter(description = "司机ID") String driverIdStr,
            @Valid @RequestBody WarehouseReturnRequest request) {
        Long driverId = parseDriverId(driverIdStr);
        DriverReturn result = driverService.applyWarehouseReturn(driverId, request);
        return Result.ok(result);
    }

    @PostMapping("/location")
    @Operation(summary = "更新GPS位置", description = "司机实时更新GPS位置，用于轨迹追踪和状态同步")
    public Result<Map<String, Object>> updateLocation(
            @RequestHeader(value = "X-Driver-Id", required = false) @Parameter(description = "司机ID") String driverIdStr,
            @Valid @RequestBody DriverLocationUpdateRequest request) {
        Long driverId = parseDriverId(driverIdStr);
        Map<String, Object> result = driverService.updateLocation(driverId, request);
        return Result.ok(result);
    }

    @GetMapping("/location-history")
    @Operation(summary = "查询历史轨迹", description = "查询司机的历史配送轨迹")
    public Result<Map<String, Object>> getLocationHistory(
            @RequestHeader(value = "X-Driver-Id", required = false) @Parameter(description = "司机ID") String driverIdStr,
            @Parameter(description = "开始时间(格式: yyyy-MM-dd HH:mm:ss)") @RequestParam(required = false) String startTime,
            @Parameter(description = "结束时间(格式: yyyy-MM-dd HH:mm:ss)") @RequestParam(required = false) String endTime,
            @Parameter(description = "订单ID(可选)") @RequestParam(required = false) String orderId) {
        Long driverId = parseDriverId(driverIdStr);
        java.time.LocalDateTime start = startTime != null ? java.time.LocalDateTime.parse(startTime, java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")) : null;
        java.time.LocalDateTime end = endTime != null ? java.time.LocalDateTime.parse(endTime, java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")) : null;
        Map<String, Object> result = driverService.getLocationHistory(driverId, start, end, orderId);
        return Result.ok(result);
    }

    @PostMapping("/status")
    @Operation(summary = "更新在线状态", description = "司机更新在线/离线/休息状态")
    public Result<Map<String, Object>> updateOnlineStatus(
            @RequestHeader(value = "X-Driver-Id", required = false) @Parameter(description = "司机ID") String driverIdStr,
            @Valid @RequestBody DriverStatusUpdateRequest request) {
        Long driverId = parseDriverId(driverIdStr);
        Map<String, Object> result = driverService.updateOnlineStatus(driverId, request);
        return Result.ok(result);
    }

    @PostMapping("/online")
    @Operation(summary = "司机上线", description = "司机一键上线，开始接收配送任务")
    public Result<Map<String, Object>> goOnline(
            @RequestHeader(value = "X-Driver-Id", required = false) @Parameter(description = "司机ID") String driverIdStr) {
        Long driverId = parseDriverId(driverIdStr);
        Map<String, Object> result = driverService.goOnline(driverId);
        return Result.ok(result);
    }

    @PostMapping("/offline")
    @Operation(summary = "司机下线", description = "司机一键下线，停止接收配送任务")
    public Result<Map<String, Object>> goOffline(
            @RequestHeader(value = "X-Driver-Id", required = false) @Parameter(description = "司机ID") String driverIdStr) {
        Long driverId = parseDriverId(driverIdStr);
        Map<String, Object> result = driverService.goOffline(driverId);
        return Result.ok(result);
    }

    @PostMapping("/break")
    @Operation(summary = "司机休息", description = "司机开始休息，暂停接收配送任务")
    public Result<Map<String, Object>> goOnBreak(
            @RequestHeader(value = "X-Driver-Id", required = false) @Parameter(description = "司机ID") String driverIdStr) {
        Long driverId = parseDriverId(driverIdStr);
        Map<String, Object> result = driverService.goOnBreak(driverId);
        return Result.ok(result);
    }

    @PostMapping("/check-in")
    @Operation(summary = "到达打卡", description = "司机到达水站后GPS定位打卡")
    public Result<Map<String, Object>> checkIn(
            @RequestHeader(value = "X-Driver-Id", required = false) @Parameter(description = "司机ID") String driverIdStr,
            @Valid @RequestBody DriverCheckInRequest request) {
        Long driverId = parseDriverId(driverIdStr);
        Map<String, Object> result = driverService.checkIn(driverId, request);
        return Result.ok(result);
    }

    @GetMapping("/status")
    @Operation(summary = "获取司机状态", description = "获取当前司机的在线状态和位置信息")
    public Result<Map<String, Object>> getDriverStatus(
            @RequestHeader(value = "X-Driver-Id", required = false) @Parameter(description = "司机ID") String driverIdStr) {
        Long driverId = parseDriverId(driverIdStr);
        Map<String, Object> status = driverService.getDriverStatus(driverId);
        return Result.ok(status);
    }

    @GetMapping("/info")
    @Operation(summary = "获取司机信息", description = "获取当前司机的详细信息，包括个人信息、统计数据等")
    public Result<DriverInfoDTO> getDriverInfo(
            @RequestHeader(value = "X-Driver-Id", required = false) @Parameter(description = "司机ID") String driverIdStr) {
        Long driverId = parseDriverId(driverIdStr);
        DriverInfoDTO info = driverService.getDriverInfo(driverId);
        return Result.ok(info);
    }

    @GetMapping("/stations")
    @Operation(summary = "获取可派送的水站列表", description = "获取所有可进行新水站派送的水站列表，用于回仓时选择新水站派送")
    public Result<List<StationSelectDTO>> getStationsForDelivery(
            @RequestHeader(value = "X-Driver-Id", required = false) @Parameter(description = "司机ID") String driverIdStr) {
        Long driverId = parseDriverId(driverIdStr);
        List<StationSelectDTO> stations = driverService.getStationsForDelivery(driverId);
        return Result.ok(stations);
    }

    @GetMapping("/barrel-records")
    @Operation(summary = "获取空桶记录", description = "获取司机的空桶流水记录，包括回桶、领桶、欠桶等")
    public Result<List<BarrelRecordDTO>> getBarrelRecords(
            @RequestHeader(value = "X-Driver-Id", required = false) @Parameter(description = "司机ID") String driverIdStr,
            @RequestParam(required = false) @Parameter(description = "记录类型: return/pickup/owed") String type) {
        Long driverId = parseDriverId(driverIdStr);
        List<BarrelRecordDTO> records = driverService.getBarrelRecords(driverId, type);
        return Result.ok(records);
    }

    private Long parseDriverId(String driverIdStr) {
        if (driverIdStr == null || driverIdStr.trim().isEmpty()) {
            throw new BusinessException(ResultCode.PARAM_MISSING, "缺少司机ID参数（X-Driver-Id header）");
        }
        try {
            return Long.parseLong(driverIdStr.trim());
        } catch (NumberFormatException e) {
            throw new BusinessException(ResultCode.PARAM_INVALID, "无效的司机ID格式: " + driverIdStr);
        }
    }
}
