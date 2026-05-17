package com.bucketwater.oms.module.admin.controller;

import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.common.security.RequireRole;
import com.bucketwater.oms.module.admin.dto.StationPageDTO;
import com.bucketwater.oms.module.admin.dto.StationPageQueryDTO;
import com.bucketwater.oms.module.admin.service.AdminStationPageService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/admin/stations")
@Tag(name = "管理端-水站管理", description = "水站分页查询和管理")
@RequireRole({"PLATFORM_ADMIN", "FACTORY_ADMIN"})
public class AdminStationPageController {

    @Autowired
    private AdminStationPageService stationPageService;

    @GetMapping("/page")
    @Operation(summary = "分页查询水站列表", description = "支持关键字搜索、状态筛选、余额筛选、分页")
    public Result<StationPageDTO> queryStations(
            @RequestParam(required = false) @Parameter(description = "关键字搜索") String keyword,
            @RequestParam(required = false) @Parameter(description = "状态: active/suspended/cancelled") String status,
            @RequestParam(required = false) @Parameter(description = "余额筛选: balance_sufficient/balance_low/balance_arrears") String balanceFilter,
            @RequestParam(defaultValue = "1") @Parameter(description = "页码") Integer page,
            @RequestParam(defaultValue = "20") @Parameter(description = "每页数量") Integer size) {
        
        StationPageQueryDTO query = new StationPageQueryDTO();
        query.setKeyword(keyword);
        query.setStatus(status);
        query.setBalanceFilter(balanceFilter);
        query.setPage(page);
        query.setSize(size);
        
        StationPageDTO result = stationPageService.queryStations(query);
        return Result.ok(result);
    }
}
