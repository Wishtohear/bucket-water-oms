package com.bucketwater.oms.module.bucket.controller;

import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.bucket.dto.BucketSummaryDTO;
import com.bucketwater.oms.module.bucket.dto.BucketTransactionDTO;
import com.bucketwater.oms.module.bucket.service.BucketService;
import com.bucketwater.oms.module.user.entity.User;
import com.bucketwater.oms.common.security.JwtAuthenticationFilter;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;


@RestController
@RequestMapping("/stations")
@Tag(name = "空桶管理模块", description = "空桶流水、押金管理")
public class BucketController {

    @Autowired
    private BucketService bucketService;

    @GetMapping("/bucket-transactions")
    @Operation(summary = "获取空桶流水", description = "获取水站空桶流水列表")
    public Result<BucketTransactionDTO> getTransactions(
            @RequestHeader(value = "X-Station-Id", required = false) Long headerStationId,
            HttpServletRequest httpRequest,
            @RequestParam(required = false) @Parameter(description = "开始日期") String startDate,
            @RequestParam(required = false) @Parameter(description = "结束日期") String endDate) {
        Long stationId = getStationId(headerStationId, httpRequest);
        BucketTransactionDTO transactions = bucketService.getTransactions(stationId, startDate, endDate);
        return Result.ok(transactions);
    }

    @GetMapping("/bucket-summary")
    @Operation(summary = "获取空桶汇总", description = "获取水站空桶汇总信息")
    public Result<BucketSummaryDTO> getBucketSummary(
            @RequestHeader(value = "X-Station-Id", required = false) Long headerStationId,
            HttpServletRequest httpRequest) {
        Long stationId = getStationId(headerStationId, httpRequest);
        BucketSummaryDTO summary = bucketService.getBucketSummary(stationId);
        return Result.ok(summary);
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
