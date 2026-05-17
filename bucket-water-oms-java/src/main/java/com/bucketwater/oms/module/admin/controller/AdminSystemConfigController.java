package com.bucketwater.oms.module.admin.controller;

import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.common.security.RequireRole;
import com.bucketwater.oms.module.admin.dto.SystemConfigDTO;
import com.bucketwater.oms.module.admin.service.AdminSystemService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/admin/system")
@Tag(name = "管理端-系统配置", description = "系统设置和配置管理")
@RequireRole({"PLATFORM_ADMIN", "FACTORY_ADMIN"})
public class AdminSystemConfigController {

    @Autowired
    private AdminSystemService systemService;

    @GetMapping("/config")
    @Operation(summary = "获取系统配置", description = "获取系统基础配置信息")
    public Result<SystemConfigDTO> getSystemConfig() {
        SystemConfigDTO config = systemService.getSystemConfig();
        return Result.ok(config);
    }

    @PutMapping("/config")
    @Operation(summary = "更新系统配置", description = "更新系统基础业务配置")
    public Result<Void> updateSystemConfig(@RequestBody SystemConfigDTO config) {
        systemService.updateSystemConfig(config);
        return Result.ok();
    }

    @GetMapping("/admins")
    @Operation(summary = "获取管理员列表", description = "获取所有管理员账号")
    public Result<List<SystemConfigDTO.AdminUser>> getAdminUsers(
            @RequestParam(required = false) @Parameter(description = "角色") String role,
            @RequestParam(required = false) @Parameter(description = "状态") String status) {
        List<SystemConfigDTO.AdminUser> admins = systemService.getAdminUsers(role, status);
        return Result.ok(admins);
    }

    @GetMapping("/admins/{adminId}")
    @Operation(summary = "获取管理员详情", description = "根据ID获取管理员详细信息")
    public Result<SystemConfigDTO.AdminUser> getAdminUser(
            @PathVariable @Parameter(description = "管理员ID") String adminId) {
        SystemConfigDTO.AdminUser admin = systemService.getAdminUser(adminId);
        return Result.ok(admin);
    }

    @PostMapping("/admins")
    @Operation(summary = "添加管理员", description = "添加新的管理员账号")
    public Result<Void> addAdminUser(@RequestBody SystemConfigDTO.AdminUser user) {
        systemService.addAdminUser(user);
        return Result.ok();
    }

    @PutMapping("/admins/{adminId}")
    @Operation(summary = "更新管理员", description = "更新管理员信息")
    public Result<Void> updateAdminUser(
            @PathVariable @Parameter(description = "管理员ID") String adminId,
            @RequestBody SystemConfigDTO.AdminUser user) {
        systemService.updateAdminUser(adminId, user);
        return Result.ok();
    }

    @DeleteMapping("/admins/{adminId}")
    @Operation(summary = "删除管理员", description = "删除管理员账号")
    public Result<Void> deleteAdminUser(
            @PathVariable @Parameter(description = "管理员ID") String adminId) {
        systemService.deleteAdminUser(adminId);
        return Result.ok();
    }

    @PatchMapping("/admins/{adminId}/enable")
    @Operation(summary = "启用管理员", description = "启用禁用状态的管理员账号")
    public Result<Void> enableAdminUser(
            @PathVariable @Parameter(description = "管理员ID") String adminId) {
        systemService.enableAdminUser(adminId);
        return Result.ok();
    }

    @PatchMapping("/admins/{adminId}/disable")
    @Operation(summary = "禁用管理员", description = "禁用管理员账号")
    public Result<Void> disableAdminUser(
            @PathVariable @Parameter(description = "管理员ID") String adminId) {
        systemService.disableAdminUser(adminId);
        return Result.ok();
    }

    @PostMapping("/admins/{adminId}/reset-password")
    @Operation(summary = "重置管理员密码", description = "重置管理员密码为123456")
    public Result<Map<String, String>> resetAdminPassword(
            @PathVariable @Parameter(description = "管理员ID") String adminId) {
        String newPassword = systemService.resetAdminPassword(adminId);
        return Result.ok(Map.of("newPassword", newPassword));
    }

    @PatchMapping("/admins/{adminId}/role")
    @Operation(summary = "更新管理员角色", description = "更新管理员的角色和权限")
    public Result<Void> updateAdminRole(
            @PathVariable @Parameter(description = "管理员ID") String adminId,
            @RequestBody @Parameter(description = "角色和权限") Map<String, Object> roleData) {
        String role = (String) roleData.get("role");
        List<String> permissions = (List<String>) roleData.get("permissions");
        systemService.updateAdminRole(adminId, role, permissions);
        return Result.ok();
    }

    @GetMapping("/audit-logs")
    @Operation(summary = "获取审计日志", description = "获取系统操作审计日志")
    public Result<List<SystemConfigDTO.AuditLog>> getAuditLogs(
            @RequestParam(required = false) @Parameter(description = "操作类型") String actionType,
            @RequestParam(required = false) @Parameter(description = "开始日期") String startDate,
            @RequestParam(required = false) @Parameter(description = "结束日期") String endDate,
            @RequestParam(required = false) @Parameter(description = "操作人ID") String operatorId,
            @RequestParam(required = false) @Parameter(description = "关键字") String keyword,
            @RequestParam(defaultValue = "1") @Parameter(description = "页码") Integer page,
            @RequestParam(defaultValue = "20") @Parameter(description = "每页数量") Integer pageSize) {
        List<SystemConfigDTO.AuditLog> logs = systemService.getAuditLogs(
            actionType, startDate, endDate, operatorId, keyword, page, pageSize);
        return Result.ok(logs);
    }

    @GetMapping("/audit-logs/{logId}")
    @Operation(summary = "获取审计日志详情", description = "根据ID获取审计日志详细信息")
    public Result<SystemConfigDTO.AuditLog> getAuditLogById(
            @PathVariable @Parameter(description = "日志ID") String logId) {
        SystemConfigDTO.AuditLog log = systemService.getAuditLogById(logId);
        return Result.ok(log);
    }

    @GetMapping("/audit-logs/export")
    @Operation(summary = "导出审计日志", description = "导出审计日志为Excel文件")
    public Result<byte[]> exportAuditLogs(
            @RequestParam(required = false) @Parameter(description = "操作类型") String actionType,
            @RequestParam(required = false) @Parameter(description = "开始日期") String startDate,
            @RequestParam(required = false) @Parameter(description = "结束日期") String endDate,
            @RequestParam(required = false) @Parameter(description = "操作人ID") String operatorId) {
        byte[] data = systemService.exportAuditLogs(actionType, startDate, endDate, operatorId);
        return Result.ok(data);
    }

    @GetMapping("/configs")
    @Operation(summary = "获取所有配置", description = "获取系统所有配置项")
    public Result<List<Map<String, Object>>> getConfigs() {
        List<Map<String, Object>> configs = systemService.getConfigs();
        return Result.ok(configs);
    }

    @GetMapping("/configs/{category}")
    @Operation(summary = "按分类获取配置", description = "根据分类获取配置项")
    public Result<List<Map<String, Object>>> getConfigsByCategory(
            @PathVariable @Parameter(description = "配置分类") String category) {
        List<Map<String, Object>> configs = systemService.getConfigsByCategory(category);
        return Result.ok(configs);
    }

    @PatchMapping("/configs/{key}")
    @Operation(summary = "更新单个配置", description = "根据key更新配置项")
    public Result<Void> updateConfig(
            @PathVariable @Parameter(description = "配置key") String key,
            @RequestBody @Parameter(description = "配置值") Map<String, Object> configData) {
        Object value = configData.get("value");
        systemService.updateConfig(key, value);
        return Result.ok();
    }

    @PatchMapping("/configs/batch")
    @Operation(summary = "批量更新配置", description = "批量更新多个配置项")
    public Result<Void> batchUpdateConfigs(
            @RequestBody @Parameter(description = "配置列表") List<Map<String, Object>> configs) {
        systemService.batchUpdateConfigs(configs);
        return Result.ok();
    }

    @GetMapping("/configs/statement")
    @Operation(summary = "获取对账单设置", description = "获取对账单相关配置")
    public Result<Map<String, Object>> getStatementSettings() {
        Map<String, Object> settings = systemService.getStatementSettings();
        return Result.ok(settings);
    }

    @PatchMapping("/configs/statement")
    @Operation(summary = "更新对账单设置", description = "更新对账单相关配置")
    public Result<Void> updateStatementSettings(
            @RequestBody Map<String, Object> settings) {
        systemService.updateStatementSettings(settings);
        return Result.ok();
    }

    @GetMapping("/configs/notifications")
    @Operation(summary = "获取通知设置", description = "获取系统通知配置")
    public Result<Map<String, Object>> getNotificationSettings() {
        Map<String, Object> settings = systemService.getNotificationSettings();
        return Result.ok(settings);
    }

    @PatchMapping("/configs/notifications")
    @Operation(summary = "更新通知设置", description = "更新系统通知配置")
    public Result<Void> updateNotificationSettings(
            @RequestBody Map<String, Object> settings) {
        systemService.updateNotificationSettings(settings);
        return Result.ok();
    }

    @GetMapping("/configs/basic")
    @Operation(summary = "获取基础设置", description = "获取系统基础配置")
    public Result<Map<String, Object>> getBasicSettings() {
        Map<String, Object> settings = systemService.getBasicSettings();
        return Result.ok(settings);
    }

    @PatchMapping("/configs/basic")
    @Operation(summary = "更新基础设置", description = "更新系统基础配置")
    public Result<Void> updateBasicSettings(
            @RequestBody Map<String, Object> settings) {
        systemService.updateBasicSettings(settings);
        return Result.ok();
    }

    @GetMapping("/configs/inventory")
    @Operation(summary = "获取库存设置", description = "获取库存预警配置")
    public Result<Map<String, Object>> getInventorySettings() {
        Map<String, Object> settings = systemService.getInventorySettings();
        return Result.ok(settings);
    }

    @PatchMapping("/configs/inventory")
    @Operation(summary = "更新库存设置", description = "更新库存预警配置")
    public Result<Void> updateInventorySettings(
            @RequestBody Map<String, Object> settings) {
        systemService.updateInventorySettings(settings);
        return Result.ok();
    }

    @GetMapping("/settings/all")
    @Operation(summary = "获取所有设置", description = "获取系统所有配置汇总")
    public Result<Map<String, Object>> getAllSettings() {
        Map<String, Object> settings = systemService.getAllSettings();
        return Result.ok(settings);
    }
}
