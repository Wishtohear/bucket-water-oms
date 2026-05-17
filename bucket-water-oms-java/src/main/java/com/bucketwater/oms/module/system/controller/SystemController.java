package com.bucketwater.oms.module.system.controller;

import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.module.system.entity.SystemConfig;
import com.bucketwater.oms.module.system.service.SystemConfigService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@RestController
@RequestMapping("/system")
@Tag(name = "系统模块", description = "系统配置管理")
public class SystemController {

    @Autowired
    private SystemConfigService systemConfigService;

    @GetMapping("/configs")
    @Operation(summary = "获取所有配置", description = "获取所有系统配置")
    public Result<List<SystemConfig>> getAllConfigs() {
        List<SystemConfig> configs = systemConfigService.getAllConfigs();
        return Result.ok(configs);
    }

    @GetMapping("/configs/group/{group}")
    @Operation(summary = "获取分组配置", description = "按分组获取配置")
    public Result<List<SystemConfig>> getConfigsByGroup(
            @PathVariable @Parameter(description = "配置分组") String group) {
        List<SystemConfig> configs = systemConfigService.getConfigsByGroup(group);
        return Result.ok(configs);
    }

    @GetMapping("/configs/{key}")
    @Operation(summary = "获取配置值", description = "根据键获取配置值")
    public Result<String> getConfigValue(
            @PathVariable @Parameter(description = "配置键") String key) {
        String value = systemConfigService.getConfigValue(key);
        return Result.ok(value);
    }

    @PostMapping("/configs")
    @Operation(summary = "创建配置", description = "创建新配置")
    public Result<SystemConfig> createConfig(@RequestBody SystemConfig config) {
        SystemConfig created = systemConfigService.createConfig(config);
        return Result.ok(created);
    }

    @PutMapping("/configs/{id}")
    @Operation(summary = "更新配置", description = "更新配置值")
    public Result<SystemConfig> updateConfig(
            @PathVariable @Parameter(description = "配置ID") Long id,
            @RequestParam @Parameter(description = "配置值") String value) {
        SystemConfig updated = systemConfigService.updateConfig(id, value);
        return Result.ok(updated);
    }
}
