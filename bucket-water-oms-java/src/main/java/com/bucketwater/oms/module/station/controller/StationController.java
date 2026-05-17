package com.bucketwater.oms.module.station.controller;

import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.station.dto.InventoryDTO;
import com.bucketwater.oms.module.station.dto.MonthlyStatementDTO;
import com.bucketwater.oms.module.station.dto.ProductPriceDTO;
import com.bucketwater.oms.module.station.dto.RechargeRequest;
import com.bucketwater.oms.module.station.dto.StationDashboardDTO;
import com.bucketwater.oms.module.station.dto.StationInfoDTO;
import com.bucketwater.oms.module.station.service.StationService;
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
import java.util.Map;
import java.util.Optional;



@RestController
@RequestMapping("/stations")
@Tag(name = "水站模块", description = "水站信息、库存、充值、收货确认")
public class StationController {

    @Autowired
    private StationService stationService;

    @GetMapping("/dashboard")
    @Operation(summary = "获取水站Dashboard", description = "获取水站专属的Dashboard数据，包括账户余额、订单、通知等")
    public Result<StationDashboardDTO> getDashboard(
            @RequestHeader(value = "X-Station-Id", required = false) Long headerStationId,
            HttpServletRequest request) {
        Long stationId = getStationId(headerStationId, request);
        StationDashboardDTO dashboard = stationService.getDashboard(stationId);
        return Result.ok(dashboard);
    }

    @GetMapping("/info")
    @Operation(summary = "获取水站信息", description = "获取水站基本信息、账户信息、销售政策（优先从header获取水站ID，未提供则从JWT获取）")
    public Result<StationInfoDTO> getStationInfoByHeader(
            @RequestHeader(value = "X-Station-Id", required = false) Long headerStationId,
            HttpServletRequest request) {
        Long stationId = headerStationId;
        if (stationId == null) {
            Optional<User> currentUser = JwtAuthenticationFilter.getCurrentUser(request);
            if (currentUser.isPresent()) {
                stationId = currentUser.get().getStationId();
            }
        }
        if (stationId == null) {
            throw new BusinessException(ResultCode.PARAM_ERROR, "无法获取水站ID，请检查登录状态");
        }
        StationInfoDTO info = stationService.getStationInfo(stationId);
        return Result.ok(info);
    }

    @GetMapping("/{stationId}")
    @Operation(summary = "获取水站信息", description = "获取水站基本信息、账户信息、销售政策")
    public Result<StationInfoDTO> getStationInfo(
            @PathVariable @Parameter(description = "水站ID") Long stationId) {
        StationInfoDTO info = stationService.getStationInfo(stationId);
        return Result.ok(info);
    }

    @GetMapping("/inventory")
    @Operation(summary = "获取实时库存", description = "获取各仓库的实时库存和价格")
    public Result<InventoryDTO> getInventory(
            @RequestHeader(value = "X-Station-Id", required = false) Long headerStationId,
            HttpServletRequest request) {
        Long stationId = getStationId(headerStationId, request);
        InventoryDTO inventory = stationService.getInventory(stationId);
        return Result.ok(inventory);
    }

    @GetMapping("/product-prices")
    @Operation(summary = "获取商品价格列表", description = "获取水站的商品价格列表，包含单价和最低起订量")
    public Result<java.util.List<ProductPriceDTO>> getProductPrices(
            @RequestHeader(value = "X-Station-Id", required = false) Long headerStationId,
            HttpServletRequest request) {
        Long stationId = getStationId(headerStationId, request);
        java.util.List<ProductPriceDTO> prices = stationService.getProductPrices(stationId);
        return Result.ok(prices);
    }

    @PostMapping("/recharge")
    @Operation(summary = "账户充值", description = "水站账户充值，支持微信支付")
    public Result<Void> recharge(
            @RequestHeader(value = "X-Station-Id", required = false) Long headerStationId,
            HttpServletRequest request,
            @Valid @RequestBody RechargeRequest rechargeRequest) {
        Long stationId = getStationId(headerStationId, request);
        stationService.recharge(stationId, rechargeRequest);
        return Result.ok();
    }

    @PostMapping("/bucket-deposit/pay")
    @Operation(summary = "补缴空桶押金", description = "水站补缴欠桶押金")
    public Result<Void> payBucketDeposit(
            @RequestHeader(value = "X-Station-Id", required = false) Long headerStationId,
            HttpServletRequest request,
            @RequestParam @Parameter(description = "桶数量") Integer bucketNum) {
        Long stationId = getStationId(headerStationId, request);
        stationService.payBucketDeposit(stationId, bucketNum);
        return Result.ok();
    }

    @PostMapping("/order/{orderId}/confirm")
    @Operation(summary = "扫码确认收货", description = "水站扫码确认订单收货")
    public Result<Map<String, Object>> confirmOrder(
            @RequestHeader(value = "X-Station-Id", required = false) Long headerStationId,
            HttpServletRequest request,
            @PathVariable @Parameter(description = "订单ID") Long orderId,
            @RequestParam @Parameter(description = "确认码") String confirmCode) {
        Long stationId = getStationId(headerStationId, request);
        Map<String, Object> result = stationService.confirmOrderDelivery(stationId, orderId, confirmCode);
        return Result.ok(result);
    }

    @PostMapping("/order/{orderId}/verify-code")
    @Operation(summary = "验证码确认收货", description = "水站输入验证码确认订单收货")
    public Result<Map<String, Object>> verifyCodeConfirm(
            @RequestHeader(value = "X-Station-Id", required = false) Long headerStationId,
            HttpServletRequest request,
            @PathVariable @Parameter(description = "订单ID") Long orderId,
            @RequestParam @Parameter(description = "验证码") String verifyCode) {
        Long stationId = getStationId(headerStationId, request);
        Map<String, Object> result = stationService.verifyOrderCode(stationId, orderId, verifyCode);
        return Result.ok(result);
    }

    @PostMapping("/order/{orderId}/send-confirm-code")
    @Operation(summary = "发送确认码", description = "店长发送确认码给顾客，用于老板确认签收")
    public Result<Map<String, Object>> sendConfirmCode(
            @RequestHeader(value = "X-Station-Id", required = false) Long headerStationId,
            HttpServletRequest request,
            @PathVariable @Parameter(description = "订单ID") Long orderId,
            @RequestParam(required = false) @Parameter(description = "发送方式: sms/call/manual") String sendMethod) {
        Long stationId = getStationId(headerStationId, request);
        Map<String, Object> result = stationService.sendOrderConfirmCode(stationId, orderId, sendMethod);
        return Result.ok(result);
    }

    @GetMapping("/order/{orderId}/confirm-code")
    @Operation(summary = "获取订单确认码", description = "获取订单的当前确认码")
    public Result<Map<String, Object>> getConfirmCode(
            @RequestHeader(value = "X-Station-Id", required = false) Long headerStationId,
            HttpServletRequest request,
            @PathVariable @Parameter(description = "订单ID") Long orderId) {
        Long stationId = getStationId(headerStationId, request);
        Map<String, Object> result = stationService.getOrderConfirmCode(stationId, orderId);
        return Result.ok(result);
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

    @GetMapping("/statements")
    @Operation(summary = "获取月度对账单列表", description = "获取水站的月度对账单列表")
    public Result<List<MonthlyStatementDTO>> getMonthlyStatements(
            @RequestHeader(value = "X-Station-Id", required = false) Long headerStationId,
            HttpServletRequest request,
            @RequestParam(required = false, defaultValue = "1") @Parameter(description = "页码") Integer page,
            @RequestParam(required = false, defaultValue = "6") @Parameter(description = "每页数量") Integer size) {
        Long stationId = getStationId(headerStationId, request);
        List<MonthlyStatementDTO> statements = stationService.getMonthlyStatements(stationId, page, size);
        return Result.ok(statements);
    }

    @GetMapping("/statements/current")
    @Operation(summary = "获取当月对账单", description = "获取当前月份的对账单统计")
    public Result<MonthlyStatementDTO> getCurrentMonthStatement(
            @RequestHeader(value = "X-Station-Id", required = false) Long headerStationId,
            HttpServletRequest request) {
        Long stationId = getStationId(headerStationId, request);
        MonthlyStatementDTO statement = stationService.getCurrentMonthStatement(stationId);
        return Result.ok(statement);
    }

    @GetMapping("/statements/{yearMonth}")
    @Operation(summary = "获取指定月份对账单", description = "获取指定月份的对账单统计")
    public Result<MonthlyStatementDTO> getStatementByMonth(
            @RequestHeader(value = "X-Station-Id", required = false) Long headerStationId,
            HttpServletRequest request,
            @PathVariable @Parameter(description = "账单月份 (格式: yyyy-MM)") String yearMonth) {
        Long stationId = getStationId(headerStationId, request);
        MonthlyStatementDTO statement = stationService.getMonthlyStatement(stationId, yearMonth);
        return Result.ok(statement);
    }

    @PostMapping("/statements/{statementId}/confirm")
    @Operation(summary = "确认对账单", description = "水站确认月度对账单")
    public Result<Void> confirmStatement(
            @RequestHeader(value = "X-Station-Id", required = false) Long headerStationId,
            HttpServletRequest request,
            @PathVariable @Parameter(description = "对账单ID") String statementId) {
        Long stationId = getStationId(headerStationId, request);
        stationService.confirmMonthlyStatement(stationId, statementId);
        return Result.ok();
    }

    @PostMapping("/statements/{statementId}/dispute")
    @Operation(summary = "对账单异议", description = "水站对对账单提出异议")
    public Result<Void> disputeStatement(
            @RequestHeader(value = "X-Station-Id", required = false) Long headerStationId,
            HttpServletRequest request,
            @PathVariable @Parameter(description = "对账单ID") String statementId,
            @RequestParam @Parameter(description = "异议原因") String reason) {
        Long stationId = getStationId(headerStationId, request);
        stationService.disputeMonthlyStatement(stationId, statementId, reason);
        return Result.ok();
    }
}
