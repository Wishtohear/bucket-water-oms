package com.bucketwater.oms.module.admin.controller;

import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.common.security.RequireRole;
import com.bucketwater.oms.module.admin.dto.*;
import com.bucketwater.oms.module.admin.service.AdminInventoryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/admin/inventory")
@Tag(name = "管理端-库存管理", description = "库存监控和管理")
@RequireRole({"PLATFORM_ADMIN", "FACTORY_ADMIN"})
public class AdminInventoryController {

    @Autowired
    private AdminInventoryService inventoryService;

    @GetMapping("/overview")
    @Operation(summary = "获取库存概览", description = "获取各仓库的产品库存概览")
    public Result<InventoryOverviewDTO> getInventoryOverview(
            @RequestParam(required = false) @Parameter(description = "仓库ID") String warehouseId) {
        InventoryOverviewDTO overview = inventoryService.getInventoryOverview(warehouseId);
        return Result.ok(overview);
    }

    @GetMapping("/records")
    @Operation(summary = "获取出入库记录", description = "获取库存出入库明细记录")
    public Result<List<InventoryRecordDTO>> getInventoryRecords(
            @RequestParam(required = false) @Parameter(description = "仓库ID") String warehouseId,
            @RequestParam(required = false) @Parameter(description = "业务类型") String businessType,
            @RequestParam(required = false, defaultValue = "week") @Parameter(description = "时间范围: today/week/month") String dateRange) {
        List<InventoryRecordDTO> records = inventoryService.getInventoryRecords(warehouseId, businessType, dateRange);
        return Result.ok(records);
    }

    @PostMapping("/inbound")
    @Operation(summary = "入库登记", description = "登记产品入库")
    public Result<Void> recordInbound(@RequestBody InboundRequest request) {
        inventoryService.recordInbound(request);
        return Result.ok();
    }

    public static class InboundRequest {
        private String warehouseId;
        private String productId;
        private Integer quantity;
        private String type;
        private String operator;
        private String remark;

        public String getWarehouseId() { return warehouseId; }
        public void setWarehouseId(String warehouseId) { this.warehouseId = warehouseId; }
        public String getProductId() { return productId; }
        public void setProductId(String productId) { this.productId = productId; }
        public Integer getQuantity() { return quantity; }
        public void setQuantity(Integer quantity) { this.quantity = quantity; }
        public String getType() { return type; }
        public void setType(String type) { this.type = type; }
        public String getOperator() { return operator; }
        public void setOperator(String operator) { this.operator = operator; }
        public String getRemark() { return remark; }
        public void setRemark(String remark) { this.remark = remark; }
    }

    @GetMapping("/stats")
    @Operation(summary = "获取库存统计", description = "获取库存统计数据")
    public Result<?> getInventoryStats(
            @RequestParam(required = false) @Parameter(description = "仓库ID") String warehouseId) {
        var stats = inventoryService.getInventoryStats(warehouseId);
        return Result.ok(stats);
    }

    @GetMapping("/checks")
    @Operation(summary = "获取库存盘点记录", description = "获取所有库存盘点记录")
    public Result<List<InventoryCheckDTO>> getInventoryChecks(
            @RequestParam(required = false) @Parameter(description = "仓库ID") String warehouseId) {
        List<InventoryCheckDTO> checks = inventoryService.getInventoryCheckRecords(warehouseId);
        return Result.ok(checks);
    }

    @GetMapping("/checks/{checkId}")
    @Operation(summary = "获取库存盘点详情", description = "获取指定库存盘点记录的详细信息")
    public Result<InventoryCheckDTO> getInventoryCheckById(
            @PathVariable @Parameter(description = "盘点ID") String checkId) {
        InventoryCheckDTO check = inventoryService.getInventoryCheckById(checkId);
        return Result.ok(check);
    }

    @PostMapping("/checks")
    @Operation(summary = "创建库存盘点", description = "创建新的库存盘点记录")
    public Result<InventoryCheckDTO> createInventoryCheck(
            @RequestBody @Parameter(description = "盘点请求") CreateInventoryCheckRequest request) {
        InventoryCheckDTO check = inventoryService.createInventoryCheck(request);
        return Result.ok(check);
    }

    @PostMapping("/checks/{checkId}/confirm")
    @Operation(summary = "确认库存盘点", description = "确认库存盘点结果并调整库存")
    public Result<InventoryCheckDTO> confirmInventoryCheck(
            @PathVariable @Parameter(description = "盘点ID") String checkId) {
        InventoryCheckDTO check = inventoryService.confirmInventoryCheck(checkId);
        return Result.ok(check);
    }
}
