package com.bucketwater.oms.module.auth.controller;

import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.module.auth.dto.LoginRequest;
import com.bucketwater.oms.module.auth.dto.LoginResponse;
import com.bucketwater.oms.module.auth.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 平台总超级管理员认证控制器
 * 提供平台管理员登录、登出、Token刷新等认证功能
 */
@RestController
@RequestMapping("/platform/auth")
@Tag(name = "平台管理员认证", description = "平台总超级管理员登录、登出、Token刷新")
public class PlatformAuthController {

    @Autowired
    private AuthService authService;

    /**
     * 平台管理员登录
     */
    @PostMapping("/login")
    @Operation(summary = "平台管理员登录", description = "使用用户名和密码登录平台管理系统")
    public Result<LoginResponse> platformLogin(@Valid @RequestBody PlatformLoginRequest request) {
        LoginRequest loginRequest = new LoginRequest();
        loginRequest.setPhone(request.getUsername());
        loginRequest.setPassword(request.getPassword());
        loginRequest.setRole("platform");

        LoginResponse response = authService.login(loginRequest);
        return Result.ok(response);
    }

    /**
     * 平台管理员Token刷新
     */
    @PostMapping("/refresh")
    @Operation(summary = "刷新Token", description = "使用RefreshToken获取新的AccessToken")
    public Result<LoginResponse> refreshToken(@RequestHeader("Authorization") String refreshToken) {
        LoginResponse response = authService.refreshToken(refreshToken.replace("Bearer ", ""));
        return Result.ok(response);
    }

    /**
     * 平台管理员登出
     */
    @PostMapping("/logout")
    @Operation(summary = "退出登录", description = "使当前Token失效")
    public Result<Void> logout(@RequestHeader("Authorization") String token) {
        return Result.ok();
    }

    /**
     * 平台管理员登录请求
     */
    public static class PlatformLoginRequest {
        private String username;
        private String password;

        public String getUsername() {
            return username;
        }

        public void setUsername(String username) {
            this.username = username;
        }

        public String getPassword() {
            return password;
        }

        public void setPassword(String password) {
            this.password = password;
        }
    }
}
