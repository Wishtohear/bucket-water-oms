package com.bucketwater.oms.module.aftersales.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.aftersales.dto.*;
import com.bucketwater.oms.module.aftersales.entity.AfterSales;
import com.bucketwater.oms.module.aftersales.service.AfterSalesService;
import com.bucketwater.oms.module.user.entity.User;
import com.bucketwater.oms.common.security.JwtAuthenticationFilter;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/after-sales")
@Tag(name = "售后模块", description = "售后申请、售后处理")
public class AfterSalesController {

    @Autowired
    private AfterSalesService afterSalesService;

    /**
     * 获取售后列表（水站端）
     */
    @GetMapping
    @Operation(summary = "获取售后列表", description = "水站端获取售后申请列表")
    public Result<Page<AfterSalesDTO>> getAfterSalesList(
            @RequestHeader(value = "X-Station-Id", required = false) Long headerStationId,
            HttpServletRequest httpRequest,
            @RequestParam(required = false, defaultValue = "all") @Parameter(description = "状态筛选") String status,
            @RequestParam(required = false, defaultValue = "1") @Parameter(description = "页码") Integer page,
            @RequestParam(required = false, defaultValue = "20") @Parameter(description = "每页数量") Integer size) {
        Long stationId = getStationId(headerStationId, httpRequest);
        Page<AfterSalesDTO> result = afterSalesService.getAfterSalesList(stationId, status, page, size);
        return Result.ok(result);
    }

    /**
     * 获取售后详情（水站端）
     */
    @GetMapping("/{id}")
    @Operation(summary = "获取售后详情", description = "水站端获取售后申请详情")
    public Result<AfterSalesDetailDTO> getAfterSalesDetail(
            @RequestHeader(value = "X-Station-Id", required = false) Long headerStationId,
            HttpServletRequest httpRequest,
            @PathVariable @Parameter(description = "售后ID") Long id) {
        Long stationId = getStationId(headerStationId, httpRequest);
        AfterSalesDetailDTO result = afterSalesService.getAfterSalesDetail(stationId, id);
        return Result.ok(result);
    }

    /**
     * 创建售后申请（水站端）
     */
    @PostMapping
    @Operation(summary = "创建售后申请", description = "水站端提交售后申请")
    public Result<CreateAfterSalesResponse> createAfterSales(
            @RequestHeader(value = "X-Station-Id", required = false) Long headerStationId,
            HttpServletRequest httpRequest,
            @Valid @RequestBody CreateAfterSalesRequestV2 request) {
        Long stationId = getStationId(headerStationId, httpRequest);
        CreateAfterSalesResponse result = afterSalesService.createAfterSales(stationId, request);
        return Result.ok(result);
    }

    /**
     * 取消售后申请（水站端）
     */
    @PostMapping("/{id}/cancel")
    @Operation(summary = "取消售后申请", description = "水站端取消售后申请，只能取消待处理的申请")
    public Result<Void> cancelAfterSales(
            @RequestHeader(value = "X-Station-Id", required = false) Long headerStationId,
            HttpServletRequest httpRequest,
            @PathVariable @Parameter(description = "售后ID") Long id) {
        Long stationId = getStationId(headerStationId, httpRequest);
        afterSalesService.cancelAfterSales(stationId, id);
        return Result.ok();
    }

    private Long getStationId(Long headerStationId, HttpServletRequest request) {
        if (headerStationId != null) {
            return headerStationId;
        }
        Optional<User> currentUser = JwtAuthenticationFilter.getCurrentUser(request);
        if (currentUser.isPresent()) {
            Long stationId = currentUser.get().getStationId();
            if (stationId != null) {
                return stationId;
            }
        }
        throw new BusinessException(ResultCode.PARAM_ERROR, "无法获取水站ID，请检查登录状态");
    }

    /**
     * 仓库端获取售后列表
     */
    @GetMapping("/warehouse")
    @Operation(summary = "仓库获取售后列表", description = "仓库端获取售后申请列表")
    public Result<Page<AfterSalesDTO>> getAfterSalesListForWarehouse(
            @RequestHeader("X-Warehouse-Id") @Parameter(description = "仓库ID") Long warehouseId,
            @RequestParam(required = false, defaultValue = "all") @Parameter(description = "状态筛选") String status,
            @RequestParam(required = false, defaultValue = "1") @Parameter(description = "页码") Integer page,
            @RequestParam(required = false, defaultValue = "20") @Parameter(description = "每页数量") Integer size) {

        Page<AfterSalesDTO> result = afterSalesService.getAfterSalesListForWarehouse(warehouseId, status, page, size);
        return Result.ok(result);
    }

    /**
     * 处理售后单（仓库端）
     */
    @PostMapping("/{afterSalesId}/process")
    @Operation(summary = "处理售后单", description = "仓库端处理售后单，同意或拒绝")
    public Result<AfterSales> processAfterSales(
            @PathVariable @Parameter(description = "售后ID") Long afterSalesId,
            @Valid @RequestBody com.bucketwater.oms.module.aftersales.dto.ProcessAfterSalesRequest request) {

        AfterSales result = afterSalesService.processAfterSales(afterSalesId, request);
        return Result.ok(result);
    }

    /**
     * 获取售后类型列表（辅助接口）
     */
    @GetMapping("/types")
    @Operation(summary = "获取售后类型列表", description = "获取可选的售后类型")
    public Result<java.util.List<java.util.Map<String, String>>> getAfterSalesTypes() {
        java.util.List<java.util.Map<String, String>> types = java.util.Arrays.asList(
                java.util.Map.of("value", "replenishment", "label", "补货"),
                java.util.Map.of("value", "refund", "label", "退款"),
                java.util.Map.of("value", "return", "label", "退货")
        );
        return Result.ok(types);
    }

    /**
     * 获取售后状态列表（辅助接口）
     */
    @GetMapping("/statuses")
    @Operation(summary = "获取售后状态列表", description = "获取可选的售后状态")
    public Result<java.util.List<java.util.Map<String, String>>> getAfterSalesStatuses() {
        java.util.List<java.util.Map<String, String>> statuses = java.util.Arrays.asList(
                java.util.Map.of("value", "all", "label", "全部"),
                java.util.Map.of("value", "pending", "label", "待处理"),
                java.util.Map.of("value", "processing", "label", "处理中"),
                java.util.Map.of("value", "completed", "label", "已完成"),
                java.util.Map.of("value", "rejected", "label", "已拒绝"),
                java.util.Map.of("value", "cancelled", "label", "已取消")
        );
        return Result.ok(statuses);
    }
}
