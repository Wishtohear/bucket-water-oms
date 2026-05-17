package com.bucketwater.oms.module.admin.controller;

import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.common.security.RequireRole;
import com.bucketwater.oms.module.admin.dto.OrderManagementDTO;
import com.bucketwater.oms.module.admin.service.AdminOrderService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/admin/orders")
@Tag(name = "管理端-订单管理", description = "管理端订单查询和管理")
@RequireRole({"PLATFORM_ADMIN", "FACTORY_ADMIN"})
public class AdminOrderController {

    @Autowired
    private AdminOrderService adminOrderService;

    @GetMapping("/page")
    @Operation(summary = "分页查询订单列表", description = "支持关键字搜索、状态筛选、仓库筛选、日期范围筛选、分页")
    public Result<OrderManagementDTO.OrderPageResult> queryOrders(
            @RequestParam(required = false) @Parameter(description = "关键字搜索（订单号/水站名称）") String keyword,
            @RequestParam(required = false) @Parameter(description = "订单状态") String status,
            @RequestParam(required = false) @Parameter(description = "仓库ID") Long warehouseId,
            @RequestParam(required = false) @Parameter(description = "水站ID") Long stationId,
            @RequestParam(required = false) @Parameter(description = "开始日期 YYYY-MM-DD") String startDate,
            @RequestParam(required = false) @Parameter(description = "结束日期 YYYY-MM-DD") String endDate,
            @RequestParam(defaultValue = "1") @Parameter(description = "页码") Integer page,
            @RequestParam(defaultValue = "20") @Parameter(description = "每页数量") Integer size) {

        OrderManagementDTO.OrderQueryDTO query = new OrderManagementDTO.OrderQueryDTO();
        query.setKeyword(keyword);
        query.setStatus(status);
        query.setWarehouseId(warehouseId);
        query.setStationId(stationId);
        query.setStartDate(startDate);
        query.setEndDate(endDate);
        query.setPage(page);
        query.setSize(size);

        OrderManagementDTO.OrderPageResult result = adminOrderService.queryOrders(query);
        return Result.ok(result);
    }

    @GetMapping("/{orderId}")
    @Operation(summary = "获取订单详情", description = "获取订单详细信息")
    public Result<OrderManagementDTO> getOrderDetail(
            @PathVariable @Parameter(description = "订单ID") Long orderId) {
        OrderManagementDTO order = adminOrderService.getOrderDetail(orderId);
        return Result.ok(order);
    }

    @PostMapping("/{orderId}/cancel")
    @Operation(summary = "取消订单", description = "取消订单")
    public Result<Void> cancelOrder(
            @PathVariable @Parameter(description = "订单ID") Long orderId,
            @RequestParam(required = false) @Parameter(description = "取消原因") String reason) {
        adminOrderService.cancelOrder(orderId, reason);
        return Result.ok();
    }

    @GetMapping("/stats")
    @Operation(summary = "获取订单统计数据", description = "获取今日订单数、待处理数、完成数等统计数据")
    public Result<Map<String, Object>> getOrderStats() {
        Map<String, Object> stats = adminOrderService.getOrderStats();
        return Result.ok(stats);
    }
}
