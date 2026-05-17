package com.bucketwater.oms.module.auth.controller;

import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.module.auth.dto.LoginRequest;
import com.bucketwater.oms.module.auth.dto.LoginResponse;
import com.bucketwater.oms.module.auth.dto.SmsCodeRequest;
import com.bucketwater.oms.module.auth.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@Tag(name = "认证模块", description = "用户登录、Token刷新、验证码")
public class AuthController {

    @Autowired
    private AuthService authService;

    @PostMapping("/login")
    @Operation(summary = "用户登录", description = "支持水站/司机/仓库/管理员登录")
    public Result<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        LoginResponse response = authService.login(request);
        return Result.ok(response);
    }

    @PostMapping("/refresh")
    @Operation(summary = "刷新Token", description = "使用RefreshToken获取新的AccessToken")
    public Result<LoginResponse> refresh(@RequestHeader("Authorization") String refreshToken) {
        LoginResponse response = authService.refreshToken(refreshToken.replace("Bearer ", ""));
        return Result.ok(response);
    }

    @PostMapping("/sms-code")
    @Operation(summary = "发送验证码", description = "发送短信验证码到手机")
    public Result<Void> sendSmsCode(@Valid @RequestBody SmsCodeRequest request) {
        authService.sendSmsCode(request);
        return Result.ok();
    }

    @PostMapping("/login-by-sms")
    @Operation(summary = "短信验证码登录", description = "使用手机号和短信验证码登录")
    public Result<LoginResponse> loginBySmsCode(
            @RequestParam @Parameter(description = "手机号") String phone,
            @RequestParam @Parameter(description = "验证码") String code,
            @RequestParam(required = false, defaultValue = "admin") @Parameter(description = "角色") String role) {
        LoginResponse response = authService.loginWithSmsCode(phone, code, role);
        return Result.ok(response);
    }

    @PostMapping("/reset-password")
    @Operation(summary = "重置密码", description = "通过短信验证码重置密码")
    public Result<Void> resetPassword(
            @RequestParam @io.swagger.v3.oas.annotations.Parameter(description = "手机号") String phone,
            @RequestParam @io.swagger.v3.oas.annotations.Parameter(description = "验证码") String code,
            @RequestParam @io.swagger.v3.oas.annotations.Parameter(description = "新密码") String newPassword) {
        authService.resetPasswordBySmsCode(phone, code, newPassword);
        return Result.ok();
    }
}
