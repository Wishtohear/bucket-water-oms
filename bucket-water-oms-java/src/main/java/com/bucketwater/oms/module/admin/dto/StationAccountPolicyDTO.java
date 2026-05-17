package com.bucketwater.oms.module.admin.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.util.List;

@Schema(description = "水站销售政策配置")
public class StationAccountPolicyDTO {

    @NotNull(message = "水站ID不能为空")
    @Schema(description = "水站ID")
    private String stationId;

    @Schema(description = "销售政策模板ID")
    private Long policyId;

    @Schema(description = "账期类型: prepaid/monthly/credit")
    private String paymentType;

    @Schema(description = "信用额度")
    private BigDecimal creditLimit;

    @Schema(description = "每桶押金金额")
    private BigDecimal bucketDepositPerUnit;

    @Schema(description = "每桶押金金额(别名)")
    private BigDecimal bucketDepositAmount;

    @Schema(description = "欠桶阈值")
    private Integer owedThreshold;

    @Schema(description = "阶梯价配置")
    private List<TierPriceConfig> tierPrices;

    public String getStationId() { return stationId; }
    public void setStationId(String stationId) { this.stationId = stationId; }
    public Long getPolicyId() { return policyId; }
    public void setPolicyId(Long policyId) { this.policyId = policyId; }
    public String getPaymentType() { return paymentType; }
    public void setPaymentType(String paymentType) { this.paymentType = paymentType; }
    public BigDecimal getCreditLimit() { return creditLimit; }
    public void setCreditLimit(BigDecimal creditLimit) { this.creditLimit = creditLimit; }
    public BigDecimal getBucketDepositPerUnit() { return bucketDepositPerUnit; }
    public void setBucketDepositPerUnit(BigDecimal bucketDepositPerUnit) { this.bucketDepositPerUnit = bucketDepositPerUnit; }
    public BigDecimal getBucketDepositAmount() { return bucketDepositAmount; }
    public void setBucketDepositAmount(BigDecimal bucketDepositAmount) { this.bucketDepositAmount = bucketDepositAmount; }
    public Integer getOwedThreshold() { return owedThreshold; }
    public void setOwedThreshold(Integer owedThreshold) { this.owedThreshold = owedThreshold; }
    public List<TierPriceConfig> getTierPrices() { return tierPrices; }
    public void setTierPrices(List<TierPriceConfig> tierPrices) { this.tierPrices = tierPrices; }

    @Schema(description = "阶梯价配置")
    public static class TierPriceConfig {

        @Schema(description = "商品ID")
        private String productId;

        @Schema(description = "基础单价")
        private BigDecimal basePrice;

        @Schema(description = "阶梯阈值")
        private Integer tierThreshold;

        @Schema(description = "阶梯单价")
        private BigDecimal tierPrice;

        public String getProductId() { return productId; }
        public void setProductId(String productId) { this.productId = productId; }
        public BigDecimal getBasePrice() { return basePrice; }
        public void setBasePrice(BigDecimal basePrice) { this.basePrice = basePrice; }
        public Integer getTierThreshold() { return tierThreshold; }
        public void setTierThreshold(Integer tierThreshold) { this.tierThreshold = tierThreshold; }
        public BigDecimal getTierPrice() { return tierPrice; }
        public void setTierPrice(BigDecimal tierPrice) { this.tierPrice = tierPrice; }
    }
}
