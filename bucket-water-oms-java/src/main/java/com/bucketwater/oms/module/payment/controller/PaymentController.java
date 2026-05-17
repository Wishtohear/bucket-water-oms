package com.bucketwater.oms.module.payment.controller;

import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.module.payment.dto.RechargeRequest;
import com.bucketwater.oms.module.payment.dto.WechatPayRequest;
import com.bucketwater.oms.module.payment.dto.WechatPayResponse;
import com.bucketwater.oms.module.payment.entity.RechargeRecord;
import com.bucketwater.oms.module.payment.service.WechatPayService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/payments")
@Tag(name = "支付模块", description = "微信支付集成")
public class PaymentController {

    @Autowired
    private WechatPayService wechatPayService;

    @PostMapping("/wechat/prepay")
    @Operation(summary = "创建微信预支付订单", description = "创建微信支付预订单")
    public Result<WechatPayResponse> createPrepay(
            @RequestParam @Parameter(description = "水站ID") String stationId,
            @RequestParam @Parameter(description = "金额") BigDecimal amount,
            @RequestParam(defaultValue = "recharge") @Parameter(description = "支付类型: recharge/deposit") String payType) {
        WechatPayResponse response = wechatPayService.createPrepay(stationId, amount, payType);
        return Result.ok(response);
    }

    @PostMapping("/wechat/notify")
    @Operation(summary = "微信支付回调", description = "接收微信支付回调通知")
    public String handleNotify(@RequestBody WechatPayRequest request) {
        if (wechatPayService.verifySignature(request)) {
            wechatPayService.handlePaymentNotify(
                request.getPrepayId(),
                request.getTransactionId(),
                new BigDecimal(request.getTotalFee()).divide(new BigDecimal("100"))
            );
            return "<xml><return_code><![CDATA[SUCCESS]]></return_code><return_msg><![CDATA[OK]]></return_msg></xml>";
        }
        return "<xml><return_code><![CDATA[FAIL]]></return_code><return_msg><![CDATA[SIGN ERROR]]></return_msg></xml>";
    }

    @PostMapping("/recharge")
    @Operation(summary = "创建充值订单", description = "创建充值订单并获取预支付参数")
    public Result<Map<String, Object>> createRecharge(@RequestBody RechargeRequest request) {
        WechatPayResponse response = wechatPayService.createPrepay(
            String.valueOf(request.getStationId()),
            request.getAmount(),
            request.getPayType()
        );

        Map<String, Object> result = new HashMap<>();
        result.put("prepayId", response.getPrepayId());
        result.put("nonceStr", response.getNonceStr());
        result.put("timestamp", response.getTimestamp());
        result.put("sign", response.getSign());
        result.put("payType", request.getPayType());

        return Result.ok(result);
    }

    @GetMapping("/recharge/{stationId}")
    @Operation(summary = "查询充值记录", description = "查询水站的充值记录")
    public Result<Map<String, Object>> getRechargeRecords(
            @PathVariable @Parameter(description = "水站ID") Long stationId,
            @RequestParam(required = false) @Parameter(description = "状态") String status) {

        return Result.ok(new HashMap<String, Object>() {{
            put("stationId", stationId);
            put("status", status);
            put("message", "充值记录查询功能开发中");
        }});
    }
}
