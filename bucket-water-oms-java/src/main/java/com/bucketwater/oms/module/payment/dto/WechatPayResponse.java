package com.bucketwater.oms.module.payment.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "微信支付响应")
public class WechatPayResponse {

    @Schema(description = "预支付交易会话标识")
    private String prepayId;

    @Schema(description = "随机字符串")
    private String nonceStr;

    @Schema(description = "时间戳")
    private String timestamp;

    @Schema(description = "签名")
    private String sign;

    public WechatPayResponse() {}

    public WechatPayResponse(String prepayId, String nonceStr, String timestamp, String sign) {
        this.prepayId = prepayId;
        this.nonceStr = nonceStr;
        this.timestamp = timestamp;
        this.sign = sign;
    }

    public String getPrepayId() {
        return prepayId;
    }

    public void setPrepayId(String prepayId) {
        this.prepayId = prepayId;
    }

    public String getNonceStr() {
        return nonceStr;
    }

    public void setNonceStr(String nonceStr) {
        this.nonceStr = nonceStr;
    }

    public String getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(String timestamp) {
        this.timestamp = timestamp;
    }

    public String getSign() {
        return sign;
    }

    public void setSign(String sign) {
        this.sign = sign;
    }
}
