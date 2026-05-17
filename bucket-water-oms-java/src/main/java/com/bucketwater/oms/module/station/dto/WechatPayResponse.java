package com.bucketwater.oms.module.station.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "微信支付响应")
public class WechatPayResponse {

    @Schema(description = "预支付ID")
    private String prepayId;

    @Schema(description = "随机字符串")
    private String nonceStr;

    @Schema(description = "时间戳")
    private String timestamp;

    @Schema(description = "签名")
    private String sign;
}
