package com.bucketwater.oms.module.order.controller;

import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.order.dto.CreateOrderRequest;
import com.bucketwater.oms.module.order.dto.DeliveryRequest;
import com.bucketwater.oms.module.order.dto.DispatchOrderRequest;
import com.bucketwater.oms.module.order.dto.DispatchOrderResponse;
import com.bucketwater.oms.module.order.dto.OrderVO;
import com.bucketwater.oms.module.order.dto.RejectOrderRequest;
import com.bucketwater.oms.module.order.dto.ReviewOrderRequest;
import com.bucketwater.oms.module.order.dto.UpdateOrderRequest;
import com.bucketwater.oms.module.order.service.OrderService;
import com.bucketwater.oms.module.user.entity.User;
import com.bucketwater.oms.common.security.JwtAuthenticationFilter;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/orders")
@Tag(name = "订单模块", description = "订单创建、查询、状态变更")
public class OrderController {

    @Autowired
    private OrderService orderService;

    @PostMapping
    @Operation(summary = "创建订单", description = "水站创建新订单")
    public Result<OrderVO> createOrder(
            @RequestHeader(value = "X-Station-Id", required = false) Long headerStationId,
            HttpServletRequest httpRequest,
            @Valid @RequestBody CreateOrderRequest orderRequest) {
        Long stationId = getStationId(headerStationId, httpRequest);
        OrderVO order = orderService.createOrder(stationId, orderRequest);
        return Result.ok(order);
    }

    @GetMapping
    @Operation(summary = "获取订单列表", description = "分页查询订单列表")
    public Result<List<OrderVO>> getOrders(
            @RequestHeader(value = "X-Station-Id", required = false) Long stationId,
            @RequestParam(required = false) @Parameter(description = "订单状态") String status,
            @RequestParam(defaultValue = "1") @Parameter(description = "页码") Integer page,
            @RequestParam(defaultValue = "20") @Parameter(description = "每页数量") Integer size) {
        List<OrderVO> orders = orderService.getOrders(stationId, status, page, size);
        return Result.ok(orders);
    }

    @GetMapping("/{orderId}")
    @Operation(summary = "获取订单详情", description = "获取订单详细信息")
    public Result<OrderVO> getOrderDetail(
            @PathVariable @Parameter(description = "订单ID") Long orderId) {
        OrderVO order = orderService.getOrderDetail(orderId);
        return Result.ok(order);
    }

    @PutMapping("/{orderId}")
    @Operation(summary = "修改订单", description = "审查前可修改订单信息（所有字段必填）")
    public Result<OrderVO> updateOrder(
            @PathVariable @Parameter(description = "订单ID") Long orderId,
            @RequestHeader(value = "X-Station-Id", required = false) Long headerStationId,
            HttpServletRequest httpRequest,
            @Valid @RequestBody CreateOrderRequest orderRequest) {
        Long stationId = getStationId(headerStationId, httpRequest);
        OrderVO order = orderService.updateOrder(orderId, stationId, orderRequest);
        return Result.ok(order);
    }

    @PutMapping("/{orderId}/optional")
    @Operation(summary = "修改订单（可选字段）", description = "审查前可修改订单信息（只更新传入的字段）")
    public Result<OrderVO> updateOrderOptional(
            @PathVariable @Parameter(description = "订单ID") Long orderId,
            @RequestHeader(value = "X-Station-Id", required = false) Long headerStationId,
            HttpServletRequest httpRequest,
            @Valid @RequestBody UpdateOrderRequest orderRequest) {
        Long stationId = getStationId(headerStationId, httpRequest);
        OrderVO order = orderService.updateOrderOptional(orderId, stationId, orderRequest);
        return Result.ok(order);
    }

    @PostMapping("/{orderId}/cancel")
    @Operation(summary = "取消订单", description = "审查前可取消订单")
    public Result<Void> cancelOrder(
            @PathVariable @Parameter(description = "订单ID") Long orderId,
            @RequestParam(required = false) @Parameter(description = "取消原因") String reason) {
        orderService.cancelOrder(orderId, reason);
        return Result.ok();
    }

    @PostMapping("/{orderId}/review")
    @Operation(summary = "仓库接单/拒单", description = "仓库审查订单，接单或拒单")
    public Result<OrderVO> reviewOrder(
            @PathVariable @Parameter(description = "订单ID") Long orderId,
            @RequestHeader("X-Warehouse-Id") @Parameter(description = "仓库ID") Long warehouseId,
            @Valid @RequestBody ReviewOrderRequest request) {
        OrderVO order = orderService.reviewOrder(orderId, warehouseId, request);
        return Result.ok(order);
    }

    @PostMapping("/{orderId}/dispatch")
    @Operation(summary = "仓库派单", description = "仓库将订单派给司机，跨仓库派单会返回警告信息")
    public Result<DispatchOrderResponse> dispatchOrder(
            @PathVariable @Parameter(description = "订单ID") Long orderId,
            @RequestHeader("X-Warehouse-Id") @Parameter(description = "仓库ID") Long warehouseId,
            @Valid @RequestBody DispatchOrderRequest request) {
        DispatchOrderResponse response = orderService.dispatchOrder(orderId, warehouseId, request);
        return Result.ok(response);
    }

    @PostMapping("/{orderId}/deliver")
    @Operation(summary = "配送签收", description = "司机完成配送签收")
    public Result<OrderVO> deliverOrder(
            @PathVariable @Parameter(description = "订单ID") Long orderId,
            @Valid @RequestBody DeliveryRequest request) {
        OrderVO order = orderService.deliverOrder(orderId, request);
        return Result.ok(order);
    }

    @PostMapping("/{orderId}/reject")
    @Operation(summary = "仓库拒单", description = "仓库拒单，记录拒单原因和库存不足明细")
    public Result<OrderVO> rejectOrder(
            @PathVariable @Parameter(description = "订单ID") Long orderId,
            @RequestHeader("X-Warehouse-Id") @Parameter(description = "仓库ID") Long warehouseId,
            @Valid @RequestBody RejectOrderRequest request) {
        OrderVO order = orderService.rejectOrder(orderId, warehouseId, request);
        return Result.ok(order);
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
}
