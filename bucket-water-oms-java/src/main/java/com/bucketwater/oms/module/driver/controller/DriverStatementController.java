package com.bucketwater.oms.module.driver.controller;

import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.driver.dto.DriverStatementDTO;
import com.bucketwater.oms.module.driver.service.DriverStatementService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;


@RestController
@RequestMapping("/drivers/statements")
@Tag(name = "司机对账模块", description = "司机配送对账管理")
public class DriverStatementController {

    @Autowired
    private DriverStatementService statementService;

    @GetMapping
    @Operation(summary = "获取对账单列表", description = "获取司机对账单列表")
    public Result<List<DriverStatementDTO>> getStatements(
            @RequestHeader(value = "X-Driver-Id", required = false) @Parameter(description = "司机ID") String driverIdStr,
            @RequestParam(required = false) @Parameter(description = "状态") String status,
            @RequestParam(required = false, defaultValue = "false") @Parameter(description = "是否只返回最新对账单") Boolean latest) {
        Long driverId = parseDriverId(driverIdStr);
        if (latest != null && latest) {
            DriverStatementDTO latestStatement = statementService.getLatestStatement(driverId);
            return Result.ok(latestStatement != null ? List.of(latestStatement) : List.of());
        }
        List<DriverStatementDTO> statements = statementService.getStatements(driverId, status);
        return Result.ok(statements);
    }

    @GetMapping("/current")
    @Operation(summary = "获取当前对账单", description = "获取当前/最新的对账单（单个对象，供移动端使用）")
    public Result<DriverStatementDTO> getCurrentStatement(
            @RequestHeader(value = "X-Driver-Id", required = false) @Parameter(description = "司机ID") String driverIdStr) {
        Long driverId = parseDriverId(driverIdStr);
        DriverStatementDTO statement = statementService.getLatestStatement(driverId);
        return Result.ok(statement);
    }

    @GetMapping("/{statementId}")
    @Operation(summary = "获取对账单详情", description = "获取对账单详细信息")
    public Result<DriverStatementDTO> getStatement(
            @PathVariable @Parameter(description = "对账单ID") Long statementId) {
        DriverStatementDTO statement = statementService.getStatementById(statementId);
        return Result.ok(statement);
    }

    @PostMapping("/{statementId}/confirm")
    @Operation(summary = "确认对账单", description = "司机确认对账单")
    public Result<DriverStatementDTO> confirmStatement(
            @PathVariable @Parameter(description = "对账单ID") Long statementId) {
        DriverStatementDTO statement = statementService.confirmStatement(statementId);
        return Result.ok(statement);
    }

    @PostMapping("/generate")
    @Operation(summary = "生成对账单", description = "生成指定时间段的对账单")
    public Result<DriverStatementDTO> generateStatement(
            @RequestHeader(value = "X-Driver-Id", required = false) @Parameter(description = "司机ID") String driverIdStr,
            @RequestParam @Parameter(description = "开始日期") @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate startDate,
            @RequestParam @Parameter(description = "结束日期") @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate endDate,
            @RequestParam(required = false) @Parameter(description = "提成比例(%)") java.math.BigDecimal commissionRate,
            @RequestParam(required = false) @Parameter(description = "每公里里程补助(元)") java.math.BigDecimal mileageSubsidyPerKm) {
        Long driverId = parseDriverId(driverIdStr);
        DriverStatementDTO statement = statementService.generateStatement(driverId, startDate, endDate, commissionRate, mileageSubsidyPerKm);
        return Result.ok(statement);
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
