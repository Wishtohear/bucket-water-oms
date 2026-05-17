package com.bucketwater.oms.module.payment.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "微信支付回调请求")
public class WechatPayRequest {

    @Schema(description = "返回状态码")
    private String returnCode;

    @Schema(description = "返回信息")
    private String returnMsg;

    @Schema(description = "小程序/应用ID")
    private String appId;

    @Schema(description = "商户号")
    private String mchId;

    @Schema(description = "设备号")
    private String deviceInfo;

    @Schema(description = "随机字符串")
    private String nonceStr;

    @Schema(description = "签名")
    private String sign;

    @Schema(description = "签名类型")
    private String signType;

    @Schema(description = "业务结果")
    private String resultCode;

    @Schema(description = "错误代码")
    private String errCode;

    @Schema(description = "错误代码描述")
    private String errCodeDes;

    @Schema(description = "交易类型")
    private String tradeType;

    @Schema(description = "预支付交易会话标识")
    private String prepayId;

    @Schema(description = "支付订单号")
    private String transactionId;

    @Schema(description = "商户订单号")
    private String outTradeNo;

    @Schema(description = "用户支付完成时间")
    private String timeEnd;

    @Schema(description = "支付金额")
    private String totalFee;

    @Schema(description = "现金支付金额")
    private String cashFee;

    @Schema(description = "货币类型")
    private String feeType;

    @Schema(description = "银行类型")
    private String bankType;

    public String getReturnCode() {
        return returnCode;
    }

    public void setReturnCode(String returnCode) {
        this.returnCode = returnCode;
    }

    public String getReturnMsg() {
        return returnMsg;
    }

    public void setReturnMsg(String returnMsg) {
        this.returnMsg = returnMsg;
    }

    public String getAppId() {
        return appId;
    }

    public void setAppId(String appId) {
        this.appId = appId;
    }

    public String getMchId() {
        return mchId;
    }

    public void setMchId(String mchId) {
        this.mchId = mchId;
    }

    public String getDeviceInfo() {
        return deviceInfo;
    }

    public void setDeviceInfo(String deviceInfo) {
        this.deviceInfo = deviceInfo;
    }

    public String getNonceStr() {
        return nonceStr;
    }

    public void setNonceStr(String nonceStr) {
        this.nonceStr = nonceStr;
    }

    public String getSign() {
        return sign;
    }

    public void setSign(String sign) {
        this.sign = sign;
    }

    public String getSignType() {
        return signType;
    }

    public void setSignType(String signType) {
        this.signType = signType;
    }

    public String getResultCode() {
        return resultCode;
    }

    public void setResultCode(String resultCode) {
        this.resultCode = resultCode;
    }

    public String getErrCode() {
        return errCode;
    }

    public void setErrCode(String errCode) {
        this.errCode = errCode;
    }

    public String getErrCodeDes() {
        return errCodeDes;
    }

    public void setErrCodeDes(String errCodeDes) {
        this.errCodeDes = errCodeDes;
    }

    public String getTradeType() {
        return tradeType;
    }

    public void setTradeType(String tradeType) {
        this.tradeType = tradeType;
    }

    public String getPrepayId() {
        return prepayId;
    }

    public void setPrepayId(String prepayId) {
        this.prepayId = prepayId;
    }

    public String getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(String transactionId) {
        this.transactionId = transactionId;
    }

    public String getOutTradeNo() {
        return outTradeNo;
    }

    public void setOutTradeNo(String outTradeNo) {
        this.outTradeNo = outTradeNo;
    }

    public String getTimeEnd() {
        return timeEnd;
    }

    public void setTimeEnd(String timeEnd) {
        this.timeEnd = timeEnd;
    }

    public String getTotalFee() {
        return totalFee;
    }

    public void setTotalFee(String totalFee) {
        this.totalFee = totalFee;
    }

    public String getCashFee() {
        return cashFee;
    }

    public void setCashFee(String cashFee) {
        this.cashFee = cashFee;
    }

    public String getFeeType() {
        return feeType;
    }

    public void setFeeType(String feeType) {
        this.feeType = feeType;
    }

    public String getBankType() {
        return bankType;
    }

    public void setBankType(String bankType) {
        this.bankType = bankType;
    }
}
