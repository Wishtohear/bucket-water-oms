package com.bucketwater.oms.module.payment.entity;

import com.baomidou.mybatisplus.annotation.*;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Schema(description = "充值记录")
@TableName("recharge_record")
public class RechargeRecord {

    @Schema(description = "充值记录ID")
    @TableId(type = IdType.ASSIGN_ID)
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

    @Schema(description = "预支付交易会话标识")
    private String prepayId;

    @Schema(description = "用户ID")
    private Long userId;

    @Schema(description = "用户名称")
    private String userName;

    @Schema(description = "备注")
    private String remark;

    @TableField(fill = FieldFill.INSERT)
    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    @Schema(description = "更新时间")
    private LocalDateTime updateTime;

    @Schema(description = "支付完成时间")
    private LocalDateTime payTime;

    @Schema(description = "过期时间")
    private LocalDateTime expireTime;

    @Schema(description = "操作员")
    private String operator;

    @TableLogic
    @Schema(description = "删除标记")
    private Integer deleted;
}
