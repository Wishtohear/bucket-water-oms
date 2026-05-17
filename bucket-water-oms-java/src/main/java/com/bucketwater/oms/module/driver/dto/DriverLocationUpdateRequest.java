package com.bucketwater.oms.module.driver.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;

@Schema(description = "司机位置更新请求")
public class DriverLocationUpdateRequest {

    @NotNull(message = "纬度不能为空")
    @Schema(description = "纬度")
    private BigDecimal lat;

    @NotNull(message = "经度不能为空")
    @Schema(description = "经度")
    private BigDecimal lng;

    @Schema(description = "在线状态: online/offline/break")
    private String onlineStatus;

    @Schema(description = "当前位置地址")
    private String address;

    @Schema(description = "速度(km/h)")
    private BigDecimal speed;

    @Schema(description = "方向角度")
    private Integer heading;

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

    public String getOnlineStatus() {
        return onlineStatus;
    }

    public void setOnlineStatus(String onlineStatus) {
        this.onlineStatus = onlineStatus;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public BigDecimal getSpeed() {
        return speed;
    }

    public void setSpeed(BigDecimal speed) {
        this.speed = speed;
    }

    public Integer getHeading() {
        return heading;
    }

    public void setHeading(Integer heading) {
        this.heading = heading;
    }
}
