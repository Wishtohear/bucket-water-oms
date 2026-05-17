package com.bucketwater.oms.module.payment.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Schema(description = "充值记录DTO")
public class RechargeRecordDTO {

    @Schema(description = "充值记录ID")
    private Long id;

    @Schema(description = "水站ID")
    private Long stationId;

    @Schema(description = "水站名称")
    private String stationName;

    @Schema(description = "充值金额")
    private BigDecimal amount;

    @Schema(description = "充值后余额")
    private BigDecimal balanceAfter;

    @Schema(description = "支付类型: wechat/alipay/balance")
    private String payType;

    @Schema(description = "支付状态: pending/success/failed")
    private String status;

    @Schema(description = "微信支付订单号")
    private String wechatOrderNo;

    @Schema(description = "微信支付交易号")
    private String transactionId;

    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @Schema(description = "支付完成时间")
    private LocalDateTime payTime;
}
