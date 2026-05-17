package com.bucketwater.oms.module.inventory.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.module.inventory.dto.InventoryAdjustmentDTO;
import com.bucketwater.oms.module.inventory.dto.InventoryAdjustmentRequest;
import com.bucketwater.oms.module.inventory.service.InventoryAdjustmentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/warehouses/inventory/adjustments")
@Tag(name = "库存调整审批模块", description = "库存调整申请和审批管理")
public class InventoryAdjustmentController {

    @Autowired
    private InventoryAdjustmentService adjustmentService;

    @GetMapping
    @Operation(summary = "查询库存调整单", description = "分页查询库存调整单列表")
    public Result<Page<InventoryAdjustmentDTO>> queryAdjustments(
            @RequestParam(required = false) @Parameter(description = "仓库ID") Long warehouseId,
            @RequestParam(required = false) @Parameter(description = "状态") String status,
            @RequestParam(defaultValue = "1") @Parameter(description = "页码") Integer page,
            @RequestParam(defaultValue = "20") @Parameter(description = "每页数量") Integer size) {
        Page<InventoryAdjustmentDTO> result = adjustmentService.queryAdjustments(warehouseId, status, page, size);
        return Result.ok(result);
    }

    @GetMapping("/{adjustmentId}")
    @Operation(summary = "获取库存调整单详情", description = "根据ID获取库存调整单详情")
    public Result<InventoryAdjustmentDTO> getAdjustmentById(
            @PathVariable @Parameter(description = "调整单ID") Long adjustmentId) {
        InventoryAdjustmentDTO dto = adjustmentService.getAdjustmentById(adjustmentId);
        return Result.ok(dto);
    }

    @PostMapping
    @Operation(summary = "创建库存调整单", description = "创建新的库存调整单（待审批状态）")
    public Result<InventoryAdjustmentDTO> createAdjustment(
            @RequestHeader("X-Warehouse-Id") @Parameter(description = "仓库ID") Long warehouseId,
            @RequestHeader(value = "X-Operator", defaultValue = "系统") @Parameter(description = "申请人") String applicant,
            @Valid @RequestBody InventoryAdjustmentRequest request) {
        InventoryAdjustmentDTO dto = adjustmentService.createAdjustment(warehouseId, applicant, request);
        return Result.ok(dto);
    }

    @PostMapping("/{adjustmentId}/approve")
    @Operation(summary = "审批通过库存调整单", description = "审批通过库存调整单，执行库存变更")
    public Result<InventoryAdjustmentDTO> approveAdjustment(
            @PathVariable @Parameter(description = "调整单ID") Long adjustmentId,
            @RequestHeader(value = "X-Operator", defaultValue = "系统") @Parameter(description = "审批人") String approver,
            @RequestParam(required = false) @Parameter(description = "审批备注") String remark) {
        InventoryAdjustmentDTO dto = adjustmentService.approveAdjustment(adjustmentId, approver, remark);
        return Result.ok(dto);
    }

    @PostMapping("/{adjustmentId}/reject")
    @Operation(summary = "拒绝库存调整单", description = "拒绝库存调整单")
    public Result<InventoryAdjustmentDTO> rejectAdjustment(
            @PathVariable @Parameter(description = "调整单ID") Long adjustmentId,
            @RequestHeader(value = "X-Operator", defaultValue = "系统") @Parameter(description = "审批人") String approver,
            @RequestParam(required = false) @Parameter(description = "拒绝原因") String remark) {
        InventoryAdjustmentDTO dto = adjustmentService.rejectAdjustment(adjustmentId, approver, remark);
        return Result.ok(dto);
    }
}
