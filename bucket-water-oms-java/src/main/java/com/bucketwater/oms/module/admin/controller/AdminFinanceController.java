package com.bucketwater.oms.module.admin.controller;

import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.common.security.RequireRole;
import com.bucketwater.oms.module.admin.dto.FinanceOverviewDTO;
import com.bucketwater.oms.module.admin.service.AdminFinanceService;
import com.bucketwater.oms.module.statement.entity.MonthlyStatement;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/admin/finance")
@Tag(name = "管理端-财务管理", description = "财务管理和对账")
@RequireRole({"PLATFORM_ADMIN", "FACTORY_ADMIN"})
public class AdminFinanceController {

    @Autowired
    private AdminFinanceService financeService;

    @GetMapping("/overview")
    @Operation(summary = "获取财务概览", description = "获取本月应收、已回款、争议单、欠额等统计数据")
    public Result<FinanceOverviewDTO> getFinanceOverview() {
        FinanceOverviewDTO overview = financeService.getFinanceOverview();
        return Result.ok(overview);
    }

    @GetMapping("/statements")
    @Operation(summary = "获取对账单列表", description = "获取往来对账单列表")
    public Result<List<MonthlyStatement>> getStatements(
            @RequestParam(required = false) @Parameter(description = "年月") String yearMonth,
            @RequestParam(required = false) @Parameter(description = "水站名称") String stationName,
            @RequestParam(required = false) @Parameter(description = "状态") String status) {
        List<MonthlyStatement> statements = financeService.getStatements(yearMonth, stationName, status);
        return Result.ok(statements);
    }

    @GetMapping("/statements/{statementId}")
    @Operation(summary = "获取对账单详情", description = "根据ID获取对账单详细信息，包含明细列表")
    public Result<MonthlyStatement> getStatementById(
            @PathVariable @Parameter(description = "对账单ID") String statementId) {
        MonthlyStatement statement = financeService.getStatementById(statementId);
        return Result.ok(statement);
    }

    @PostMapping("/statements/{statementId}/confirm")
    @Operation(summary = "确认对账单", description = "确认对账单")
    public Result<Void> confirmStatement(
            @PathVariable @Parameter(description = "对账单ID") String statementId) {
        financeService.confirmStatement(statementId);
        return Result.ok();
    }

    @PostMapping("/statements/{statementId}/dispute")
    @Operation(summary = "处理争议", description = "处理对账单争议")
    public Result<Void> handleDispute(
            @PathVariable @Parameter(description = "对账单ID") String statementId,
            @RequestParam @Parameter(description = "解决方案") String resolution) {
        financeService.handleDispute(statementId, resolution);
        return Result.ok();
    }

    @GetMapping("/receivables")
    @Operation(summary = "获取应收款列表", description = "获取所有水站的应收款统计")
    public Result<List<Map<String, Object>>> getReceivables(
            @RequestParam(required = false) @Parameter(description = "水站ID") Long stationId,
            @RequestParam(required = false) @Parameter(description = "开始日期") String startDate,
            @RequestParam(required = false) @Parameter(description = "结束日期") String endDate) {
        List<Map<String, Object>> receivables = financeService.getReceivables(stationId, startDate, endDate);
        return Result.ok(receivables);
    }

    @GetMapping("/predeposits")
    @Operation(summary = "获取预存款列表", description = "获取所有水站的预存款余额信息")
    public Result<List<Map<String, Object>>> getPredeposits(
            @RequestParam(required = false) @Parameter(description = "水站ID") Long stationId) {
        List<Map<String, Object>> predeposits = financeService.getPredeposits(stationId);
        return Result.ok(predeposits);
    }

    @GetMapping("/summary")
    @Operation(summary = "获取财务摘要", description = "获取财务汇总数据")
    public Result<Map<String, Object>> getFinanceSummary() {
        Map<String, Object> summary = financeService.getFinanceSummary();
        return Result.ok(summary);
    }

    @GetMapping("/export/receivables")
    @Operation(summary = "导出应收款报表", description = "导出应收款报表Excel")
    public ResponseEntity<byte[]> exportReceivablesReport(
            @RequestParam(required = false) @Parameter(description = "水站ID") Long stationId,
            @RequestParam(required = false) @Parameter(description = "开始日期") String startDate,
            @RequestParam(required = false) @Parameter(description = "结束日期") String endDate) {
        byte[] excelData = financeService.exportReceivables(stationId, startDate, endDate);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
        headers.setContentDispositionFormData("attachment", "receivables_" + System.currentTimeMillis() + ".xlsx");

        return ResponseEntity.ok()
                .headers(headers)
                .body(excelData);
    }

    @GetMapping("/export/predeposits")
    @Operation(summary = "导出预存款报表", description = "导出预存款报表Excel")
    public ResponseEntity<byte[]> exportPredepositsReport(
            @RequestParam(required = false) @Parameter(description = "水站ID") Long stationId) {
        byte[] excelData = financeService.exportPredeposits(stationId);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
        headers.setContentDispositionFormData("attachment", "predeposits_" + System.currentTimeMillis() + ".xlsx");

        return ResponseEntity.ok()
                .headers(headers)
                .body(excelData);
    }
}
