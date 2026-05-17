package com.bucketwater.oms.module.warehouse.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.module.audit.dto.AuditLogDTO;
import com.bucketwater.oms.module.audit.dto.AuditLogQueryDTO;
import com.bucketwater.oms.module.audit.service.AuditLogService;
import com.bucketwater.oms.module.warehouse.service.WarehouseOperationLogService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/warehouses/operation-logs")
@Tag(name = "仓库操作日志", description = "仓库端操作日志查询")
public class WarehouseOperationLogController {

    private static final Logger log = LoggerFactory.getLogger(WarehouseOperationLogController.class);

    private final WarehouseOperationLogService warehouseOperationLogService;
    private final AuditLogService auditLogService;

    public WarehouseOperationLogController(
            WarehouseOperationLogService warehouseOperationLogService,
            AuditLogService auditLogService) {
        this.warehouseOperationLogService = warehouseOperationLogService;
        this.auditLogService = auditLogService;
    }

    @GetMapping
    @Operation(summary = "查询操作日志", description = "分页查询仓库操作日志列表，支持多条件筛选")
    public Result<IPage<AuditLogDTO>> queryLogs(
            HttpServletRequest request,
            @RequestParam(required = false) @Parameter(description = "用户ID") Long userId,
            @RequestParam(required = false) @Parameter(description = "用户名") String username,
            @RequestParam(required = false) @Parameter(description = "操作类型") String action,
            @RequestParam(required = false) @Parameter(description = "模块") String module,
            @RequestParam(required = false) @Parameter(description = "实体类型") String entityType,
            @RequestParam(required = false) @Parameter(description = "实体ID") String entityId,
            @RequestParam(required = false) @Parameter(description = "开始时间 YYYY-MM-DD") String startTime,
            @RequestParam(required = false) @Parameter(description = "结束时间 YYYY-MM-DD") String endTime,
            @RequestParam(defaultValue = "1") @Parameter(description = "页码") Integer page,
            @RequestParam(defaultValue = "20") @Parameter(description = "每页条数") Integer pageSize) {

        String warehouseIdHeader = request.getHeader("X-Warehouse-Id");
        log.info("查询仓库操作日志, warehouseId={}, userId={}, username={}, action={}, module={}",
                warehouseIdHeader, userId, username, action, module);

        AuditLogQueryDTO query = new AuditLogQueryDTO();
        query.setUserId(userId);
        query.setUsername(username);
        query.setAction(action);
        query.setModule(module);
        query.setEntityType(entityType);
        query.setEntityId(entityId);
        query.setStartTime(startTime);
        query.setEndTime(endTime);
        query.setPage(page);
        query.setPageSize(pageSize);

        IPage<AuditLogDTO> result = warehouseOperationLogService.queryLogsByWarehouse(warehouseIdHeader, query);
        return Result.ok(result);
    }

    @GetMapping("/recent")
    @Operation(summary = "查询最近日志", description = "查询仓库最近的审计日志")
    public Result<List<AuditLogDTO>> queryRecentLogs(
            HttpServletRequest request,
            @RequestParam(defaultValue = "50") @Parameter(description = "条数") Integer limit) {

        String warehouseIdHeader = request.getHeader("X-Warehouse-Id");
        log.info("查询仓库最近操作日志, warehouseId={}, limit={}", warehouseIdHeader, limit);

        List<AuditLogDTO> logs = warehouseOperationLogService.queryRecentLogsByWarehouse(warehouseIdHeader, limit);
        return Result.ok(logs);
    }

    @GetMapping("/{id}")
    @Operation(summary = "查询日志详情", description = "根据ID查询操作日志详情")
    public Result<AuditLogDTO> getLogById(
            HttpServletRequest request,
            @PathVariable @Parameter(description = "日志ID") Long id) {

        String warehouseIdHeader = request.getHeader("X-Warehouse-Id");
        log.info("查询操作日志详情, warehouseId={}, logId={}", warehouseIdHeader, id);

        AuditLogDTO log = warehouseOperationLogService.getLogById(warehouseIdHeader, id);
        if (log == null) {
            return Result.error("日志不存在或无权访问");
        }
        return Result.ok(log);
    }
}
