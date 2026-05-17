package com.bucketwater.oms.module.audit.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.module.audit.dto.AuditLogDTO;
import com.bucketwater.oms.module.audit.dto.AuditLogQueryDTO;
import com.bucketwater.oms.module.audit.service.AuditLogService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/admin/audit-logs")
@Tag(name = "审计日志", description = "管理端审计日志查询")
public class AdminAuditLogController {

    private final AuditLogService auditLogService;

    public AdminAuditLogController(AuditLogService auditLogService) {
        this.auditLogService = auditLogService;
    }

    @GetMapping
    @Operation(summary = "查询审计日志", description = "分页查询审计日志列表，支持多条件筛选")
    public Result<IPage<AuditLogDTO>> queryLogs(
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

        IPage<AuditLogDTO> result = auditLogService.queryLogs(query);
        return Result.ok(result);
    }

    @GetMapping("/recent")
    @Operation(summary = "查询最近日志", description = "查询最近的审计日志")
    public Result<List<AuditLogDTO>> queryRecentLogs(
            @RequestParam(defaultValue = "50") @Parameter(description = "条数") Integer limit) {
        List<AuditLogDTO> logs = auditLogService.queryRecentLogs(limit);
        return Result.ok(logs);
    }

    @GetMapping("/{id}")
    @Operation(summary = "查询日志详情", description = "根据ID查询审计日志详情")
    public Result<AuditLogDTO> getLogById(
            @PathVariable @Parameter(description = "日志ID") Long id) {
        AuditLogDTO log = auditLogService.getLogById(id);
        return Result.ok(log);
    }

    @GetMapping("/debug/count")
    @Operation(summary = "调试：统计日志数量", description = "不经过逻辑删除过滤的统计")
    public Result<Map<String, Object>> debugCount() {
        long totalCount = auditLogService.countAllLogs();
        long activeCount = auditLogService.countActiveLogs();
        return Result.ok(Map.of(
            "totalCount", totalCount,
            "activeCount", activeCount,
            "message", "totalCount包含所有数据(包括deleted=1)，activeCount只包含deleted=0的数据"
        ));
    }

    @DeleteMapping
    @Operation(summary = "删除所有日志", description = "一键删除所有审计日志（危险操作）")
    public Result<Map<String, Object>> deleteAllLogs() {
        long deletedCount = auditLogService.deleteAllLogs();
        return Result.ok(Map.of(
            "deletedCount", deletedCount,
            "message", "成功删除 " + deletedCount + " 条日志"
        ));
    }
}
