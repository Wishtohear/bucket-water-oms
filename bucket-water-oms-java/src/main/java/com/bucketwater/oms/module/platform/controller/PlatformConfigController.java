package com.bucketwater.oms.module.platform.controller;

import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.common.security.RequireRole;
import com.bucketwater.oms.module.platform.entity.PlatformConfig;
import com.bucketwater.oms.module.platform.service.PlatformConfigService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/platform/config")
@Tag(name = "平台配置", description = "平台总超级管理员配置管理接口")
@RequireRole({"PLATFORM_ADMIN"})
public class PlatformConfigController {

    @Autowired
    private PlatformConfigService configService;

    @GetMapping("/groups/{group}")
    @Operation(summary = "获取配置列表", description = "获取指定分组的配置列表")
    public Result<List<PlatformConfig>> getConfigList(
            @PathVariable @Parameter(description = "配置分组") String group) {
        List<PlatformConfig> configs = configService.getConfigList(group);
        return Result.ok(configs);
    }

    @GetMapping("/map/{group}")
    @Operation(summary = "获取配置Map", description = "获取指定分组的配置Map（键值对）")
    public Result<Map<String, String>> getConfigMap(
            @PathVariable @Parameter(description = "配置分组") String group) {
        Map<String, String> configMap = configService.getConfigMap(group);
        return Result.ok(configMap);
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取配置详情", description = "根据ID获取配置详情")
    public Result<PlatformConfig> getConfigById(
            @PathVariable @Parameter(description = "配置ID") Long id) {
        PlatformConfig config = configService.getConfigById(id);
        return Result.ok(config);
    }

    @GetMapping("/key/{key}")
    @Operation(summary = "获取配置值", description = "根据配置键获取配置值")
    public Result<String> getConfigValue(
            @PathVariable @Parameter(description = "配置键") String key) {
        String value = configService.getConfigValue(key);
        return Result.ok(value);
    }

    @PostMapping
    @Operation(summary = "创建配置", description = "创建新配置项")
    @Transactional
    public Result<PlatformConfig> createConfig(@RequestBody PlatformConfig config) {
        PlatformConfig created = configService.createConfig(config);
        return Result.ok(created);
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新配置", description = "更新配置项")
    @Transactional
    public Result<PlatformConfig> updateConfig(
            @PathVariable @Parameter(description = "配置ID") Long id,
            @RequestBody PlatformConfig config) {
        PlatformConfig updated = configService.updateConfig(id, config);
        return Result.ok(updated);
    }

    @PutMapping("/value/{key}")
    @Operation(summary = "更新配置值", description = "根据配置键更新配置值")
    @Transactional
    public Result<Void> updateConfigValue(
            @PathVariable @Parameter(description = "配置键") String key,
            @RequestParam @Parameter(description = "配置值") String value) {
        configService.updateConfigValue(key, value);
        return Result.ok();
    }

    @PutMapping("/batch")
    @Operation(summary = "批量更新配置", description = "批量更新配置项")
    @Transactional
    public Result<Void> batchUpdateConfigs(@RequestBody Map<String, String> configMap) {
        configService.batchUpdateConfigs(configMap);
        return Result.ok();
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除配置", description = "删除配置项")
    @Transactional
    public Result<Void> deleteConfig(
            @PathVariable @Parameter(description = "配置ID") Long id) {
        configService.deleteConfig(id);
        return Result.ok();
    }
}
