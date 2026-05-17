package com.bucketwater.oms.module.admin.controller;

import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.common.security.RequireRole;
import com.bucketwater.oms.module.admin.service.AdminProductService;
import com.bucketwater.oms.module.export.service.ExcelExportService;
import com.bucketwater.oms.module.product.entity.Product;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;

import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletResponse;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/admin/products")
@Tag(name = "管理端-产品管理", description = "产品管理")
@RequireRole({"PLATFORM_ADMIN", "FACTORY_ADMIN"})
public class AdminProductController {

    @Autowired
    private AdminProductService adminProductService;

    @Autowired
    private ExcelExportService excelExportService;

    @GetMapping
    @Operation(summary = "获取产品列表", description = "获取所有产品列表")
    public Result<List<Product>> getAllProducts(
            @RequestParam(required = false) @Parameter(description = "分类") String category,
            @RequestParam(required = false) @Parameter(description = "状态") String status,
            @RequestParam(required = false) @Parameter(description = "关键词") String keyword) {
        List<Product> products = adminProductService.getAllProducts(category, status);
        return Result.ok(products);
    }

    @GetMapping("/export")
    @Operation(summary = "导出产品列表", description = "导出产品列表到Excel")
    public void exportProducts(
            @RequestParam(required = false) @Parameter(description = "分类") String category,
            @RequestParam(required = false) @Parameter(description = "状态") String status,
            @RequestParam(required = false) @Parameter(description = "关键词") String keyword,
            HttpServletResponse response) {
        try {
            byte[] excelData = excelExportService.exportProducts(category, status, keyword);

            String filename = "产品列表_" + java.time.LocalDate.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyyMMdd")) + ".xlsx";
            String encodedFilename = URLEncoder.encode(filename, StandardCharsets.UTF_8);

            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setHeader(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + encodedFilename + "\"; filename*=UTF-8''" + encodedFilename);
            response.setContentLength(excelData.length);
            response.getOutputStream().write(excelData);
            response.getOutputStream().flush();
        } catch (Exception e) {
            throw new RuntimeException("导出Excel失败: " + e.getMessage());
        }
    }

    @GetMapping("/{productId}")
    @Operation(summary = "获取产品详情", description = "获取产品详细信息")
    public Result<Product> getProduct(
            @PathVariable @Parameter(description = "产品ID") Long productId) {
        Product product = adminProductService.getProductById(productId);
        return Result.ok(product);
    }

    @PostMapping
    @Operation(summary = "创建产品", description = "创建新产品")
    public Result<Product> createProduct(@RequestBody Product request) {
        Product product = adminProductService.createProduct(request);
        return Result.ok(product);
    }

    @PutMapping("/{productId}")
    @Operation(summary = "更新产品", description = "更新产品信息")
    public Result<Product> updateProduct(
            @PathVariable @Parameter(description = "产品ID") Long productId,
            @RequestBody Product request) {
        Product product = adminProductService.updateProduct(productId, request);
        return Result.ok(product);
    }

    @PutMapping("/{productId}/status")
    @Operation(summary = "更新产品状态", description = "启用/停用产品")
    public Result<Void> updateProductStatus(
            @PathVariable @Parameter(description = "产品ID") Long productId,
            @RequestParam @Parameter(description = "状态") String status) {
        adminProductService.updateProductStatus(productId, status);
        return Result.ok();
    }

    @DeleteMapping("/{productId}")
    @Operation(summary = "删除产品", description = "删除指定产品")
    public Result<Void> deleteProduct(
            @PathVariable @Parameter(description = "产品ID") Long productId) {
        adminProductService.deleteProduct(productId);
        return Result.ok();
    }

    @GetMapping("/categories")
    @Operation(summary = "获取产品分类", description = "获取产品分类统计")
    public Result<List<Map<String, Object>>> getCategories() {
        List<Map<String, Object>> categories = adminProductService.getCategories();
        return Result.ok(categories);
    }

    @GetMapping("/stats")
    @Operation(summary = "获取产品统计", description = "获取产品统计信息")
    public Result<Map<String, Object>> getStats() {
        Map<String, Object> stats = adminProductService.getStats();
        return Result.ok(stats);
    }

    @GetMapping("/{productId}/warehouse-inventory")
    @Operation(summary = "获取产品各仓库库存", description = "获取产品在各仓库的库存详情")
    public Result<List<Map<String, Object>>> getProductWarehouseInventory(
            @PathVariable @Parameter(description = "产品ID") Long productId) {
        List<Map<String, Object>> inventory = adminProductService.getProductWarehouseInventory(productId);
        return Result.ok(inventory);
    }

    @PatchMapping("/{productId}/batch-price")
    @Operation(summary = "批量更新价格", description = "批量更新产品价格")
    public Result<Void> batchUpdatePrice(
            @PathVariable @Parameter(description = "产品ID") Long productId,
            @RequestBody Map<String, Object> request) {
        return Result.ok();
    }
}
