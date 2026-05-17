package com.bucketwater.oms.module.export.controller;

import com.bucketwater.oms.module.export.service.ExcelExportService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;


@RestController
@RequestMapping("/exports")
@Tag(name = "导出模块", description = "Excel导出功能")
public class ExportController {

    @Autowired
    private ExcelExportService excelExportService;

    @GetMapping("/statements/{statementId}")
    @Operation(summary = "导出对账单", description = "导出对账单为Excel格式")
    public ResponseEntity<byte[]> exportStatement(
            @PathVariable @Parameter(description = "对账单ID") Long statementId) {
        byte[] excelData = excelExportService.exportStatement(statementId);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
        headers.setContentDispositionFormData("attachment",
            "statement_" + statementId + "_" + LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd")) + ".xlsx");

        return ResponseEntity.ok()
                .headers(headers)
                .body(excelData);
    }

    @GetMapping("/orders")
    @Operation(summary = "导出订单", description = "导出订单列表为Excel格式")
    public ResponseEntity<byte[]> exportOrders(
            @RequestParam @Parameter(description = "订单ID列表") List<Long> orderIds,
            @RequestParam(required = false) @Parameter(description = "文件名标题") String title) {
        byte[] excelData = excelExportService.exportOrders(orderIds, title);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
        headers.setContentDispositionFormData("attachment",
            "orders_" + LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd")) + ".xlsx");

        return ResponseEntity.ok()
                .headers(headers)
                .body(excelData);
    }

    @GetMapping("/driver-statements/{statementId}")
    @Operation(summary = "导出司机对账单", description = "导出司机配送对账单为Excel格式")
    public ResponseEntity<byte[]> exportDriverStatement(
            @PathVariable @Parameter(description = "对账单ID") Long statementId) {
        byte[] excelData = excelExportService.exportDriverStatement(statementId);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
        headers.setContentDispositionFormData("attachment",
            "driver_statement_" + statementId + "_" + LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd")) + ".xlsx");

        return ResponseEntity.ok()
                .headers(headers)
                .body(excelData);
    }

    @GetMapping("/reports/sales")
    @Operation(summary = "导出销售统计报表", description = "导出销售统计报表为Excel格式")
    public ResponseEntity<byte[]> exportSalesReport(
            @RequestParam(required = false) @Parameter(description = "开始日期") String startDate,
            @RequestParam(required = false) @Parameter(description = "结束日期") String endDate) {
        byte[] excelData = excelExportService.exportSalesReport(startDate, endDate);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
        headers.setContentDispositionFormData("attachment",
            "sales_report_" + LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd")) + ".xlsx");

        return ResponseEntity.ok()
                .headers(headers)
                .body(excelData);
    }

    @GetMapping("/reports/station-purchase")
    @Operation(summary = "导出水站进货报表", description = "导出水站进货统计报表为Excel格式")
    public ResponseEntity<byte[]> exportStationPurchaseReport(
            @RequestParam(required = false) @Parameter(description = "开始日期") String startDate,
            @RequestParam(required = false) @Parameter(description = "结束日期") String endDate,
            @RequestParam(required = false) @Parameter(description = "水站ID") Long stationId) {
        byte[] excelData = excelExportService.exportStationPurchaseReport(startDate, endDate, stationId);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
        headers.setContentDispositionFormData("attachment",
            "station_purchase_" + LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd")) + ".xlsx");

        return ResponseEntity.ok()
                .headers(headers)
                .body(excelData);
    }

    @GetMapping("/reports/driver-delivery")
    @Operation(summary = "导出司机配送报表", description = "导出司机配送统计报表为Excel格式")
    public ResponseEntity<byte[]> exportDriverDeliveryReport(
            @RequestParam(required = false) @Parameter(description = "开始日期") String startDate,
            @RequestParam(required = false) @Parameter(description = "结束日期") String endDate,
            @RequestParam(required = false) @Parameter(description = "司机ID") Long driverId) {
        byte[] excelData = excelExportService.exportDriverDeliveryReport(startDate, endDate, driverId);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
        headers.setContentDispositionFormData("attachment",
            "driver_delivery_" + LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd")) + ".xlsx");

        return ResponseEntity.ok()
                .headers(headers)
                .body(excelData);
    }
}
