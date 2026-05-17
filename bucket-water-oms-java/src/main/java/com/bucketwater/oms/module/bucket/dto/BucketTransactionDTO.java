package com.bucketwater.oms.module.bucket.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Schema(description = "空桶流水DTO")
public class BucketTransactionDTO {

    @Schema(description = "总欠桶数量")
    private Integer totalOwed;

    @Schema(description = "欠桶阈值")
    private Integer threshold;

    @Schema(description = "每桶押金金额")
    private BigDecimal depositPerUnit;

    @Schema(description = "总押金金额")
    private BigDecimal totalDeposit;

    @Schema(description = "押金桶总数")
    private Integer totalDepositBuckets;

    @Schema(description = "可退押金")
    private BigDecimal refundableDeposit;

    @Schema(description = "是否超阈值预警")
    private Boolean overThreshold;

    @Schema(description = "本月回桶数")
    private Integer monthlyReturn;

    @Schema(description = "本月欠桶数")
    private Integer monthlyOwed;

    @Schema(description = "流水列表")
    private List<TransactionItem> transactions;

    public BucketTransactionDTO() {}

    public BucketTransactionDTO(Integer totalOwed, Integer threshold, BigDecimal depositPerUnit,
                               BigDecimal totalDeposit, Integer totalDepositBuckets,
                               BigDecimal refundableDeposit, Boolean overThreshold,
                               Integer monthlyReturn, Integer monthlyOwed,
                               List<TransactionItem> transactions) {
        this.totalOwed = totalOwed;
        this.threshold = threshold;
        this.depositPerUnit = depositPerUnit;
        this.totalDeposit = totalDeposit;
        this.totalDepositBuckets = totalDepositBuckets;
        this.refundableDeposit = refundableDeposit;
        this.overThreshold = overThreshold;
        this.monthlyReturn = monthlyReturn;
        this.monthlyOwed = monthlyOwed;
        this.transactions = transactions;
    }

    public Integer getTotalOwed() {
        return totalOwed;
    }

    public void setTotalOwed(Integer totalOwed) {
        this.totalOwed = totalOwed;
    }

    public Integer getThreshold() {
        return threshold;
    }

    public void setThreshold(Integer threshold) {
        this.threshold = threshold;
    }

    public BigDecimal getDepositPerUnit() {
        return depositPerUnit;
    }

    public void setDepositPerUnit(BigDecimal depositPerUnit) {
        this.depositPerUnit = depositPerUnit;
    }

    public BigDecimal getTotalDeposit() {
        return totalDeposit;
    }

    public void setTotalDeposit(BigDecimal totalDeposit) {
        this.totalDeposit = totalDeposit;
    }

    public Integer getTotalDepositBuckets() {
        return totalDepositBuckets;
    }

    public void setTotalDepositBuckets(Integer totalDepositBuckets) {
        this.totalDepositBuckets = totalDepositBuckets;
    }

    public BigDecimal getRefundableDeposit() {
        return refundableDeposit;
    }

    public void setRefundableDeposit(BigDecimal refundableDeposit) {
        this.refundableDeposit = refundableDeposit;
    }

    public Boolean getOverThreshold() {
        return overThreshold;
    }

    public void setOverThreshold(Boolean overThreshold) {
        this.overThreshold = overThreshold;
    }

    public Integer getMonthlyReturn() {
        return monthlyReturn;
    }

    public void setMonthlyReturn(Integer monthlyReturn) {
        this.monthlyReturn = monthlyReturn;
    }

    public Integer getMonthlyOwed() {
        return monthlyOwed;
    }

    public void setMonthlyOwed(Integer monthlyOwed) {
        this.monthlyOwed = monthlyOwed;
    }

    public List<TransactionItem> getTransactions() {
        return transactions;
    }

    public void setTransactions(List<TransactionItem> transactions) {
        this.transactions = transactions;
    }

    @Schema(description = "流水项")
    public static class TransactionItem {

        @Schema(description = "流水ID")
        private String id;

        @Schema(description = "类型")
        private String type;

        @Schema(description = "类型文本")
        private String typeText;

        @Schema(description = "数量")
        private Integer quantity;

        @Schema(description = "变动后余额")
        private Integer balance;

        @Schema(description = "订单ID")
        private String orderId;

        @Schema(description = "司机名称")
        private String driverName;

        @Schema(description = "创建时间")
        private LocalDateTime createdAt;

        public TransactionItem() {}

        public TransactionItem(String id, String type, String typeText, Integer quantity,
                             Integer balance, String orderId, String driverName, LocalDateTime createdAt) {
            this.id = id;
            this.type = type;
            this.typeText = typeText;
            this.quantity = quantity;
            this.balance = balance;
            this.orderId = orderId;
            this.driverName = driverName;
            this.createdAt = createdAt;
        }

        public String getId() {
            return id;
        }

        public void setId(String id) {
            this.id = id;
        }

        public String getType() {
            return type;
        }

        public void setType(String type) {
            this.type = type;
        }

        public String getTypeText() {
            return typeText;
        }

        public void setTypeText(String typeText) {
            this.typeText = typeText;
        }

        public Integer getQuantity() {
            return quantity;
        }

        public void setQuantity(Integer quantity) {
            this.quantity = quantity;
        }

        public Integer getBalance() {
            return balance;
        }

        public void setBalance(Integer balance) {
            this.balance = balance;
        }

        public String getOrderId() {
            return orderId;
        }

        public void setOrderId(String orderId) {
            this.orderId = orderId;
        }

        public String getDriverName() {
            return driverName;
        }

        public void setDriverName(String driverName) {
            this.driverName = driverName;
        }

        public LocalDateTime getCreatedAt() {
            return createdAt;
        }

        public void setCreatedAt(LocalDateTime createdAt) {
            this.createdAt = createdAt;
        }
    }
}
