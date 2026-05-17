package com.bucketwater.oms.module.station.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("station_account")
@Schema(description = "水站账户实体")
public class StationAccount {

    @TableId(type = IdType.AUTO)
    @Schema(description = "主键ID")
    private Long id;

    @Schema(description = "水站ID")
    private Long stationId;

    @Schema(description = "押金桶数量")
    private Integer depositBucketNum;

    @Schema(description = "预存金余额")
    private BigDecimal depositBalance;

    @Schema(description = "信用额度")
    private BigDecimal creditLimit;

    @Schema(description = "已用信用额度")
    private BigDecimal creditUsed;

    @Schema(description = "每桶押金金额")
    private BigDecimal bucketDepositPerUnit;

    @Schema(description = "当前欠桶数量")
    private Integer owedBucketNum;

    @Schema(description = "欠桶阈值")
    private Integer owedThreshold;

    @Schema(description = "账期类型: prepaid/monthly/credit")
    private String paymentType;

    @Schema(description = "预存金要求金额")
    private BigDecimal prepaidRequiredAmount;

    @Schema(description = "销售政策ID")
    private Long policyId;

    @Schema(description = "更新时间")
    private LocalDateTime updatedAt;

    public BigDecimal getCreditAvailable() {
        if (creditLimit == null || creditUsed == null) {
            return BigDecimal.ZERO;
        }
        return creditLimit.subtract(creditUsed);
    }

    public boolean isBucketWarning() {
        if (owedBucketNum == null || owedThreshold == null) {
            return false;
        }
        return owedBucketNum >= owedThreshold;
    }

    public boolean checkOwedThresholdExceeded() {
        if (owedBucketNum == null || owedThreshold == null) {
            return false;
        }
        return owedBucketNum > owedThreshold;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getStationId() {
        return stationId;
    }

    public void setStationId(Long stationId) {
        this.stationId = stationId;
    }

    public Integer getDepositBucketNum() {
        return depositBucketNum;
    }

    public void setDepositBucketNum(Integer depositBucketNum) {
        this.depositBucketNum = depositBucketNum;
    }

    public BigDecimal getDepositBalance() {
        return depositBalance;
    }

    public void setDepositBalance(BigDecimal depositBalance) {
        this.depositBalance = depositBalance;
    }

    public BigDecimal getCreditLimit() {
        return creditLimit;
    }

    public void setCreditLimit(BigDecimal creditLimit) {
        this.creditLimit = creditLimit;
    }

    public BigDecimal getCreditUsed() {
        return creditUsed;
    }

    public void setCreditUsed(BigDecimal creditUsed) {
        this.creditUsed = creditUsed;
    }

    public BigDecimal getBucketDepositPerUnit() {
        return bucketDepositPerUnit;
    }

    public void setBucketDepositPerUnit(BigDecimal bucketDepositPerUnit) {
        this.bucketDepositPerUnit = bucketDepositPerUnit;
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

    public String getPaymentType() {
        return paymentType;
    }

    public void setPaymentType(String paymentType) {
        this.paymentType = paymentType;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public BigDecimal getPrepaidRequiredAmount() {
        return prepaidRequiredAmount;
    }

    public void setPrepaidRequiredAmount(BigDecimal prepaidRequiredAmount) {
        this.prepaidRequiredAmount = prepaidRequiredAmount;
    }

    public Long getPolicyId() {
        return policyId;
    }

    public void setPolicyId(Long policyId) {
        this.policyId = policyId;
    }
}
