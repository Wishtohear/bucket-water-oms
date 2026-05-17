package com.bucketwater.oms.module.statement.controller;

import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.export.service.ExcelExportService;
import com.bucketwater.oms.module.statement.dto.StatementDTO;
import com.bucketwater.oms.module.statement.service.StatementService;
import com.bucketwater.oms.module.user.entity.User;
import com.bucketwater.oms.common.security.JwtAuthenticationFilter;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;


@RestController
@RequestMapping("/statements")
@Tag(name = "对账单模块", description = "对账单查询、确认、导出")
public class StatementController {

    @Autowired
    private StatementService statementService;

    @Autowired
    private ExcelExportService excelExportService;

    @GetMapping
    @Operation(summary = "获取对账单列表", description = "获取水站对账单列表")
    public Result<List<StatementDTO>> getStatements(
            @RequestHeader(value = "X-Station-Id", required = false) Long headerStationId,
            HttpServletRequest httpRequest,
            @RequestParam(required = false) @Parameter(description = "账单月份") String yearMonth) {
        Long stationId = getStationId(headerStationId, httpRequest);
        List<StatementDTO> statements = statementService.getStatements(stationId, yearMonth);
        return Result.ok(statements);
    }

    private Long getStationId(Long headerStationId, HttpServletRequest request) {
        if (headerStationId != null) {
            return headerStationId;
        }
        Optional<User> currentUser = JwtAuthenticationFilter.getCurrentUser(request);
        if (currentUser.isPresent()) {
            Long stationId = currentUser.get().getStationId();
            if (stationId != null) {
                return stationId;
            }
        }
        throw new BusinessException(ResultCode.PARAM_ERROR, "无法获取水站ID，请检查登录状态");
    }

    @GetMapping("/{statementId}")
    @Operation(summary = "获取对账单详情", description = "获取对账单详细信息")
    public Result<StatementDTO> getStatementDetail(
            @PathVariable @Parameter(description = "对账单ID") Long statementId) {
        StatementDTO statement = statementService.getStatementDetail(statementId);
        return Result.ok(statement);
    }

    @PostMapping("/{statementId}/confirm")
    @Operation(summary = "确认对账单", description = "水站确认对账单")
    public Result<Void> confirmStatement(
            @PathVariable @Parameter(description = "对账单ID") Long statementId) {
        statementService.confirmStatement(statementId);
        return Result.ok();
    }

    @PostMapping("/{statementId}/dispute")
    @Operation(summary = "对账单异议", description = "水站对对账单有异议时提交异议")
    public Result<Void> disputeStatement(
            @PathVariable @Parameter(description = "对账单ID") Long statementId,
            @RequestParam @Parameter(description = "异议原因") String disputeReason) {
        statementService.disputeStatement(statementId, disputeReason);
        return Result.ok();
    }

    @GetMapping("/{statementId}/export")
    @Operation(summary = "导出对账单Excel", description = "导出对账单为Excel格式")
    public ResponseEntity<byte[]> exportStatement(
            @PathVariable @Parameter(description = "对账单ID") Long statementId) {
        byte[] excelData = excelExportService.exportStatement(statementId);

        StatementDTO statement = statementService.getStatementDetail(statementId);
        String filename = "对账单_" + statement.getYearMonth() + ".xlsx";

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
        headers.setContentDispositionFormData("attachment", filename);

        return ResponseEntity.ok()
                .headers(headers)
                .body(excelData);
    }
}
