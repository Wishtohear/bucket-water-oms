package com.bucketwater.oms.module.admin.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class PolicyTemplateDTO {
    private Long id;
    private String name;
    private String type;
    private String typeText;
    private String description;
    private String remark;
    private String status;
    private Integer coverageCount;
    private BigDecimal bucketWaterPrice;
    private BigDecimal creditLimit;
    private BigDecimal minOrderQuantity;
    private String startDate;
    private String endDate;
    private String giftRatio;

    private String paymentType;
    private BigDecimal preDeposit;
    private Integer bucketThreshold;

    @JsonProperty("pricingRules")
    private List<ProductPrice> productPrices;

    @JsonProperty("pricingRules")
    public List<ProductPrice> getPricingRules() {
        return productPrices;
    }

    public void setPricingRules(List<ProductPrice> pricingRules) {
        this.productPrices = pricingRules;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class ProductPrice {
        private String productId;
        private String productName;
        private String category;
        private BigDecimal standardPrice;
        private BigDecimal price;
        private BigDecimal guidePriceMin;
        private BigDecimal guidePriceMax;
        private BigDecimal tierPrice;
        private Integer tierThreshold;
        private Integer minQuantity;

        public BigDecimal getStandardPrice() {
            return standardPrice != null ? standardPrice : price;
        }

        public void setStandardPrice(BigDecimal standardPrice) {
            this.standardPrice = standardPrice;
        }
    }
}
