package com.bucketwater.oms.module.admin.controller;

import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.common.security.RequireRole;
import com.bucketwater.oms.common.security.UserContext;
import com.bucketwater.oms.module.admin.dto.DriverManagementDTO;
import com.bucketwater.oms.module.admin.dto.RecentOrderDTO;
import com.bucketwater.oms.module.admin.dto.StationAccountPolicyDTO;
import com.bucketwater.oms.module.admin.dto.StationDetailDTO;
import com.bucketwater.oms.module.admin.dto.StationManagementDTO;
import com.bucketwater.oms.module.admin.dto.StationStaffDTO;
import com.bucketwater.oms.module.admin.dto.WarehouseStaffDTO;
import com.bucketwater.oms.module.admin.dto.StationVO;
import com.bucketwater.oms.module.admin.dto.WarehouseManagementDTO;
import com.bucketwater.oms.module.admin.service.AdminDriverService;
import com.bucketwater.oms.module.admin.service.AdminStationService;
import com.bucketwater.oms.module.admin.service.AdminWarehouseService;
import com.bucketwater.oms.module.driver.entity.Driver;
import com.bucketwater.oms.module.station.entity.Station;
import com.bucketwater.oms.module.station.entity.StationAccount;
import com.bucketwater.oms.module.user.entity.User;
import com.bucketwater.oms.module.warehouse.entity.Warehouse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;


@RestController
@RequestMapping("/admin")
@Tag(name = "管理端", description = "水厂管理员后台管理")
@RequireRole({"PLATFORM_ADMIN", "FACTORY_ADMIN"})
public class AdminController {

    @Autowired
    private AdminStationService adminStationService;

    @Autowired
    private AdminDriverService adminDriverService;

    @Autowired
    private AdminWarehouseService adminWarehouseService;

    @GetMapping("/stations")
    @Operation(summary = "获取水站列表", description = "获取所有水站列表，支持数据隔离")
    public Result<List<StationVO>> getAllStations(
            HttpServletRequest request,
            @RequestParam(required = false) @Parameter(description = "状态") String status) {
        Optional<User> currentUser = com.bucketwater.oms.common.security.JwtAuthenticationFilter.getCurrentUser(request);
        Long factoryId = currentUser.map(UserContext::getFactoryId).orElse(null);
        List<StationVO> stations = adminStationService.getAllStations(status, factoryId);
        return Result.ok(stations);
    }

    @GetMapping("/stations/{stationId}")
    @Operation(summary = "获取水站详情", description = "获取水站详细信息")
    public Result<Station> getStation(
            @PathVariable @Parameter(description = "水站ID") Long stationId) {
        Station station = adminStationService.getStationById(stationId);
        return Result.ok(station);
    }

    @GetMapping("/stations/{stationId}/detail")
    @Operation(summary = "获取水站完整详情", description = "获取水站完整详情，包含账户、定价、员工、最近订单等")
    public Result<StationDetailDTO> getStationDetail(
            @PathVariable @Parameter(description = "水站ID") Long stationId) {
        StationDetailDTO detail = adminStationService.getStationDetail(stationId);
        return Result.ok(detail);
    }

    @GetMapping("/stations/{stationId}/account")
    @Operation(summary = "获取水站账户", description = "获取水站账户信息")
    public Result<StationAccount> getStationAccount(
            @PathVariable @Parameter(description = "水站ID") Long stationId) {
        StationAccount account = adminStationService.getStationAccount(stationId);
        return Result.ok(account);
    }

    @GetMapping("/stations/{stationId}/staffs")
    @Operation(summary = "获取水站员工", description = "获取水站员工账号列表")
    public Result<List<StationStaffDTO>> getStationStaffs(
            @PathVariable @Parameter(description = "水站ID") Long stationId) {
        StationDetailDTO detail = adminStationService.getStationDetail(stationId);
        return Result.ok(detail.getStaffs());
    }

    @PostMapping("/stations/{stationId}/staffs")
    @Operation(summary = "创建店员账号", description = "为水站创建店员账号")
    public Result<Void> createStationStaff(
            @PathVariable @Parameter(description = "水站ID") Long stationId,
            @RequestBody StationStaffDTO staff) {
        adminStationService.createStaff(stationId, staff);
        return Result.ok();
    }

    @PutMapping("/stations/{stationId}/staffs/{staffId}")
    @Operation(summary = "更新店员账号", description = "更新店员信息")
    public Result<Void> updateStationStaff(
            @PathVariable @Parameter(description = "店员ID") Long staffId,
            @RequestBody StationStaffDTO staff) {
        adminStationService.updateStaff(staffId, staff);
        return Result.ok();
    }

    @DeleteMapping("/stations/{stationId}/staffs/{staffId}")
    @Operation(summary = "删除店员账号", description = "删除店员账号")
    public Result<Void> deleteStationStaff(
            @PathVariable @Parameter(description = "店员ID") Long staffId) {
        adminStationService.deleteStaff(staffId);
        return Result.ok();
    }

    @PostMapping("/stations/{stationId}/staffs/{staffId}/reset-password")
    @Operation(summary = "重置店员密码", description = "重置店员密码为123456")
    public Result<Void> resetStationStaffPassword(
            @PathVariable @Parameter(description = "店员ID") Long staffId) {
        adminStationService.resetStaffPassword(staffId);
        return Result.ok();
    }

    @GetMapping("/stations/{stationId}/orders")
    @Operation(summary = "获取水站订单", description = "获取水站最近订单列表")
    public Result<List<RecentOrderDTO>> getStationOrders(
            @PathVariable @Parameter(description = "水站ID") Long stationId,
            @RequestParam(defaultValue = "10") @Parameter(description = "数量限制") Integer limit) {
        List<RecentOrderDTO> orders = adminStationService.getStationOrders(stationId, limit);
        return Result.ok(orders);
    }

    @PostMapping("/stations")
    @Operation(summary = "创建水站", description = "创建新水站账号")
    public Result<Station> createStation(
            @Valid @RequestBody StationManagementDTO request) {
        Station station = adminStationService.createStation(request, request.getPhone());
        return Result.ok(station);
    }

    @PutMapping("/stations/{stationId}")
    @Operation(summary = "更新水站", description = "更新水站信息")
    public Result<Station> updateStation(
            @PathVariable @Parameter(description = "水站ID") Long stationId,
            @Valid @RequestBody StationManagementDTO request) {
        Station station = adminStationService.updateStation(stationId, request);
        return Result.ok(station);
    }

    @PutMapping("/stations/{stationId}/status")
    @Operation(summary = "更新水站状态", description = "启用/停用水站")
    public Result<Void> updateStationStatus(
            @PathVariable @Parameter(description = "水站ID") Long stationId,
            @RequestParam @Parameter(description = "状态") String status) {
        adminStationService.updateStationStatus(stationId, status);
        return Result.ok();
    }

    @PutMapping("/stations/policy")
    @Operation(summary = "更新销售政策", description = "更新水站销售政策配置")
    public Result<Void> updateStationPolicy(
            @Valid @RequestBody StationAccountPolicyDTO request) {
        adminStationService.updateStationPolicy(request);
        return Result.ok();
    }

    @PostMapping("/stations/{stationId}/policy")
    @Operation(summary = "分配销售政策", description = "为水站分配销售政策模板")
    public Result<Void> assignStationPolicy(
            @PathVariable @Parameter(description = "水站ID") Long stationId,
            @RequestParam @Parameter(description = "政策模板ID") Long policyId) {
        adminStationService.assignStationPolicy(stationId, policyId);
        return Result.ok();
    }

    @PutMapping("/stations/{stationId}/location")
    @Operation(summary = "更新水站位置", description = "更新水站GPS坐标和地址信息，用于定位和导航")
    public Result<Station> updateStationLocation(
            @PathVariable @Parameter(description = "水站ID") Long stationId,
            @RequestParam @Parameter(description = "纬度") java.math.BigDecimal latitude,
            @RequestParam @Parameter(description = "经度") java.math.BigDecimal longitude,
            @RequestParam(required = false) @Parameter(description = "地址") String address) {
        Station station = adminStationService.updateStationLocation(stationId, latitude, longitude, address);
        return Result.ok(station);
    }

    @GetMapping("/drivers")
    @Operation(summary = "获取司机列表", description = "获取所有司机列表")
    public Result<List<Driver>> getAllDrivers(
            @RequestParam(required = false) @Parameter(description = "状态") String status) {
        List<Driver> drivers = adminDriverService.getAllDrivers(status);
        return Result.ok(drivers);
    }

    @GetMapping("/drivers/{driverId}")
    @Operation(summary = "获取司机详情", description = "获取司机详细信息")
    public Result<Driver> getDriver(
            @PathVariable @Parameter(description = "司机ID") Long driverId) {
        Driver driver = adminDriverService.getDriverById(driverId);
        return Result.ok(driver);
    }

    @PostMapping("/drivers")
    @Operation(summary = "创建司机", description = "创建新司机账号")
    public Result<Driver> createDriver(
            @Valid @RequestBody DriverManagementDTO request) {
        Driver driver = adminDriverService.createDriver(request, request.getPhone());
        return Result.ok(driver);
    }

    @PutMapping("/drivers/{driverId}")
    @Operation(summary = "更新司机", description = "更新司机信息")
    public Result<Driver> updateDriver(
            @PathVariable @Parameter(description = "司机ID") Long driverId,
            @Valid @RequestBody DriverManagementDTO request) {
        Driver driver = adminDriverService.updateDriver(driverId, request);
        return Result.ok(driver);
    }

    @PutMapping("/drivers/{driverId}/status")
    @Operation(summary = "更新司机状态", description = "启用/停用司机")
    public Result<Void> updateDriverStatus(
            @PathVariable @Parameter(description = "司机ID") Long driverId,
            @RequestParam @Parameter(description = "状态") String status) {
        adminDriverService.updateDriverStatus(driverId, status);
        return Result.ok();
    }

    @PostMapping("/drivers/{driverId}/reset-password")
    @Operation(summary = "重置密码", description = "重置司机密码为123456")
    public Result<Void> resetDriverPassword(
            @PathVariable @Parameter(description = "司机ID") Long driverId) {
        adminDriverService.resetDriverPassword(driverId);
        return Result.ok();
    }

    @GetMapping("/drivers/stats")
    @Operation(summary = "获取司机统计", description = "获取司机统计数据")
    public Result<?> getDriverStats() {
        return Result.ok(adminDriverService.getDriverStats());
    }

    @GetMapping("/drivers/delivery-report")
    @Operation(summary = "获取司机配送报表", description = "获取司机配送统计报表")
    public Result<?> getDeliveryReport(
            @RequestParam(required = false) @Parameter(description = "开始日期") String startDate,
            @RequestParam(required = false) @Parameter(description = "结束日期") String endDate,
            @RequestParam(required = false) @Parameter(description = "司机ID") Long driverId) {
        return Result.ok(adminDriverService.getDeliveryReport(startDate, endDate, driverId));
    }

    @GetMapping("/drivers/in-transit-buckets")
    @Operation(summary = "获取在途空桶", description = "获取司机在途空桶数量")
    public Result<?> getInTransitBuckets() {
        return Result.ok(adminDriverService.getInTransitBuckets());
    }

    @GetMapping("/drivers/export")
    @Operation(summary = "导出司机列表", description = "导出司机数据为Excel")
    public Result<Void> exportDrivers(
            @RequestParam(required = false) @Parameter(description = "状态") String status,
            @RequestParam(required = false) @Parameter(description = "仓库ID") Long warehouseId) {
        return Result.ok();
    }

    @GetMapping("/drivers/delivery-report/export")
    @Operation(summary = "导出配送报表", description = "导出司机配送报表为Excel")
    public Result<Void> exportDeliveryReport(
            @RequestParam(required = false) @Parameter(description = "开始日期") String startDate,
            @RequestParam(required = false) @Parameter(description = "结束日期") String endDate,
            @RequestParam(required = false) @Parameter(description = "司机ID") Long driverId) {
        return Result.ok();
    }

    @GetMapping("/warehouses")
    @Operation(summary = "获取仓库列表", description = "获取所有仓库列表")
    public Result<List<Warehouse>> getAllWarehouses(
            @RequestParam(required = false) @Parameter(description = "状态") String status) {
        List<Warehouse> warehouses = adminWarehouseService.getAllWarehouses(status);
        return Result.ok(warehouses);
    }

    @GetMapping("/warehouses/{warehouseId}")
    @Operation(summary = "获取仓库详情", description = "获取仓库详细信息")
    public Result<Warehouse> getWarehouse(
            @PathVariable @Parameter(description = "仓库ID") Long warehouseId) {
        Warehouse warehouse = adminWarehouseService.getWarehouseById(warehouseId);
        return Result.ok(warehouse);
    }

    @PostMapping("/warehouses")
    @Operation(summary = "创建仓库", description = "创建新仓库账号")
    public Result<Warehouse> createWarehouse(
            @Valid @RequestBody WarehouseManagementDTO request) {
        Warehouse warehouse = adminWarehouseService.createWarehouse(request, request.getContactPhone());
        return Result.ok(warehouse);
    }

    @PutMapping("/warehouses/{warehouseId}")
    @Operation(summary = "更新仓库", description = "更新仓库信息")
    public Result<Warehouse> updateWarehouse(
            @PathVariable @Parameter(description = "仓库ID") Long warehouseId,
            @Valid @RequestBody WarehouseManagementDTO request) {
        Warehouse warehouse = adminWarehouseService.updateWarehouse(warehouseId, request);
        return Result.ok(warehouse);
    }

    @PutMapping("/warehouses/{warehouseId}/status")
    @Operation(summary = "更新仓库状态", description = "启用/停用仓库")
    public Result<Void> updateWarehouseStatus(
            @PathVariable @Parameter(description = "仓库ID") Long warehouseId,
            @RequestParam @Parameter(description = "状态") String status) {
        adminWarehouseService.updateWarehouseStatus(warehouseId, status);
        return Result.ok();
    }

    @GetMapping("/warehouses/{warehouseId}/staffs")
    @Operation(summary = "获取仓库人员", description = "获取仓库绑定的人员账号列表")
    public Result<List<WarehouseStaffDTO>> getWarehouseStaffs(
            @PathVariable @Parameter(description = "仓库ID") Long warehouseId) {
        List<WarehouseStaffDTO> staffs = adminWarehouseService.getWarehouseStaffs(warehouseId);
        return Result.ok(staffs);
    }
}
