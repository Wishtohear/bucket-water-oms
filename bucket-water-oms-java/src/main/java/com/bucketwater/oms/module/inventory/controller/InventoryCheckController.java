package com.bucketwater.oms.module.inventory.controller;

import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.module.inventory.dto.*;
import com.bucketwater.oms.module.inventory.service.InventoryCheckService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/warehouses/inventory/check")
@Tag(name = "库存盘点模块", description = "库存盘点管理")
public class InventoryCheckController {

    @Autowired
    private InventoryCheckService checkService;

    @GetMapping("/tasks")
    @Operation(summary = "查询盘点任务", description = "分页查询盘点任务列表")
    public Result<PageResponse<InventoryCheckTaskDTO>> queryTasks(
            @RequestParam(required = false) @Parameter(description = "仓库ID") Long warehouseId,
            @RequestParam(required = false) @Parameter(description = "状态") String status,
            @RequestParam(required = false) @Parameter(description = "开始日期 yyyy-MM-dd") String startDate,
            @RequestParam(required = false) @Parameter(description = "结束日期 yyyy-MM-dd") String endDate,
            @RequestParam(defaultValue = "1") @Parameter(description = "页码") Integer page,
            @RequestParam(defaultValue = "20") @Parameter(description = "每页数量") Integer size) {

        InventoryCheckQueryRequest request = new InventoryCheckQueryRequest();
        request.setWarehouseId(warehouseId);
        request.setStatus(status);
        request.setStartDate(startDate);
        request.setEndDate(endDate);
        request.setPage(page);
        request.setSize(size);

        PageResponse<InventoryCheckTaskDTO> result = checkService.queryTasks(request);
        return Result.ok(result);
    }

    @GetMapping("/tasks/{taskId}")
    @Operation(summary = "获取盘点任务详情", description = "根据ID获取盘点任务详情，包含所有盘点明细")
    public Result<InventoryCheckTaskDTO> getTaskById(
            @PathVariable @Parameter(description = "任务ID") Long taskId) {
        InventoryCheckTaskDTO dto = checkService.getTaskById(taskId);
        return Result.ok(dto);
    }

    @PostMapping("/tasks")
    @Operation(summary = "创建盘点任务", description = "创建新的库存盘点任务")
    public Result<InventoryCheckTaskDTO> createTask(
            @RequestHeader("X-Warehouse-Id") @Parameter(description = "仓库ID") Long warehouseId,
            @RequestHeader(value = "X-Operator", defaultValue = "系统") @Parameter(description = "操作人") String operator,
            @Valid @RequestBody CreateInventoryCheckRequest request) {
        request.setWarehouseId(warehouseId);
        InventoryCheckTaskDTO dto = checkService.createCheckTask(warehouseId, operator, request);
        return Result.ok(dto);
    }

    @PutMapping("/tasks/{taskId}/items/{productId}")
    @Operation(summary = "更新盘点明细", description = "更新指定产品的实际库存数量")
    public Result<InventoryCheckTaskDTO> updateTaskItem(
            @PathVariable @Parameter(description = "任务ID") Long taskId,
            @PathVariable @Parameter(description = "产品ID") Long productId,
            @RequestParam @Parameter(description = "实际库存数量") Integer actualQuantity,
            @RequestParam(required = false) @Parameter(description = "备注") String remark) {
        InventoryCheckTaskDTO dto = checkService.updateTaskItem(taskId, productId, actualQuantity, remark);
        return Result.ok(dto);
    }

    @PostMapping("/tasks/{taskId}/confirm")
    @Operation(summary = "确认盘点任务", description = "确认盘点任务完成，根据盘点结果调整库存")
    public Result<InventoryCheckTaskDTO> confirmTask(
            @PathVariable @Parameter(description = "任务ID") Long taskId,
            @RequestHeader(value = "X-Operator", defaultValue = "系统") @Parameter(description = "操作人") String operator) {
        InventoryCheckTaskDTO dto = checkService.confirmTask(taskId, operator);
        return Result.ok(dto);
    }

    @GetMapping("/records")
    @Operation(summary = "查询盘点记录", description = "分页查询所有产品的盘点记录")
    public Result<PageResponse<ProductInventoryCheckDTO>> queryRecords(
            @RequestParam(required = false) @Parameter(description = "仓库ID") Long warehouseId,
            @RequestParam(required = false) @Parameter(description = "产品ID") Long productId,
            @RequestParam(required = false) @Parameter(description = "状态") String status,
            @RequestParam(required = false) @Parameter(description = "开始日期 yyyy-MM-dd") String startDate,
            @RequestParam(required = false) @Parameter(description = "结束日期 yyyy-MM-dd") String endDate,
            @RequestParam(defaultValue = "1") @Parameter(description = "页码") Integer page,
            @RequestParam(defaultValue = "20") @Parameter(description = "每页数量") Integer size) {

        InventoryCheckQueryRequest request = new InventoryCheckQueryRequest();
        request.setWarehouseId(warehouseId);
        request.setProductId(productId);
        request.setStatus(status);
        request.setStartDate(startDate);
        request.setEndDate(endDate);
        request.setPage(page);
        request.setSize(size);

        PageResponse<ProductInventoryCheckDTO> result = checkService.queryCheckRecords(request);
        return Result.ok(result);
    }
}
