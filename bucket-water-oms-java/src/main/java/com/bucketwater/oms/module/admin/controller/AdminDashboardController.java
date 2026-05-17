package com.bucketwater.oms.module.admin.controller;

import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.common.security.RequireRole;
import com.bucketwater.oms.module.admin.dto.AdminDashboardDTO;
import com.bucketwater.oms.module.admin.service.AdminDashboardService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/admin/dashboard")
@Tag(name = "管理端-后台首页", description = "后台首页数据统计")
@RequireRole({"PLATFORM_ADMIN", "FACTORY_ADMIN"})
public class AdminDashboardController {

    @Autowired
    private AdminDashboardService dashboardService;

    @GetMapping
    @Operation(summary = "获取后台首页数据", description = "获取今日统计、销售趋势、通知、库存预警等数据")
    public Result<AdminDashboardDTO> getDashboardData() {
        AdminDashboardDTO data = dashboardService.getDashboardData();
        return Result.ok(data);
    }

    @GetMapping("/stats")
    @Operation(summary = "获取今日统计数据", description = "获取今日销售额、订单数、活跃水站数、库存预警数")
    public Result<AdminDashboardDTO.TodayStats> getTodayStats() {
        AdminDashboardDTO data = dashboardService.getDashboardData();
        return Result.ok(data.getTodayStats());
    }

    @GetMapping("/sales-trend")
    @Operation(summary = "获取销售趋势", description = "获取近7日销售趋势数据")
    public Result<?> getSalesTrend(
            @RequestParam(required = false) @Parameter(description = "天数") Integer days) {
        AdminDashboardDTO data = dashboardService.getDashboardData();
        return Result.ok(data.getSalesTrend());
    }

    @GetMapping("/notifications")
    @Operation(summary = "获取通知列表", description = "获取重要通知列表")
    public Result<?> getNotifications() {
        AdminDashboardDTO data = dashboardService.getDashboardData();
        return Result.ok(data.getNotifications());
    }

    @GetMapping("/inventory-warning")
    @Operation(summary = "获取库存预警", description = "获取库存预警信息")
    public Result<?> getInventoryWarning() {
        AdminDashboardDTO data = dashboardService.getDashboardData();
        return Result.ok(data.getInventoryWarning());
    }
}
