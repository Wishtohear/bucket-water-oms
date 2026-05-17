package com.bucketwater.oms.module.admin.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.math.BigDecimal;

@Data
@Schema(description = "最近订单DTO")
public class RecentOrderDTO {

    @Schema(description = "订单ID")
    private Long id;

    @Schema(description = "订单号")
    private String orderNo;

    @Schema(description = "创建时间")
    private String createTime;

    @Schema(description = "订单金额")
    private BigDecimal amount;

    @Schema(description = "订单状态")
    private String status;
}
