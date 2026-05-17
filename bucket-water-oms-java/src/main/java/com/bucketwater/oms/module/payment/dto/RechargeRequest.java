package com.bucketwater.oms.module.payment.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Data;

import java.math.BigDecimal;

@Data
@Schema(description = "充值请求")
public class RechargeRequest {

    @NotNull(message = "水站ID不能为空")
    @Schema(description = "水站ID")
    private Long stationId;

    @NotNull(message = "充值金额不能为空")
    @Positive(message = "充值金额必须为正数")
    @Schema(description = "充值金额")
    private BigDecimal amount;

    @Schema(description = "支付类型: wechat/alipay/balance")
    private String payType = "wechat";

    @Schema(description = "备注")
    private String remark;
}
