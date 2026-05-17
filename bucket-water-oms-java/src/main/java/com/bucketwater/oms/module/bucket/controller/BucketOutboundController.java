package com.bucketwater.oms.module.bucket.controller;

import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.module.bucket.dto.*;
import com.bucketwater.oms.module.bucket.service.BucketOutboundService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 空桶出库控制器
 */
@RestController
@RequestMapping("/warehouses/bucket-outbound")
@Tag(name = "空桶出库模块", description = "空桶出库管理")
public class BucketOutboundController {

    @Autowired
    private BucketOutboundService bucketOutboundService;

    @GetMapping
    @Operation(summary = "获取空桶出库列表", description = "获取仓库的空桶出库列表")
    public Result<List<BucketOutboundDTO>> getOutboundList(
            @RequestHeader("X-Warehouse-Id") @Parameter(description = "仓库ID") Long warehouseId,
            @RequestParam(required = false) @Parameter(description = "状态: pending/confirmed/rejected") String status,
            @RequestParam(defaultValue = "1") @Parameter(description = "页码") Integer page,
            @RequestParam(defaultValue = "20") @Parameter(description = "每页数量") Integer size) {
        List<BucketOutboundDTO> list = bucketOutboundService.getOutboundList(warehouseId, status, page, size);
        return Result.ok(list);
    }

    @GetMapping("/{outboundId}")
    @Operation(summary = "获取出库单详情", description = "获取空桶出库单详细信息")
    public Result<BucketOutboundDTO> getOutboundDetail(
            @PathVariable @Parameter(description = "出库单ID") Long outboundId) {
        BucketOutboundDTO dto = bucketOutboundService.getOutboundDetail(outboundId);
        return Result.ok(dto);
    }

    @PostMapping
    @Operation(summary = "创建空桶出库", description = "创建新的空桶出库单")
    public Result<BucketOutboundDTO> createOutbound(
            @RequestHeader("X-Warehouse-Id") @Parameter(description = "仓库ID") Long warehouseId,
            @Valid @RequestBody CreateBucketOutboundRequest request) {
        request.setWarehouseId(warehouseId);
        BucketOutboundDTO dto = bucketOutboundService.createOutbound(request);
        return Result.ok(dto);
    }

    @PostMapping("/{outboundId}/confirm")
    @Operation(summary = "确认出库", description = "确认空桶出库，更新库存")
    public Result<BucketOutboundDTO> confirmOutbound(
            @PathVariable @Parameter(description = "出库单ID") Long outboundId,
            @Valid @RequestBody ConfirmBucketOutboundRequest request) {
        BucketOutboundDTO dto = bucketOutboundService.confirmOutbound(outboundId, request);
        return Result.ok(dto);
    }

    @PostMapping("/{outboundId}/reject")
    @Operation(summary = "拒绝出库", description = "拒绝空桶出库单")
    public Result<BucketOutboundDTO> rejectOutbound(
            @PathVariable @Parameter(description = "出库单ID") Long outboundId,
            @RequestParam @Parameter(description = "拒绝原因") String reason,
            @RequestParam(required = false) @Parameter(description = "操作人") String operator) {
        BucketOutboundDTO dto = bucketOutboundService.rejectOutbound(outboundId, reason, operator);
        return Result.ok(dto);
    }
}
