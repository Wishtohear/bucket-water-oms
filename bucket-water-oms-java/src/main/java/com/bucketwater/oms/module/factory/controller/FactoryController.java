package com.bucketwater.oms.module.factory.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.common.security.RequireRole;
import com.bucketwater.oms.module.factory.entity.Factory;
import com.bucketwater.oms.module.factory.service.FactoryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/platform/factories")
@Tag(name = "平台-水厂管理", description = "平台总超级管理员水厂管理接口")
@RequireRole({"PLATFORM_ADMIN"})
public class FactoryController {

    @Autowired
    private FactoryService factoryService;

    @GetMapping
    @Operation(summary = "获取水厂列表", description = "获取所有水厂列表，支持分页")
    public Result<IPage<Factory>> getFactoryPage(
            @RequestParam(required = false) @Parameter(description = "关键字搜索") String keyword,
            @RequestParam(required = false) @Parameter(description = "状态") String status,
            @RequestParam(defaultValue = "1") @Parameter(description = "页码") Integer page,
            @RequestParam(defaultValue = "20") @Parameter(description = "每页数量") Integer size) {
        IPage<Factory> pageResult = factoryService.getFactoryPage(keyword, status, page, size);
        return Result.ok(pageResult);
    }

    @GetMapping("/all")
    @Operation(summary = "获取所有水厂", description = "获取所有水厂列表（不分页）")
    public Result<List<Factory>> getAllFactories(
            @RequestParam(required = false) @Parameter(description = "状态") String status) {
        List<Factory> factories = factoryService.getAllFactories(status);
        return Result.ok(factories);
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取水厂详情", description = "根据ID获取水厂详细信息")
    public Result<Factory> getFactoryById(
            @PathVariable @Parameter(description = "水厂ID") Long id) {
        Factory factory = factoryService.getFactoryById(id);
        return Result.ok(factory);
    }

    @PostMapping
    @Operation(summary = "创建水厂", description = "创建新水厂")
    public Result<Factory> createFactory(@RequestBody Factory factory) {
        Factory created = factoryService.createFactory(factory);
        return Result.ok(created);
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新水厂", description = "更新水厂信息")
    public Result<Factory> updateFactory(
            @PathVariable @Parameter(description = "水厂ID") Long id,
            @RequestBody Factory factory) {
        Factory updated = factoryService.updateFactory(id, factory);
        return Result.ok(updated);
    }

    @PutMapping("/{id}/status")
    @Operation(summary = "更新水厂状态", description = "启用/停用水厂")
    public Result<Void> updateFactoryStatus(
            @PathVariable @Parameter(description = "水厂ID") Long id,
            @RequestParam @Parameter(description = "状态: active/inactive") String status) {
        factoryService.updateFactoryStatus(id, status);
        return Result.ok();
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除水厂", description = "删除水厂")
    public Result<Void> deleteFactory(
            @PathVariable @Parameter(description = "水厂ID") Long id) {
        factoryService.deleteFactory(id);
        return Result.ok();
    }
}
