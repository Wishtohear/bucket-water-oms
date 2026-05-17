package com.bucketwater.oms.module.warehouse.controller;

import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.module.warehouse.dto.CheckInboundRequest;
import com.bucketwater.oms.module.warehouse.dto.CreateInboundRequest;
import com.bucketwater.oms.module.warehouse.dto.WarehouseInboundDTO;
import com.bucketwater.oms.module.warehouse.service.WarehouseInboundService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/warehouses/inbound")
@Tag(name = "仓库入库模块", description = "仓库采购入库管理")
public class WarehouseInboundController {

    @Autowired
    private WarehouseInboundService inboundService;

    @GetMapping
    @Operation(summary = "获取入库列表", description = "获取仓库入库单列表")
    public Result<List<WarehouseInboundDTO>> getInboundList(
            @RequestHeader("X-Warehouse-Id") @Parameter(description = "仓库ID") Long warehouseId,
            @RequestParam(required = false) @Parameter(description = "状态") String status) {
        List<WarehouseInboundDTO> inbounds = inboundService.getInboundList(warehouseId, status);
        return Result.ok(inbounds);
    }

    @GetMapping("/{inboundId}")
    @Operation(summary = "获取入库详情", description = "获取入库单详细信息")
    public Result<WarehouseInboundDTO> getInbound(
            @PathVariable @Parameter(description = "入库ID") Long inboundId) {
        WarehouseInboundDTO inbound = inboundService.getInboundById(inboundId);
        return Result.ok(inbound);
    }

    @PostMapping
    @Operation(summary = "创建入库单", description = "创建采购入库单")
    public Result<WarehouseInboundDTO> createInbound(
            @RequestHeader("X-Warehouse-Id") @Parameter(description = "仓库ID") Long warehouseId,
            @RequestHeader(value = "X-Operator", defaultValue = "系统") @Parameter(description = "操作人") String operator,
            @Valid @RequestBody CreateInboundRequest request) {
        WarehouseInboundDTO inbound = inboundService.createInbound(warehouseId, operator, request);
        return Result.ok(inbound);
    }

    @PostMapping("/{inboundId}/check")
    @Operation(summary = "审核入库单", description = "审核入库单，同意或拒绝")
    public Result<WarehouseInboundDTO> checkInbound(
            @PathVariable @Parameter(description = "入库ID") Long inboundId,
            @Valid @RequestBody CheckInboundRequest request) {
        WarehouseInboundDTO inbound = inboundService.checkInbound(inboundId, request);
        return Result.ok(inbound);
    }
}
