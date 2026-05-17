package com.bucketwater.oms.module.driver.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;

@Schema(description = "司机到达打卡请求")
public class DriverCheckInRequest {

    @NotBlank(message = "订单ID不能为空")
    @Schema(description = "订单ID")
    private String orderId;

    @NotNull(message = "纬度不能为空")
    @Schema(description = "打卡位置纬度")
    private BigDecimal lat;

    @NotNull(message = "经度不能为空")
    @Schema(description = "打卡位置经度")
    private BigDecimal lng;

    @Schema(description = "打卡位置地址")
    private String address;

    @Schema(description = "打卡时间戳(毫秒)")
    private Long timestamp;

    @Schema(description = "定位精度(米)")
    private BigDecimal accuracy;

    public String getOrderId() {
        return orderId;
    }

    public void setOrderId(String orderId) {
        this.orderId = orderId;
    }

    public BigDecimal getLat() {
        return lat;
    }

    public void setLat(BigDecimal lat) {
        this.lat = lat;
    }

    public BigDecimal getLng() {
        return lng;
    }

    public void setLng(BigDecimal lng) {
        this.lng = lng;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public Long getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(Long timestamp) {
        this.timestamp = timestamp;
    }

    public BigDecimal getAccuracy() {
        return accuracy;
    }

    public void setAccuracy(BigDecimal accuracy) {
        this.accuracy = accuracy;
    }
}
