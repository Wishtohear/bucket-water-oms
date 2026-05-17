package com.bucketwater.oms.module.ticket.controller;

import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.ticket.dto.WaterTicketDTO;
import com.bucketwater.oms.module.ticket.dto.WaterTicketTransactionDTO;
import com.bucketwater.oms.module.ticket.service.WaterTicketService;
import com.bucketwater.oms.module.user.entity.User;
import com.bucketwater.oms.common.security.JwtAuthenticationFilter;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;


@RestController
@RequestMapping("/tickets")
@Tag(name = "水票模块", description = "水票购买、使用、查询")
public class WaterTicketController {

    @Autowired
    private WaterTicketService ticketService;

    @GetMapping
    @Operation(summary = "获取水票列表", description = "获取水站的水票列表")
    public Result<List<WaterTicketDTO>> getTickets(
            @RequestHeader(value = "X-Station-Id", required = false) Long headerStationId,
            HttpServletRequest httpRequest) {
        Long stationId = getStationId(headerStationId, httpRequest);
        List<WaterTicketDTO> tickets = ticketService.getTickets(stationId);
        return Result.ok(tickets);
    }

    @GetMapping("/stats")
    @Operation(summary = "获取水票统计", description = "获取水票统计数据")
    public Result<Map<String, Object>> getTicketStats(
            @RequestHeader(value = "X-Station-Id", required = false) Long headerStationId,
            HttpServletRequest httpRequest) {
        Long stationId = getStationId(headerStationId, httpRequest);
        Map<String, Object> stats = ticketService.getTicketStats(stationId);
        return Result.ok(stats);
    }

    @GetMapping("/holdings")
    @Operation(summary = "获取水票持有明细", description = "获取水站持有的水票明细列表")
    public Result<List<WaterTicketDTO>> getTicketHoldings(
            @RequestHeader(value = "X-Station-Id", required = false) Long headerStationId,
            HttpServletRequest httpRequest) {
        Long stationId = getStationId(headerStationId, httpRequest);
        List<WaterTicketDTO> holdings = ticketService.getTicketHoldings(stationId);
        return Result.ok(holdings);
    }

    @GetMapping("/transactions")
    @Operation(summary = "获取水票使用记录", description = "获取水站所有水票的使用流水记录")
    public Result<List<WaterTicketTransactionDTO>> getAllTransactions(
            @RequestHeader(value = "X-Station-Id", required = false) Long headerStationId,
            HttpServletRequest httpRequest,
            @RequestParam(required = false) @Parameter(description = "筛选条件") String filter,
            @RequestParam(required = false) @Parameter(description = "日期范围") String dateRange) {
        Long stationId = getStationId(headerStationId, httpRequest);
        List<WaterTicketTransactionDTO> transactions = ticketService.getAllTransactions(stationId, filter, dateRange);
        return Result.ok(transactions);
    }

    @GetMapping("/valid")
    @Operation(summary = "获取可用水票", description = "获取水站的有效水票")
    public Result<List<WaterTicketDTO>> getValidTickets(
            @RequestHeader(value = "X-Station-Id", required = false) Long headerStationId,
            HttpServletRequest httpRequest) {
        Long stationId = getStationId(headerStationId, httpRequest);
        List<WaterTicketDTO> tickets = ticketService.getValidTickets(stationId);
        return Result.ok(tickets);
    }

    @GetMapping("/{ticketId}")
    @Operation(summary = "获取水票详情", description = "获取水票详细信息")
    public Result<WaterTicketDTO> getTicket(
            @PathVariable @Parameter(description = "水票ID") Long ticketId) {
        WaterTicketDTO ticket = ticketService.getTicketById(ticketId);
        return Result.ok(ticket);
    }

    @GetMapping("/{ticketId}/transactions")
    @Operation(summary = "获取水票使用记录", description = "获取水票的使用流水记录")
    public Result<List<WaterTicketTransactionDTO>> getTransactions(
            @PathVariable @Parameter(description = "水票ID") Long ticketId) {
        List<WaterTicketTransactionDTO> transactions = ticketService.getTicketTransactions(ticketId);
        return Result.ok(transactions);
    }

    @PostMapping("/purchase")
    @Operation(summary = "购买水票", description = "购买新水票")
    public Result<WaterTicketDTO> purchaseTicket(
            @RequestHeader(value = "X-Station-Id", required = false) Long headerStationId,
            HttpServletRequest httpRequest,
            @RequestParam @Parameter(description = "水票数量") Integer count,
            @RequestParam @Parameter(description = "金额") BigDecimal amount,
            @RequestParam @Parameter(description = "过期日期") @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDateTime expireDate) {
        Long stationId = getStationId(headerStationId, httpRequest);
        WaterTicketDTO ticket = ticketService.purchaseTicket(stationId, count, amount, expireDate);
        return Result.ok(ticket);
    }

    @GetMapping("/remaining")
    @Operation(summary = "获取剩余水票总数", description = "获取水站剩余水票总数")
    public Result<Integer> getRemainingTickets(
            @RequestHeader(value = "X-Station-Id", required = false) Long headerStationId,
            HttpServletRequest httpRequest) {
        Long stationId = getStationId(headerStationId, httpRequest);
        int remaining = ticketService.getTotalRemainingTickets(stationId);
        return Result.ok(remaining);
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
