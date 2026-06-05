package com.bucketwater.oms.module.platform.controller;

import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.common.security.RequireRole;
import com.bucketwater.oms.module.platform.dto.PlatformDashboardDTO;
import com.bucketwater.oms.module.platform.service.PlatformDashboardService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/platform/dashboard")
@Tag(name = "平台Dashboard", description = "平台总超级管理员Dashboard数据")
@RequireRole({"PLATFORM_ADMIN"})
public class PlatformDashboardController {

    @Autowired
    private PlatformDashboardService dashboardService;

    @GetMapping("/stats")
    @Operation(summary = "获取平台Dashboard数据", description = "返回平台统计数据和水厂列表")
    public Result<PlatformDashboardDTO> getStats() {
        return Result.ok(dashboardService.getDashboardData());
    }
}
