package com.bucketwater.oms.module.bucket.controller;

import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.module.bucket.dto.*;
import com.bucketwater.oms.module.bucket.service.BucketInboundService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 空桶入库控制器
 */
@RestController
@RequestMapping("/warehouses/bucket-inbound")
@Tag(name = "空桶入库模块", description = "空桶入库管理")
public class BucketInboundController {

    @Autowired
    private BucketInboundService bucketInboundService;

    @GetMapping
    @Operation(summary = "获取空桶入库列表", description = "获取仓库的空桶入库列表")
    public Result<List<BucketInboundDTO>> getInboundList(
            @RequestHeader("X-Warehouse-Id") @Parameter(description = "仓库ID") Long warehouseId,
            @RequestParam(required = false) @Parameter(description = "状态: pending/confirmed/rejected") String status,
            @RequestParam(defaultValue = "1") @Parameter(description = "页码") Integer page,
            @RequestParam(defaultValue = "20") @Parameter(description = "每页数量") Integer size) {
        List<BucketInboundDTO> list = bucketInboundService.getInboundList(warehouseId, status, page, size);
        return Result.ok(list);
    }

    @GetMapping("/{inboundId}")
    @Operation(summary = "获取入库单详情", description = "获取空桶入库单详细信息")
    public Result<BucketInboundDTO> getInboundDetail(
            @PathVariable @Parameter(description = "入库单ID") Long inboundId) {
        BucketInboundDTO dto = bucketInboundService.getInboundDetail(inboundId);
        return Result.ok(dto);
    }

    @PostMapping
    @Operation(summary = "创建空桶入库", description = "创建新的空桶入库单")
    public Result<BucketInboundDTO> createInbound(
            @RequestHeader("X-Warehouse-Id") @Parameter(description = "仓库ID") Long warehouseId,
            @Valid @RequestBody CreateBucketInboundRequest request) {
        request.setWarehouseId(warehouseId);
        BucketInboundDTO dto = bucketInboundService.createInbound(request);
        return Result.ok(dto);
    }

    @PostMapping("/{inboundId}/confirm")
    @Operation(summary = "确认入库", description = "确认空桶入库，更新库存")
    public Result<BucketInboundDTO> confirmInbound(
            @PathVariable @Parameter(description = "入库单ID") Long inboundId,
            @Valid @RequestBody ConfirmBucketInboundRequest request) {
        BucketInboundDTO dto = bucketInboundService.confirmInbound(inboundId, request);
        return Result.ok(dto);
    }

    @PostMapping("/{inboundId}/reject")
    @Operation(summary = "拒绝入库", description = "拒绝空桶入库单")
    public Result<BucketInboundDTO> rejectInbound(
            @PathVariable @Parameter(description = "入库单ID") Long inboundId,
            @RequestParam @Parameter(description = "拒绝原因") String reason,
            @RequestParam(required = false) @Parameter(description = "操作人") String operator) {
        BucketInboundDTO dto = bucketInboundService.rejectInbound(inboundId, reason, operator);
        return Result.ok(dto);
    }
}
