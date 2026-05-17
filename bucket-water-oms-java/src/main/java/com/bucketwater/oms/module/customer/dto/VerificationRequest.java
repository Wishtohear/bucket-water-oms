package com.bucketwater.oms.module.customer.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

@Schema(description = "验证码验证请求")
public class VerificationRequest {

    @NotBlank(message = "订单号不能为空")
    @Schema(description = "订单号")
    private String orderNo;

    @NotBlank(message = "验证码不能为空")
    @Schema(description = "验证码")
    private String code;

    public String getOrderNo() {
        return orderNo;
    }

    public void setOrderNo(String orderNo) {
        this.orderNo = orderNo;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }
}
