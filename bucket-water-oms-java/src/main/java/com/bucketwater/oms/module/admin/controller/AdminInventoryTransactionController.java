package com.bucketwater.oms.module.admin.controller;

import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.common.security.RequireRole;
import com.bucketwater.oms.module.inventory.dto.*;
import com.bucketwater.oms.module.inventory.service.InventoryCheckService;
import com.bucketwater.oms.module.inventory.service.ProductInventoryTransactionService;
import com.bucketwater.oms.module.product.entity.ProductInventory;
import com.bucketwater.oms.module.product.mapper.ProductInventoryMapper;
import com.bucketwater.oms.module.warehouse.entity.Warehouse;
import com.bucketwater.oms.module.warehouse.mapper.WarehouseMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/admin/inventory")
@Tag(name = "管理端库存模块", description = "管理端库存查询和盘点")
@RequireRole({"PLATFORM_ADMIN", "FACTORY_ADMIN"})
public class AdminInventoryTransactionController {

    @Autowired
    private ProductInventoryTransactionService transactionService;

    @Autowired
    private InventoryCheckService checkService;

    @Autowired
    private ProductInventoryMapper inventoryMapper;

    @Autowired
    private WarehouseMapper warehouseMapper;

    @GetMapping("/transactions")
    @Operation(summary = "查询库存变动记录", description = "分页查询库存变动记录，支持按仓库、产品、类型、日期筛选")
    public Result<PageResponse<ProductInventoryTransactionDTO>> queryTransactions(
            @RequestParam(required = false) @Parameter(description = "仓库ID") Long warehouseId,
            @RequestParam(required = false) @Parameter(description = "产品ID") Long productId,
            @RequestParam(required = false) @Parameter(description = "变动类型: INBOUND/OUTBOUND") String transactionType,
            @RequestParam(required = false) @Parameter(description = "明细类型") String detailType,
            @RequestParam(required = false) @Parameter(description = "开始日期 yyyy-MM-dd") String startDate,
            @RequestParam(required = false) @Parameter(description = "结束日期 yyyy-MM-dd") String endDate,
            @RequestParam(required = false) @Parameter(description = "关联订单号") String relatedOrderNo,
            @RequestParam(defaultValue = "1") @Parameter(description = "页码") Integer page,
            @RequestParam(defaultValue = "20") @Parameter(description = "每页数量") Integer size) {

        TransactionQueryRequest request = new TransactionQueryRequest();
        request.setWarehouseId(warehouseId);
        request.setProductId(productId);
        request.setTransactionType(transactionType);
        request.setDetailType(detailType);
        request.setStartDate(startDate);
        request.setEndDate(endDate);
        request.setRelatedOrderNo(relatedOrderNo);
        request.setPage(page);
        request.setSize(size);

        PageResponse<ProductInventoryTransactionDTO> result = transactionService.queryTransactions(request);
        return Result.ok(result);
    }

    @GetMapping("/transactions/{id}")
    @Operation(summary = "获取变动记录详情", description = "根据ID获取库存变动记录详情")
    public Result<ProductInventoryTransactionDTO> getTransactionById(
            @PathVariable @Parameter(description = "变动记录ID") Long id) {
        ProductInventoryTransactionDTO dto = transactionService.getTransactionById(id);
        return Result.ok(dto);
    }

    @GetMapping("/transactions/warehouse/{warehouseId}")
    @Operation(summary = "获取仓库的所有产品变动记录", description = "获取指定仓库所有产品的出入库记录")
    public Result<List<ProductInventoryTransactionDTO>> getTransactionsByWarehouse(
            @PathVariable @Parameter(description = "仓库ID") Long warehouseId,
            @RequestParam(required = false) @Parameter(description = "产品ID") Long productId,
            @RequestParam(required = false) @Parameter(description = "变动类型: INBOUND/OUTBOUND") String transactionType) {

        List<ProductInventoryTransactionDTO> transactions;
        if (productId != null) {
            transactions = transactionService.getTransactionsByProduct(warehouseId, productId);
        } else {
            TransactionQueryRequest request = new TransactionQueryRequest();
            request.setWarehouseId(warehouseId);
            request.setTransactionType(transactionType);
            request.setPage(1);
            request.setSize(1000);
            PageResponse<ProductInventoryTransactionDTO> result = transactionService.queryTransactions(request);
            transactions = result.getRecords();
        }
        return Result.ok(transactions);
    }

    @GetMapping("/check/tasks")
    @Operation(summary = "查询盘点任务", description = "分页查询盘点任务列表")
    public Result<PageResponse<InventoryCheckTaskDTO>> queryCheckTasks(
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

    @GetMapping("/check/tasks/{taskId}")
    @Operation(summary = "获取盘点任务详情", description = "根据ID获取盘点任务详情，包含所有盘点明细")
    public Result<InventoryCheckTaskDTO> getCheckTaskById(
            @PathVariable @Parameter(description = "任务ID") Long taskId) {
        InventoryCheckTaskDTO dto = checkService.getTaskById(taskId);
        return Result.ok(dto);
    }

    @PostMapping("/check/tasks")
    @Operation(summary = "创建盘点任务", description = "创建新的库存盘点任务")
    public Result<InventoryCheckTaskDTO> createCheckTask(
            @Valid @RequestBody CreateInventoryCheckRequest request) {
        InventoryCheckTaskDTO dto = checkService.createCheckTask(request.getWarehouseId(), "系统", request);
        return Result.ok(dto);
    }

    @PostMapping("/check/tasks/{taskId}/confirm")
    @Operation(summary = "确认盘点任务", description = "确认盘点任务完成，根据盘点结果调整库存")
    public Result<InventoryCheckTaskDTO> confirmCheckTask(
            @PathVariable @Parameter(description = "任务ID") Long taskId,
            @RequestHeader(value = "X-Operator", defaultValue = "系统") @Parameter(description = "操作人") String operator) {
        InventoryCheckTaskDTO dto = checkService.confirmTask(taskId, operator);
        return Result.ok(dto);
    }

    @GetMapping("/check/records")
    @Operation(summary = "查询盘点记录", description = "分页查询所有产品的盘点记录")
    public Result<PageResponse<ProductInventoryCheckDTO>> queryCheckRecords(
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

    @GetMapping("/check/{checkId}")
    @Operation(summary = "获取盘点记录详情", description = "获取单个产品的盘点记录详情")
    public Result<ProductInventoryCheckDTO> getCheckRecordById(
            @PathVariable @Parameter(description = "盘点记录ID") Long checkId,
            @RequestParam(required = false) @Parameter(description = "仓库ID") Long warehouseId) {

        InventoryCheckQueryRequest request = new InventoryCheckQueryRequest();
        request.setWarehouseId(warehouseId);
        request.setPage(1);
        request.setSize(1000);
        PageResponse<ProductInventoryCheckDTO> result = checkService.queryCheckRecords(request);

        ProductInventoryCheckDTO record = result.getRecords().stream()
            .filter(r -> r.getId().equals(checkId))
            .findFirst()
            .orElse(null);

        return Result.ok(record);
    }

    @GetMapping("/transaction-overview")
    @Operation(summary = "获取库存交易概览", description = "获取所有仓库的库存交易概览信息")
    public Result<Map<String, Object>> getOverview() {
        List<Warehouse> warehouses = warehouseMapper.selectList(null);
        List<Map<String, Object>> warehouseStats = warehouses.stream().map(warehouse -> {
            Map<String, Object> stats = new HashMap<>();
            stats.put("warehouseId", warehouse.getId());
            stats.put("warehouseName", warehouse.getName());
            stats.put("totalProducts", inventoryMapper.selectCount(null));
            return stats;
        }).collect(Collectors.toList());

        Map<String, Object> overview = new HashMap<>();
        overview.put("warehouses", warehouseStats);
        overview.put("totalWarehouses", warehouses.size());

        return Result.ok(overview);
    }

    @GetMapping("/stock/{warehouseId}")
    @Operation(summary = "获取仓库库存", description = "获取指定仓库的所有产品库存")
    public Result<List<ProductInventory>> getWarehouseStock(
            @PathVariable @Parameter(description = "仓库ID") Long warehouseId) {
        List<ProductInventory> inventories = inventoryMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<ProductInventory>()
                .eq("warehouse_id", warehouseId)
        );
        return Result.ok(inventories);
    }
}
