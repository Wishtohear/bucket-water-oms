package com.bucketwater.oms.module.sms.controller;

import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.module.sms.service.SmsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/sms")
@Tag(name = "短信模块", description = "短信发送和验证")
public class SmsController {

    @Autowired
    private SmsService smsService;

    @PostMapping("/send-code")
    @Operation(summary = "发送验证码", description = "发送短信验证码")
    public Result<Void> sendVerificationCode(
            @RequestParam @Parameter(description = "手机号") String phone,
            @RequestParam @RequestHeader(value = "X-Sms-Type", defaultValue = "login") @Parameter(description = "验证码类型") String type) {
        smsService.sendVerificationCode(phone, type);
        return Result.ok();
    }

    @PostMapping("/verify-code")
    @Operation(summary = "验证验证码", description = "验证短信验证码")
    public Result<Boolean> verifyCode(
            @RequestParam @Parameter(description = "手机号") String phone,
            @RequestParam @RequestHeader(value = "X-Sms-Type", defaultValue = "login") @Parameter(description = "验证码类型") String type,
            @RequestParam @Parameter(description = "验证码") String code) {
        boolean isValid = smsService.verifyCode(phone, type, code);
        return Result.ok(isValid);
    }

    @PostMapping("/delivery-code")
    @Operation(summary = "发送配送验证码", description = "发送配送签收验证码")
    public Result<Void> sendDeliveryCode(
            @RequestParam @Parameter(description = "手机号") String phone,
            @RequestParam @Parameter(description = "订单号") String orderNo) {
        smsService.sendDeliveryCode(phone, orderNo);
        return Result.ok();
    }
}
