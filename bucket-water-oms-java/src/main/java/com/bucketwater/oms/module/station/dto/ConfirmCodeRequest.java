package com.bucketwater.oms.module.station.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

@Schema(description = "确认码请求")
public class ConfirmCodeRequest {

    @NotBlank(message = "订单号不能为空")
    @Schema(description = "订单号")
    private String orderNo;

    @Schema(description = "确认码（生成后返回）")
    private String confirmCode;

    public String getOrderNo() {
        return orderNo;
    }

    public void setOrderNo(String orderNo) {
        this.orderNo = orderNo;
    }

    public String getConfirmCode() {
        return confirmCode;
    }

    public void setConfirmCode(String confirmCode) {
        this.confirmCode = confirmCode;
    }
}
