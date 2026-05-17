package com.bucketwater.oms.module.product.controller;

import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.module.product.dto.BatchProductRequest;
import com.bucketwater.oms.module.product.dto.ProductDTO;
import com.bucketwater.oms.module.product.entity.ProductInventory;
import com.bucketwater.oms.module.product.service.ProductService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/products")
@Tag(name = "产品模块", description = "商品查询、库存查询、批量操作")
public class ProductController {

    @Autowired
    private ProductService productService;

    @GetMapping
    @Operation(summary = "获取商品列表", description = "获取所有商品或按分类筛选")
    public Result<ProductDTO> getProducts(
            @RequestParam(required = false) @Parameter(description = "分类") String category) {
        ProductDTO products = productService.getProducts(category);
        return Result.ok(products);
    }

    @GetMapping("/warehouses/{warehouseId}/inventory")
    @Operation(summary = "获取仓库库存", description = "获取指定仓库的商品库存")
    public Result<List<ProductInventory>> getWarehouseInventory(
            @PathVariable @Parameter(description = "仓库ID") Long warehouseId) {
        List<ProductInventory> inventory = productService.getWarehouseInventory(warehouseId);
        return Result.ok(inventory);
    }

    @PostMapping("/batch/status")
    @Operation(summary = "批量更新商品状态", description = "批量启用/禁用商品")
    public Result<Map<String, Object>> batchUpdateStatus(
            @RequestBody BatchProductRequest request) {
        int count = productService.batchUpdateStatus(request.getProductIds(), request.getStatus());
        return Result.ok(Map.of("success", true, "count", count, "message", "成功更新 " + count + " 个商品状态"));
    }

    @PostMapping("/batch/price")
    @Operation(summary = "批量修改价格", description = "批量修改商品指导价")
    public Result<Map<String, Object>> batchUpdatePrice(
            @RequestBody BatchProductRequest request) {
        int count = productService.batchUpdatePrice(
            request.getProductIds(), 
            request.getGuidePrice(), 
            request.getGuidePriceMax()
        );
        return Result.ok(Map.of("success", true, "count", count, "message", "成功更新 " + count + " 个商品价格"));
    }

    @PostMapping("/batch/enable")
    @Operation(summary = "批量启用商品", description = "批量启用商品")
    public Result<Map<String, Object>> batchEnable(
            @RequestBody BatchProductRequest request) {
        int count = productService.batchEnableProducts(request.getProductIds(), true);
        return Result.ok(Map.of("success", true, "count", count, "message", "成功启用 " + count + " 个商品"));
    }

    @PostMapping("/batch/disable")
    @Operation(summary = "批量禁用商品", description = "批量禁用商品")
    public Result<Map<String, Object>> batchDisable(
            @RequestBody BatchProductRequest request) {
        int count = productService.batchEnableProducts(request.getProductIds(), false);
        return Result.ok(Map.of("success", true, "count", count, "message", "成功禁用 " + count + " 个商品"));
    }

    @PostMapping("/batch/safe-stock")
    @Operation(summary = "批量修改安全库存", description = "批量修改商品安全库存")
    public Result<Map<String, Object>> batchUpdateSafeStock(
            @RequestBody BatchProductRequest request) {
        int count = productService.batchUpdateSafeStock(request.getProductIds(), request.getSafeStock());
        return Result.ok(Map.of("success", true, "count", count, "message", "成功更新 " + count + " 个商品安全库存"));
    }
}
