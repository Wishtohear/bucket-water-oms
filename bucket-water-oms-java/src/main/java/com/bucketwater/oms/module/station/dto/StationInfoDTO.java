package com.bucketwater.oms.module.station.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.util.List;

@Schema(description = "水站信息DTO")
public class StationInfoDTO {

    @Schema(description = "水站ID")
    private String id;

    @Schema(description = "水站名称")
    private String name;

    @Schema(description = "联系人")
    private String contact;

    @Schema(description = "联系电话")
    private String phone;

    @Schema(description = "地址")
    private String address;

    @Schema(description = "账户信息")
    private AccountInfo account;

    @Schema(description = "销售政策")
    private PolicyInfo policy;

    @Schema(description = "状态")
    private String status;

    public StationInfoDTO() {}

    public StationInfoDTO(String id, String name, String contact, String phone, String address,
                       AccountInfo account, PolicyInfo policy, String status) {
        this.id = id;
        this.name = name;
        this.contact = contact;
        this.phone = phone;
        this.address = address;
        this.account = account;
        this.policy = policy;
        this.status = status;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getContact() { return contact; }
    public void setContact(String contact) { this.contact = contact; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public AccountInfo getAccount() { return account; }
    public void setAccount(AccountInfo account) { this.account = account; }
    public PolicyInfo getPolicy() { return policy; }
    public void setPolicy(PolicyInfo policy) { this.policy = policy; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    @Schema(description = "账户信息")
    public static class AccountInfo {

        @Schema(description = "预存金余额")
        private BigDecimal depositBalance;

        @Schema(description = "信用额度")
        private BigDecimal creditLimit;

        @Schema(description = "已用信用额度")
        private BigDecimal creditUsed;

        @Schema(description = "可用信用额度")
        private BigDecimal creditAvailable;

        @Schema(description = "每桶押金金额")
        private BigDecimal bucketDepositPerUnit;

        @Schema(description = "当前欠桶数量")
        private Integer owedBucketNum;

        @Schema(description = "欠桶阈值")
        private Integer owedThreshold;

        @Schema(description = "是否预警")
        private Boolean isWarning;

        public AccountInfo() {}

        public AccountInfo(BigDecimal depositBalance, BigDecimal creditLimit, BigDecimal creditUsed,
                          BigDecimal creditAvailable, BigDecimal bucketDepositPerUnit,
                          Integer owedBucketNum, Integer owedThreshold, Boolean isWarning) {
            this.depositBalance = depositBalance;
            this.creditLimit = creditLimit;
            this.creditUsed = creditUsed;
            this.creditAvailable = creditAvailable;
            this.bucketDepositPerUnit = bucketDepositPerUnit;
            this.owedBucketNum = owedBucketNum;
            this.owedThreshold = owedThreshold;
            this.isWarning = isWarning;
        }

        public BigDecimal getDepositBalance() { return depositBalance; }
        public void setDepositBalance(BigDecimal depositBalance) { this.depositBalance = depositBalance; }
        public BigDecimal getCreditLimit() { return creditLimit; }
        public void setCreditLimit(BigDecimal creditLimit) { this.creditLimit = creditLimit; }
        public BigDecimal getCreditUsed() { return creditUsed; }
        public void setCreditUsed(BigDecimal creditUsed) { this.creditUsed = creditUsed; }
        public BigDecimal getCreditAvailable() { return creditAvailable; }
        public void setCreditAvailable(BigDecimal creditAvailable) { this.creditAvailable = creditAvailable; }
        public BigDecimal getBucketDepositPerUnit() { return bucketDepositPerUnit; }
        public void setBucketDepositPerUnit(BigDecimal bucketDepositPerUnit) { this.bucketDepositPerUnit = bucketDepositPerUnit; }
        public Integer getOwedBucketNum() { return owedBucketNum; }
        public void setOwedBucketNum(Integer owedBucketNum) { this.owedBucketNum = owedBucketNum; }
        public Integer getOwedThreshold() { return owedThreshold; }
        public void setOwedThreshold(Integer owedThreshold) { this.owedThreshold = owedThreshold; }
        public Boolean getIsWarning() { return isWarning; }
        public void setIsWarning(Boolean isWarning) { this.isWarning = isWarning; }
    }

    @Schema(description = "销售政策")
    public static class PolicyInfo {

        @Schema(description = "账期类型: prepaid/monthly/credit")
        private String paymentType;

        @Schema(description = "价格列表")
        private List<PriceItem> prices;

        public PolicyInfo() {}

        public PolicyInfo(String paymentType, List<PriceItem> prices) {
            this.paymentType = paymentType;
            this.prices = prices;
        }

        public String getPaymentType() { return paymentType; }
        public void setPaymentType(String paymentType) { this.paymentType = paymentType; }
        public List<PriceItem> getPrices() { return prices; }
        public void setPrices(List<PriceItem> prices) { this.prices = prices; }
    }

    @Schema(description = "价格项")
    public static class PriceItem {

        @Schema(description = "商品ID")
        private String productId;

        @Schema(description = "商品名称")
        private String productName;

        @Schema(description = "单价")
        private BigDecimal unitPrice;

        @Schema(description = "阶梯价")
        private BigDecimal tierPrice;

        @Schema(description = "阶梯阈值")
        private Integer tierThreshold;

        public PriceItem() {}

        public PriceItem(String productId, String productName, BigDecimal unitPrice,
                       BigDecimal tierPrice, Integer tierThreshold) {
            this.productId = productId;
            this.productName = productName;
            this.unitPrice = unitPrice;
            this.tierPrice = tierPrice;
            this.tierThreshold = tierThreshold;
        }

        public String getProductId() { return productId; }
        public void setProductId(String productId) { this.productId = productId; }
        public String getProductName() { return productName; }
        public void setProductName(String productName) { this.productName = productName; }
        public BigDecimal getUnitPrice() { return unitPrice; }
        public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }
        public BigDecimal getTierPrice() { return tierPrice; }
        public void setTierPrice(BigDecimal tierPrice) { this.tierPrice = tierPrice; }
        public Integer getTierThreshold() { return tierThreshold; }
        public void setTierThreshold(Integer tierThreshold) { this.tierThreshold = tierThreshold; }
    }
}
