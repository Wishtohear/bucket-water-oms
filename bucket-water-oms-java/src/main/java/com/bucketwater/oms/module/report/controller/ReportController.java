package com.bucketwater.oms.module.report.controller;

import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.module.report.service.ReportService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/reports")
@Tag(name = "报表模块", description = "各类统计报表")
public class ReportController {

    @Autowired
    private ReportService reportService;

    @GetMapping("/station-purchase")
    @Operation(summary = "水站进货报表", description = "按月份统计水站进货量和金额")
    public Result<Map<String, Object>> getStationPurchaseReport(
            @RequestParam @Parameter(description = "账单月份") String yearMonth,
            @RequestParam(required = false) @Parameter(description = "水站ID") String stationId) {
        Map<String, Object> report = reportService.getStationPurchaseReport(yearMonth, stationId);
        return Result.ok(report);
    }

    @GetMapping("/driver-delivery")
    @Operation(summary = "司机配送报表", description = "按月份统计司机配送单数、桶数")
    public Result<Map<String, Object>> getDriverDeliveryReport(
            @RequestParam @Parameter(description = "账单月份") String yearMonth,
            @RequestParam(required = false) @Parameter(description = "司机ID") String driverId) {
        Map<String, Object> report = reportService.getDriverDeliveryReport(yearMonth, driverId);
        return Result.ok(report);
    }

    @GetMapping("/bucket-summary")
    @Operation(summary = "空桶汇总报表", description = "各水站欠桶数量、仓库库存、在途数量")
    public Result<Map<String, Object>> getBucketSummary() {
        Map<String, Object> summary = reportService.getBucketSummary();
        return Result.ok(summary);
    }

    @GetMapping("/export")
    @Operation(summary = "导出Excel", description = "导出报表为Excel格式")
    public ResponseEntity<byte[]> exportReport(
            @RequestParam @Parameter(description = "报表类型") String type,
            @RequestParam(required = false) @Parameter(description = "账单月份") String yearMonth) {
        byte[] excelData = reportService.exportReport(type, yearMonth);

        String filename = type + "_" + (yearMonth != null ? yearMonth : "all") + ".xlsx";

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
        headers.setContentDispositionFormData("attachment", filename);

        return ResponseEntity.ok()
                .headers(headers)
                .body(excelData);
    }
}
