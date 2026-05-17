package com.bucketwater.oms.module.platform.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.common.security.RequireRole;
import com.bucketwater.oms.module.platform.entity.PlatformOperationLog;
import com.bucketwater.oms.module.platform.service.PlatformOperationLogService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/platform/logs")
@Tag(name = "平台操作日志", description = "平台总超级管理员操作日志接口")
@RequireRole({"PLATFORM_ADMIN"})
public class PlatformOperationLogController {

    @Autowired
    private PlatformOperationLogService logService;

    @GetMapping
    @Operation(summary = "获取操作日志列表", description = "获取操作日志列表（分页）")
    public Result<IPage<PlatformOperationLog>> getLogPage(
            @RequestParam(required = false) @Parameter(description = "操作模块") String module,
            @RequestParam(required = false) @Parameter(description = "操作类型") String action,
            @RequestParam(required = false) @Parameter(description = "操作用户ID") Long userId,
            @RequestParam(required = false) @Parameter(description = "操作用户名称") String userName,
            @RequestParam(required = false) @Parameter(description = "操作对象类型") String targetType,
            @RequestParam(required = false) @Parameter(description = "开始时间") @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss") LocalDateTime startTime,
            @RequestParam(required = false) @Parameter(description = "结束时间") @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss") LocalDateTime endTime,
            @RequestParam(defaultValue = "1") @Parameter(description = "页码") Integer page,
            @RequestParam(defaultValue = "20") @Parameter(description = "每页数量") Integer size) {
        
        IPage<PlatformOperationLog> pageResult = logService.getLogPage(
                module, action, userId, userName, targetType, startTime, endTime, page, size);
        return Result.ok(pageResult);
    }

    @GetMapping("/list")
    @Operation(summary = "获取操作日志列表", description = "获取操作日志列表（不分页）")
    public Result<List<PlatformOperationLog>> getLogList(
            @RequestParam(required = false) @Parameter(description = "操作模块") String module,
            @RequestParam(required = false) @Parameter(description = "操作类型") String action,
            @RequestParam(required = false) @Parameter(description = "操作用户ID") Long userId,
            @RequestParam(required = false) @Parameter(description = "操作用户名称") String userName,
            @RequestParam(required = false) @Parameter(description = "操作对象类型") String targetType,
            @RequestParam(required = false) @Parameter(description = "开始时间") @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss") LocalDateTime startTime,
            @RequestParam(required = false) @Parameter(description = "结束时间") @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss") LocalDateTime endTime,
            @RequestParam(required = false) @Parameter(description = "返回数量限制") Integer limit) {
        
        List<PlatformOperationLog> logs = logService.getLogList(
                module, action, userId, userName, targetType, startTime, endTime, limit);
        return Result.ok(logs);
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取日志详情", description = "根据ID获取操作日志详情")
    public Result<PlatformOperationLog> getLogById(
            @PathVariable @Parameter(description = "日志ID") Long id) {
        PlatformOperationLog log = logService.getLogById(id);
        return Result.ok(log);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除日志", description = "删除指定日志")
    @Transactional
    public Result<Void> deleteLog(
            @PathVariable @Parameter(description = "日志ID") Long id) {
        logService.deleteLog(id);
        return Result.ok();
    }

    @DeleteMapping("/batch")
    @Operation(summary = "批量删除日志", description = "批量删除指定日志")
    @Transactional
    public Result<Void> deleteLogs(
            @RequestBody @Parameter(description = "日志ID列表") List<Long> ids) {
        logService.deleteLogs(ids);
        return Result.ok();
    }

    @DeleteMapping("/clear")
    @Operation(summary = "清理日志", description = "清理指定时间之前的日志")
    @Transactional
    public Result<Void> clearLogs(
            @RequestParam @Parameter(description = "清理此时间之前的日志") @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss") LocalDateTime beforeTime) {
        logService.clearLogs(beforeTime);
        return Result.ok();
    }
}
