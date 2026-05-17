package com.bucketwater.oms.module.admin.controller;

import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.common.security.RequireRole;
import com.bucketwater.oms.module.admin.dto.DashboardStatsDTO;
import com.bucketwater.oms.module.admin.dto.ReportStatsDTO;
import com.bucketwater.oms.module.admin.service.AdminReportService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/admin/reports")
@Tag(name = "管理端-报表统计", description = "运营报表统计和分析")
@RequireRole({"PLATFORM_ADMIN", "FACTORY_ADMIN"})
public class AdminReportStatsController {

    @Autowired
    private AdminReportService reportService;

    @GetMapping("/dashboard-stats")
    @Operation(summary = "获取Dashboard统计数据", description = "获取今日销售、订单、活跃水站、库存预警等概览数据")
    public Result<DashboardStatsDTO> getDashboardStats() {
        DashboardStatsDTO stats = reportService.getDashboardStats();
        return Result.ok(stats);
    }

    @GetMapping("/stats")
    @Operation(summary = "获取报表统计数据", description = "获取销售趋势、产品分布、水站排行、日报等统计数据")
    public Result<ReportStatsDTO> getReportStats(
            @RequestParam(required = false, defaultValue = "daily") @Parameter(description = "报表类型: daily/weekly/monthly/quarterly") String reportType,
            @RequestParam(required = false) @Parameter(description = "开始月份") String startMonth,
            @RequestParam(required = false) @Parameter(description = "结束月份") String endMonth) {
        ReportStatsDTO stats = reportService.getReportStats(reportType, startMonth, endMonth);
        return Result.ok(stats);
    }

    @GetMapping("/sales-trend")
    @Operation(summary = "获取销售趋势", description = "获取月度销售趋势数据")
    public Result<?> getSalesTrend(
            @RequestParam(required = false) @Parameter(description = "开始日期") String startDate,
            @RequestParam(required = false) @Parameter(description = "结束日期") String endDate,
            @RequestParam(required = false, defaultValue = "day") @Parameter(description = "类型: day/week/month") String type) {
        List<Map<String, Object>> trend = reportService.getSalesTrend(startDate, endDate, type);
        return Result.ok(trend);
    }

    @GetMapping("/product-sales")
    @Operation(summary = "获取产品销量统计", description = "获取按产品分类的销售统计")
    public Result<List<Map<String, Object>>> getProductSales(
            @RequestParam(required = false) @Parameter(description = "开始日期") String startDate,
            @RequestParam(required = false) @Parameter(description = "结束日期") String endDate) {
        List<Map<String, Object>> sales = reportService.getProductSales(startDate, endDate);
        return Result.ok(sales);
    }

    @GetMapping("/station-ranking")
    @Operation(summary = "获取水站订货排行", description = "获取TOP水站订货排行榜")
    public Result<List<Map<String, Object>>> getStationRanking(
            @RequestParam(required = false, defaultValue = "10") @Parameter(description = "排名数量") Integer limit,
            @RequestParam(required = false) @Parameter(description = "开始日期") String startDate,
            @RequestParam(required = false) @Parameter(description = "结束日期") String endDate) {
        List<Map<String, Object>> rankings = reportService.getStationRanking(limit, startDate, endDate);
        return Result.ok(rankings);
    }

    @GetMapping("/daily-sales")
    @Operation(summary = "获取销售明细日报", description = "获取每日销售明细数据")
    public Result<List<Map<String, Object>>> getDailySales(
            @RequestParam(required = false) @Parameter(description = "开始日期") String startDate,
            @RequestParam(required = false) @Parameter(description = "结束日期") String endDate) {
        List<Map<String, Object>> sales = reportService.getDailySales(startDate, endDate);
        return Result.ok(sales);
    }

    @GetMapping("/station-purchase")
    @Operation(summary = "获取水站采购报表", description = "获取水站采购明细统计")
    public Result<Map<String, Object>> getStationPurchaseReport(
            @RequestParam(required = false) @Parameter(description = "开始日期") String startDate,
            @RequestParam(required = false) @Parameter(description = "结束日期") String endDate,
            @RequestParam(required = false) @Parameter(description = "水站ID") Long stationId,
            @RequestParam(required = false) @Parameter(description = "区域") String area,
            @RequestParam(defaultValue = "1") @Parameter(description = "页码") Integer page,
            @RequestParam(defaultValue = "20") @Parameter(description = "每页数量") Integer size) {
        Map<String, Object> report = reportService.getStationPurchaseReport(startDate, endDate, stationId, area, page, size);
        return Result.ok(report);
    }

    @GetMapping("/station-purchase/export")
    @Operation(summary = "导出水站采购报表", description = "导出水站采购明细为Excel")
    public Result<byte[]> exportStationPurchaseReport(
            @RequestParam(required = false) @Parameter(description = "开始日期") String startDate,
            @RequestParam(required = false) @Parameter(description = "结束日期") String endDate,
            @RequestParam(required = false) @Parameter(description = "水站ID") Long stationId,
            @RequestParam(required = false) @Parameter(description = "区域") String area) {
        byte[] data = reportService.exportStationPurchaseReport(startDate, endDate, stationId, area);
        return Result.ok(data);
    }

    @GetMapping("/driver-delivery")
    @Operation(summary = "获取司机配送报表", description = "获取司机配送统计报表")
    public Result<Map<String, Object>> getDriverDeliveryReport(
            @RequestParam(required = false) @Parameter(description = "开始日期") String startDate,
            @RequestParam(required = false) @Parameter(description = "结束日期") String endDate,
            @RequestParam(required = false) @Parameter(description = "司机ID") Long driverId,
            @RequestParam(defaultValue = "1") @Parameter(description = "页码") Integer page,
            @RequestParam(defaultValue = "20") @Parameter(description = "每页数量") Integer size) {
        Map<String, Object> report = reportService.getDriverDeliveryReport(startDate, endDate, driverId, page, size);
        return Result.ok(report);
    }

    @GetMapping("/driver-stats-summary")
    @Operation(summary = "获取司机统计汇总", description = "获取司机配送统计汇总")
    public Result<Map<String, Object>> getDriverStatsSummary(
            @RequestParam(required = false) @Parameter(description = "开始日期") String startDate,
            @RequestParam(required = false) @Parameter(description = "结束日期") String endDate) {
        Map<String, Object> summary = reportService.getDriverStatsSummary(startDate, endDate);
        return Result.ok(summary);
    }

    @GetMapping("/driver-delivery/export")
    @Operation(summary = "导出司机配送报表", description = "导出司机配送明细为Excel")
    public Result<byte[]> exportDriverDeliveryReport(
            @RequestParam(required = false) @Parameter(description = "开始日期") String startDate,
            @RequestParam(required = false) @Parameter(description = "结束日期") String endDate,
            @RequestParam(required = false) @Parameter(description = "司机ID") Long driverId) {
        byte[] data = reportService.exportDriverDeliveryReport(startDate, endDate, driverId);
        return Result.ok(data);
    }

    @GetMapping("/bucket-stats-summary")
    @Operation(summary = "获取桶装统计汇总", description = "获取桶装统计汇总数据")
    public Result<Map<String, Object>> getBucketStatsSummary() {
        Map<String, Object> summary = reportService.getBucketStatsSummary();
        return Result.ok(summary);
    }

    @GetMapping("/station-bucket")
    @Operation(summary = "获取水站桶装报表", description = "获取各水站桶装押金和欠桶统计")
    public Result<List<Map<String, Object>>> getStationBucketReport() {
        List<Map<String, Object>> report = reportService.getStationBucketReport();
        return Result.ok(report);
    }

    @GetMapping("/warehouse-bucket")
    @Operation(summary = "获取仓库桶装报表", description = "获取仓库桶装库存统计")
    public Result<List<Map<String, Object>>> getWarehouseBucketReport() {
        List<Map<String, Object>> report = reportService.getWarehouseBucketReport();
        return Result.ok(report);
    }

    @GetMapping("/in-transit-buckets")
    @Operation(summary = "获取在途桶装", description = "获取司机在途桶装统计")
    public Result<List<Map<String, Object>>> getInTransitBuckets() {
        List<Map<String, Object>> buckets = reportService.getInTransitBuckets();
        return Result.ok(buckets);
    }

    @GetMapping("/in-transit-buckets/export")
    @Operation(summary = "导出在途桶装", description = "导出在途桶装数据为Excel")
    public Result<byte[]> exportInTransitBuckets() {
        byte[] data = reportService.exportInTransitBuckets();
        return Result.ok(data);
    }

    @GetMapping("/export")
    @Operation(summary = "导出报表", description = "导出报表数据为Excel")
    public Result<Void> exportReport(
            @RequestParam @Parameter(description = "报表类型") String reportType,
            @RequestParam(required = false) @Parameter(description = "开始月份") String startMonth,
            @RequestParam(required = false) @Parameter(description = "结束月份") String endMonth) {
        return Result.ok();
    }
}
