package com.bucketwater.oms.module.inventory.controller;

import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.module.inventory.dto.*;
import com.bucketwater.oms.module.inventory.service.ProductInventoryTransactionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/warehouses/inventory/transactions")
@Tag(name = "产品库存变动模块", description = "产品库存出入库记录查询")
public class InventoryTransactionController {

    @Autowired
    private ProductInventoryTransactionService transactionService;

    @GetMapping
    @Operation(summary = "查询库存变动记录", description = "分页查询仓库的库存变动记录，支持按产品、类型、日期筛选")
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

    @GetMapping("/{id}")
    @Operation(summary = "获取变动记录详情", description = "根据ID获取库存变动记录详情")
    public Result<ProductInventoryTransactionDTO> getTransactionById(
            @PathVariable @Parameter(description = "变动记录ID") Long id) {
        ProductInventoryTransactionDTO dto = transactionService.getTransactionById(id);
        return Result.ok(dto);
    }

    @GetMapping("/product/{productId}")
    @Operation(summary = "获取产品变动记录", description = "获取指定产品的所有出入库记录")
    public Result<List<ProductInventoryTransactionDTO>> getTransactionsByProduct(
            @RequestHeader("X-Warehouse-Id") @Parameter(description = "仓库ID") Long warehouseId,
            @PathVariable @Parameter(description = "产品ID") Long productId) {
        List<ProductInventoryTransactionDTO> transactions = transactionService.getTransactionsByProduct(warehouseId, productId);
        return Result.ok(transactions);
    }

    @GetMapping("/order/{orderNo}")
    @Operation(summary = "获取订单变动记录", description = "获取关联指定订单的所有库存变动记录")
    public Result<List<ProductInventoryTransactionDTO>> getTransactionsByOrder(
            @RequestHeader("X-Warehouse-Id") @Parameter(description = "仓库ID") Long warehouseId,
            @PathVariable @Parameter(description = "订单号") String orderNo) {
        List<ProductInventoryTransactionDTO> transactions = transactionService.getTransactionsByOrder(warehouseId, orderNo);
        return Result.ok(transactions);
    }

    @GetMapping("/stock/{productId}")
    @Operation(summary = "获取产品当前库存", description = "获取指定产品的当前库存数量")
    public Result<Integer> getCurrentStock(
            @RequestHeader("X-Warehouse-Id") @Parameter(description = "仓库ID") Long warehouseId,
            @PathVariable @Parameter(description = "产品ID") Long productId) {
        Integer stock = transactionService.getCurrentStock(warehouseId, productId);
        return Result.ok(stock);
    }

    @PostMapping("/inbound")
    @Operation(summary = "创建入库记录", description = "创建产品入库记录，同时更新库存")
    public Result<List<ProductInventoryTransactionDTO>> createInbound(
            @RequestHeader("X-Warehouse-Id") @Parameter(description = "仓库ID") Long warehouseId,
            @RequestHeader(value = "X-Operator", defaultValue = "系统") @Parameter(description = "操作人") String operator,
            @Valid @RequestBody CreateInboundTransactionRequest request) {
        List<ProductInventoryTransactionDTO> transactions = transactionService.createInboundTransactions(warehouseId, operator, request);
        return Result.ok(transactions);
    }
}
