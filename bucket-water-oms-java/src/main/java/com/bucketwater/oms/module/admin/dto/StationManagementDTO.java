package com.bucketwater.oms.module.admin.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;

@Data
@Schema(description = "水站创建/更新请求")
public class StationManagementDTO {

    @Schema(description = "水站名称")
    @NotBlank(message = "水站名称不能为空")
    private String name;

    @Schema(description = "联系人")
    private String contact;

    @Schema(description = "联系电话")
    @NotBlank(message = "联系电话不能为空")
    private String phone;

    @Schema(description = "地址")
    private String address;

    @Schema(description = "所属区域")
    private String area;

    @Schema(description = "水站类型")
    private String stationType;

    @Schema(description = "初始押金桶数量")
    private Integer depositBucketNum;

    @Schema(description = "信用额度")
    private BigDecimal creditLimit;

    @Schema(description = "每桶押金金额")
    private BigDecimal bucketDepositPerUnit;

    @Schema(description = "每桶押金金额(别名)")
    private BigDecimal bucketDepositAmount;

    @Schema(description = "欠桶阈值")
    private Integer owedThreshold;

    @Schema(description = "账期类型: prepaid/monthly/credit")
    private String paymentType;

    @Schema(description = "预存金要求金额")
    private BigDecimal prepaidRequiredAmount;

    @Schema(description = "初始余额")
    private BigDecimal initialBalance;

    @Schema(description = "预存金余额")
    private BigDecimal depositBalance;

    @Schema(description = "备注")
    private String remark;

    @Schema(description = "所属水厂ID")
    private Long factoryId;

    @Schema(description = "密码(创建时必填,编辑时可选)")
    private String password;

    @Schema(description = "纬度")
    private BigDecimal lat;

    @Schema(description = "经度")
    private BigDecimal lng;

    @Schema(description = "纬度(DMM格式，如 25°16.1234'N)")
    private String latDmm;

    @Schema(description = "经度(DMM格式，如 110°30.5678'E)")
    private String lngDmm;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getContact() {
        return contact;
    }

    public void setContact(String contact) {
        this.contact = contact;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getArea() {
        return area;
    }

    public void setArea(String area) {
        this.area = area;
    }

    public String getStationType() {
        return stationType;
    }

    public void setStationType(String stationType) {
        this.stationType = stationType;
    }

    public Integer getDepositBucketNum() {
        return depositBucketNum;
    }

    public void setDepositBucketNum(Integer depositBucketNum) {
        this.depositBucketNum = depositBucketNum;
    }

    public BigDecimal getCreditLimit() {
        return creditLimit;
    }

    public void setCreditLimit(BigDecimal creditLimit) {
        this.creditLimit = creditLimit;
    }

    public BigDecimal getBucketDepositPerUnit() {
        return bucketDepositPerUnit;
    }

    public void setBucketDepositPerUnit(BigDecimal bucketDepositPerUnit) {
        this.bucketDepositPerUnit = bucketDepositPerUnit;
    }

    public BigDecimal getBucketDepositAmount() {
        return bucketDepositAmount;
    }

    public void setBucketDepositAmount(BigDecimal bucketDepositAmount) {
        this.bucketDepositAmount = bucketDepositAmount;
    }

    public Integer getOwedThreshold() {
        return owedThreshold;
    }

    public void setOwedThreshold(Integer owedThreshold) {
        this.owedThreshold = owedThreshold;
    }

    public String getPaymentType() {
        return paymentType;
    }

    public void setPaymentType(String paymentType) {
        this.paymentType = paymentType;
    }

    public BigDecimal getPrepaidRequiredAmount() {
        return prepaidRequiredAmount;
    }

    public void setPrepaidRequiredAmount(BigDecimal prepaidRequiredAmount) {
        this.prepaidRequiredAmount = prepaidRequiredAmount;
    }

    public BigDecimal getInitialBalance() {
        return initialBalance;
    }

    public void setInitialBalance(BigDecimal initialBalance) {
        this.initialBalance = initialBalance;
    }

    public BigDecimal getDepositBalance() {
        return depositBalance;
    }

    public void setDepositBalance(BigDecimal depositBalance) {
        this.depositBalance = depositBalance;
    }

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
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

    public String getLatDmm() {
        return latDmm;
    }

    public void setLatDmm(String latDmm) {
        this.latDmm = latDmm;
    }

    public String getLngDmm() {
        return lngDmm;
    }

    public void setLngDmm(String lngDmm) {
        this.lngDmm = lngDmm;
    }

    public Long getFactoryId() {
        return factoryId;
    }

    public void setFactoryId(Long factoryId) {
        this.factoryId = factoryId;
    }
}
