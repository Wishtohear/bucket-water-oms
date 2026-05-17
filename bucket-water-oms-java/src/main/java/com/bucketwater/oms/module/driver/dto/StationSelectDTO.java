package com.bucketwater.oms.module.driver.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;

@Schema(description = "水站选择DTO（用于司机回仓新水站派送选择）")
public class StationSelectDTO {

    @Schema(description = "水站ID")
    private Long stationId;

    @Schema(description = "水站名称")
    private String name;

    @Schema(description = "水站地址")
    private String address;

    @Schema(description = "当前欠桶数")
    private Integer owedBucketNum;

    @Schema(description = "欠桶阈值")
    private Integer owedThreshold;

    @Schema(description = "每桶押金金额")
    private BigDecimal bucketDepositPerUnit;

    @Schema(description = "是否超过欠桶阈值")
    private Boolean isOverThreshold;

    @Schema(description = "联系电话")
    private String phone;

    public Long getStationId() {
        return stationId;
    }

    public void setStationId(Long stationId) {
        this.stationId = stationId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public Integer getOwedBucketNum() {
        return owedBucketNum;
    }

    public void setOwedBucketNum(Integer owedBucketNum) {
        this.owedBucketNum = owedBucketNum;
    }

    public Integer getOwedThreshold() {
        return owedThreshold;
    }

    public void setOwedThreshold(Integer owedThreshold) {
        this.owedThreshold = owedThreshold;
    }

    public BigDecimal getBucketDepositPerUnit() {
        return bucketDepositPerUnit;
    }

    public void setBucketDepositPerUnit(BigDecimal bucketDepositPerUnit) {
        this.bucketDepositPerUnit = bucketDepositPerUnit;
    }

    public Boolean getIsOverThreshold() {
        return isOverThreshold;
    }

    public void setIsOverThreshold(Boolean isOverThreshold) {
        this.isOverThreshold = isOverThreshold;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }
}
