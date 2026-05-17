package com.bucketwater.oms.module.warehouse.controller;

import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.module.warehouse.dto.WarehouseOutboundDTO;
import com.bucketwater.oms.module.warehouse.service.WarehouseOutboundService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@RestController
@RequestMapping("/warehouses/outbound")
@Tag(name = "仓库出库模块", description = "仓库订单出库管理")
public class WarehouseOutboundController {

    @Autowired
    private WarehouseOutboundService outboundService;

    @GetMapping
    @Operation(summary = "获取出库列表", description = "获取仓库出库单列表")
    public Result<List<WarehouseOutboundDTO>> getOutboundList(
            @RequestHeader("X-Warehouse-Id") @Parameter(description = "仓库ID") Long warehouseId,
            @RequestParam(required = false) @Parameter(description = "状态") String status) {
        List<WarehouseOutboundDTO> outbounds = outboundService.getOutboundList(warehouseId, status);
        return Result.ok(outbounds);
    }

    @GetMapping("/{outboundId}")
    @Operation(summary = "获取出库详情", description = "获取出库单详细信息")
    public Result<WarehouseOutboundDTO> getOutbound(
            @PathVariable @Parameter(description = "出库ID") Long outboundId) {
        WarehouseOutboundDTO outbound = outboundService.getOutboundById(outboundId);
        return Result.ok(outbound);
    }

    @PostMapping("/order/{orderId}")
    @Operation(summary = "创建订单出库单", description = "根据订单创建出库单")
    public Result<WarehouseOutboundDTO> createOutboundForOrder(
            @RequestHeader("X-Warehouse-Id") @Parameter(description = "仓库ID") Long warehouseId,
            @RequestHeader(value = "X-Operator", defaultValue = "系统") @Parameter(description = "操作人") String operator,
            @PathVariable @Parameter(description = "订单ID") Long orderId) {
        WarehouseOutboundDTO outbound = outboundService.createOutboundForOrder(warehouseId, orderId, operator);
        return Result.ok(outbound);
    }

    @PostMapping("/{outboundId}/confirm")
    @Operation(summary = "确认出库", description = "确认出库单完成")
    public Result<WarehouseOutboundDTO> confirmOutbound(
            @PathVariable @Parameter(description = "出库ID") Long outboundId) {
        WarehouseOutboundDTO outbound = outboundService.confirmOutbound(outboundId);
        return Result.ok(outbound);
    }
}
