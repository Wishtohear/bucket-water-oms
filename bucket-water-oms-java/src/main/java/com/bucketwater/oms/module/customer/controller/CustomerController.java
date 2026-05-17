package com.bucketwater.oms.module.customer.controller;

import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.customer.dto.CustomerDTO;
import com.bucketwater.oms.module.customer.dto.VerificationRequest;
import com.bucketwater.oms.module.customer.service.CustomerService;
import com.bucketwater.oms.module.order.entity.Order;
import com.bucketwater.oms.module.order.mapper.OrderMapper;
import com.bucketwater.oms.module.sms.service.SmsService;
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
@RequestMapping("/customers")
@Tag(name = "客户模块", description = "客户信息管理")
public class CustomerController {

    @Autowired
    private CustomerService customerService;

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private SmsService smsService;

    @GetMapping
    @Operation(summary = "获取客户列表", description = "获取水站客户列表")
    public Result<List<CustomerDTO>> getCustomers(
            @RequestHeader(value = "X-Station-Id", required = false) @Parameter(description = "水站ID") Long stationId,
            @RequestParam(required = false) @Parameter(description = "搜索关键词") String keyword) {
        List<CustomerDTO> customers = customerService.getCustomers(stationId, keyword);
        return Result.ok(customers);
    }

    @GetMapping("/{customerId}")
    @Operation(summary = "获取客户详情", description = "获取客户详细信息")
    public Result<CustomerDTO> getCustomer(
            @PathVariable @Parameter(description = "客户ID") Long customerId) {
        CustomerDTO customer = customerService.getCustomerById(customerId);
        return Result.ok(customer);
    }

    @PostMapping
    @Operation(summary = "创建客户", description = "创建新客户")
    public Result<CustomerDTO> createCustomer(
            @RequestHeader(value = "X-Station-Id", required = false) Long headerStationId,
            HttpServletRequest httpRequest,
            @RequestParam @Parameter(description = "客户名称") String name,
            @RequestParam @Parameter(description = "手机号") String phone,
            @RequestParam(required = false) @Parameter(description = "地址") String address,
            @RequestParam(required = false) @Parameter(description = "联系人") String contact) {
        Long stationId = getStationId(headerStationId, httpRequest);
        CustomerDTO customer = customerService.createCustomer(stationId, name, phone, address, contact);
        return Result.ok(customer);
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

    @PutMapping("/{customerId}")
    @Operation(summary = "更新客户", description = "更新客户信息")
    public Result<CustomerDTO> updateCustomer(
            @PathVariable @Parameter(description = "客户ID") Long customerId,
            @RequestParam(required = false) @Parameter(description = "客户名称") String name,
            @RequestParam(required = false) @Parameter(description = "手机号") String phone,
            @RequestParam(required = false) @Parameter(description = "地址") String address,
            @RequestParam(required = false) @Parameter(description = "联系人") String contact) {
        CustomerDTO customer = customerService.updateCustomer(customerId, name, phone, address, contact);
        return Result.ok(customer);
    }

    @DeleteMapping("/{customerId}")
    @Operation(summary = "删除客户", description = "删除客户")
    public Result<Void> deleteCustomer(
            @PathVariable @Parameter(description = "客户ID") Long customerId) {
        customerService.deleteCustomer(customerId);
        return Result.ok();
    }

    @PostMapping("/request-delivery-code")
    @Operation(summary = "请求配送验证码", description = "顾客请求配送验证码，用于短信签收")
    public Result<Map<String, Object>> requestDeliveryCode(
            @RequestParam @Parameter(description = "订单号") String orderNo) {
        Order order = orderMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Order>()
                .eq(Order::getOrderNo, orderNo)
        );

        if (order == null) {
            throw new BusinessException(ResultCode.ORDER_NOT_FOUND);
        }

        if (order.getContactPhone() == null || order.getContactPhone().isEmpty()) {
            throw new BusinessException(ResultCode.PARAM_ERROR, "订单缺少联系电话");
        }

        smsService.sendDeliveryCode(order.getContactPhone(), orderNo);

        return Result.ok(Map.of(
            "message", "验证码已发送至" + maskPhone(order.getContactPhone()),
            "orderNo", orderNo
        ));
    }

    @PostMapping("/verify-delivery-code")
    @Operation(summary = "验证配送验证码", description = "顾客验证收到的配送验证码")
    public Result<Map<String, Object>> verifyDeliveryCode(
            @Valid @RequestBody VerificationRequest request) {
        Order order = orderMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Order>()
                .eq(Order::getOrderNo, request.getOrderNo())
        );

        if (order == null) {
            throw new BusinessException(ResultCode.ORDER_NOT_FOUND);
        }

        if (order.getContactPhone() == null) {
            throw new BusinessException(ResultCode.PARAM_ERROR, "订单缺少联系电话");
        }

        String cacheKey = "sms:code:" + order.getContactPhone() + ":delivery:" + request.getOrderNo();

        boolean isValid = smsService.verifyCode(order.getContactPhone(), "delivery:" + request.getOrderNo(), request.getCode());

        if (isValid) {
            return Result.ok(Map.of(
                "valid", true,
                "message", "验证码验证成功"
            ));
        } else {
            return Result.ok(Map.of(
                "valid", false,
                "message", "验证码错误或已过期"
            ));
        }
    }

    private String maskPhone(String phone) {
        if (phone == null || phone.length() < 7) {
            return phone;
        }
        return phone.substring(0, 3) + "****" + phone.substring(phone.length() - 4);
    }
}
