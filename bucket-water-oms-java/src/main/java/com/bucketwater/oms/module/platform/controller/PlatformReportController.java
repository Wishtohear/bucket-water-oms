package com.bucketwater.oms.module.platform.controller;

import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.common.security.RequireRole;
import com.bucketwater.oms.module.platform.service.PlatformReportService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.Map;

@RestController
@RequestMapping("/platform/reports")
@Tag(name = "平台报表", description = "平台总超级管理员报表接口")
@RequireRole({"PLATFORM_ADMIN"})
public class PlatformReportController {

    @Autowired
    private PlatformReportService reportService;

    @GetMapping("/sales")
    @Operation(summary = "销售统计报表", description = "返回销售总额、订单数、客单价及趋势")
    public Result<Map<String, Object>> getSalesReport(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) @Parameter(description = "开始日期") LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) @Parameter(description = "结束日期") LocalDate endDate,
            @RequestParam(required = false) @Parameter(description = "水厂ID") Long factoryId) {
        return Result.ok(reportService.getSalesStats(startDate, endDate, factoryId));
    }

    @GetMapping("/orders")
    @Operation(summary = "订单统计报表", description = "按日期分组统计订单")
    public Result<Map<String, Object>> getOrderReport(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) @Parameter(description = "开始日期") LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) @Parameter(description = "结束日期") LocalDate endDate) {
        return Result.ok(reportService.getOrderStats(startDate, endDate));
    }

    @GetMapping("/comparison")
    @Operation(summary = "水厂对比报表", description = "按水厂统计订单数、销售额并排名")
    public Result<Map<String, Object>> getComparisonReport(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) @Parameter(description = "开始日期") LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) @Parameter(description = "结束日期") LocalDate endDate) {
        return Result.ok(reportService.getFactoryComparison(startDate, endDate));
    }
}
