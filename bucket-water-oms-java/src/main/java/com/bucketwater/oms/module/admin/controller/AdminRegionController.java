package com.bucketwater.oms.module.admin.controller;

import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.common.security.RequireRole;
import com.bucketwater.oms.module.admin.dto.CreateRegionRequest;
import com.bucketwater.oms.module.admin.dto.RegionDTO;
import com.bucketwater.oms.module.admin.dto.UpdateRegionRequest;
import com.bucketwater.oms.module.admin.service.AdminRegionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/admin/regions")
@RequiredArgsConstructor
@Tag(name = "地域管理", description = "地域区域管理相关接口")
@RequireRole({"PLATFORM_ADMIN", "FACTORY_ADMIN"})
public class AdminRegionController {

    private final AdminRegionService regionService;

    @GetMapping
    @Operation(summary = "获取地域列表")
    public Result<List<RegionDTO>> getRegions(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) Integer level) {
        List<RegionDTO> regions = regionService.getAllRegions(status, level);
        return Result.ok(regions);
    }

    @GetMapping("/tree")
    @Operation(summary = "获取地域树形结构")
    public Result<List<RegionDTO>> getRegionTree() {
        List<RegionDTO> tree = regionService.getRegionTree();
        return Result.ok(tree);
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取地域详情")
    public Result<RegionDTO> getRegionById(@PathVariable Long id) {
        RegionDTO region = regionService.getRegionById(id);
        return Result.ok(region);
    }

    @GetMapping("/code/{code}")
    @Operation(summary = "根据编码获取地域")
    public Result<RegionDTO> getRegionByCode(@PathVariable String code) {
        RegionDTO region = regionService.getRegionByCode(code);
        return Result.ok(region);
    }

    @GetMapping("/children/{parentCode}")
    @Operation(summary = "获取子地域")
    public Result<List<RegionDTO>> getChildren(@PathVariable String parentCode) {
        List<RegionDTO> children = regionService.getChildren(parentCode);
        return Result.ok(children);
    }

    @GetMapping("/provinces")
    @Operation(summary = "获取省份列表")
    public Result<List<RegionDTO>> getProvinces() {
        List<RegionDTO> provinces = regionService.getProvinces();
        return Result.ok(provinces);
    }

    @GetMapping("/cities/{provinceCode}")
    @Operation(summary = "获取城市列表")
    public Result<List<RegionDTO>> getCities(@PathVariable String provinceCode) {
        List<RegionDTO> cities = regionService.getCities(provinceCode);
        return Result.ok(cities);
    }

    @GetMapping("/districts/{cityCode}")
    @Operation(summary = "获取区县列表")
    public Result<List<RegionDTO>> getDistricts(@PathVariable String cityCode) {
        List<RegionDTO> districts = regionService.getDistricts(cityCode);
        return Result.ok(districts);
    }

    @PostMapping
    @Operation(summary = "创建地域")
    public Result<RegionDTO> createRegion(@RequestBody CreateRegionRequest request) {
        RegionDTO region = regionService.createRegion(request);
        return Result.ok(region);
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新地域")
    public Result<RegionDTO> updateRegion(
            @PathVariable Long id,
            @RequestBody UpdateRegionRequest request) {
        RegionDTO region = regionService.updateRegion(id, request);
        return Result.ok(region);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除地域")
    public Result<Void> deleteRegion(@PathVariable Long id) {
        regionService.deleteRegion(id);
        return Result.ok();
    }

    @PatchMapping("/{id}/enable")
    @Operation(summary = "启用地域")
    public Result<Void> enableRegion(@PathVariable Long id) {
        regionService.enableRegion(id);
        return Result.ok();
    }

    @PatchMapping("/{id}/disable")
    @Operation(summary = "停用地域")
    public Result<Void> disableRegion(@PathVariable Long id) {
        regionService.disableRegion(id);
        return Result.ok();
    }

    @PatchMapping("/{id}/sort")
    @Operation(summary = "更新排序")
    public Result<Void> updateSort(
            @PathVariable Long id,
            @RequestBody Map<String, Integer> body) {
        regionService.updateSort(id, body.get("sort"));
        return Result.ok();
    }

    @PatchMapping("/batch")
    @Operation(summary = "批量更新地域")
    public Result<Void> batchUpdate(@RequestBody Map<String, List<RegionDTO>> body) {
        regionService.batchUpdate(body.get("regions"));
        return Result.ok();
    }
}
