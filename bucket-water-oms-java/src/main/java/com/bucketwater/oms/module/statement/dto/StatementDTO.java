package com.bucketwater.oms.module.statement.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Schema(description = "对账单DTO")
public class StatementDTO {

    @Schema(description = "对账单ID")
    private String statementId;

    @Schema(description = "水站ID")
    private String stationId;

    @Schema(description = "水站名称")
    private String stationName;

    @Schema(description = "账单月份")
    private String yearMonth;

    @Schema(description = "账期开始日期")
    private LocalDate startDate;

    @Schema(description = "账期结束日期")
    private LocalDate endDate;

    @Schema(description = "期初余额")
    private BigDecimal openingBalance;

    @Schema(description = "本月进货总额")
    private BigDecimal totalAmount;

    @Schema(description = "本月回款金额")
    private BigDecimal paymentReceived;

    @Schema(description = "期末余额")
    private BigDecimal closingBalance;

    @Schema(description = "状态")
    private String status;

    @Schema(description = "订单列表")
    private List<OrderItem> orders;

    @Schema(description = "生成时间")
    private LocalDateTime generatedAt;

    @Schema(description = "确认时间")
    private LocalDateTime confirmedAt;

    @Schema(description = "异议原因")
    private String disputeReason;

    @Schema(description = "异议时间")
    private LocalDateTime disputedAt;

    @Schema(description = "结算金额")
    private BigDecimal settlementAmount;

    public StatementDTO() {}

    public StatementDTO(String statementId, String stationId, String stationName, String yearMonth,
                     LocalDate startDate, LocalDate endDate, BigDecimal openingBalance,
                     BigDecimal totalAmount, BigDecimal paymentReceived, BigDecimal closingBalance,
                     String status, List<OrderItem> orders, LocalDateTime generatedAt,
                     LocalDateTime confirmedAt, String disputeReason, LocalDateTime disputedAt,
                     BigDecimal settlementAmount) {
        this.statementId = statementId;
        this.stationId = stationId;
        this.stationName = stationName;
        this.yearMonth = yearMonth;
        this.startDate = startDate;
        this.endDate = endDate;
        this.openingBalance = openingBalance;
        this.totalAmount = totalAmount;
        this.paymentReceived = paymentReceived;
        this.closingBalance = closingBalance;
        this.status = status;
        this.orders = orders;
        this.generatedAt = generatedAt;
        this.confirmedAt = confirmedAt;
        this.disputeReason = disputeReason;
        this.disputedAt = disputedAt;
        this.settlementAmount = settlementAmount;
    }

    public String getStatementId() { return statementId; }
    public void setStatementId(String statementId) { this.statementId = statementId; }
    public String getStationId() { return stationId; }
    public void setStationId(String stationId) { this.stationId = stationId; }
    public String getStationName() { return stationName; }
    public void setStationName(String stationName) { this.stationName = stationName; }
    public String getYearMonth() { return yearMonth; }
    public void setYearMonth(String yearMonth) { this.yearMonth = yearMonth; }
    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }
    public LocalDate getEndDate() { return endDate; }
    public void setEndDate(LocalDate endDate) { this.endDate = endDate; }
    public BigDecimal getOpeningBalance() { return openingBalance; }
    public void setOpeningBalance(BigDecimal openingBalance) { this.openingBalance = openingBalance; }
    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }
    public BigDecimal getPaymentReceived() { return paymentReceived; }
    public void setPaymentReceived(BigDecimal paymentReceived) { this.paymentReceived = paymentReceived; }
    public BigDecimal getClosingBalance() { return closingBalance; }
    public void setClosingBalance(BigDecimal closingBalance) { this.closingBalance = closingBalance; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public List<OrderItem> getOrders() { return orders; }
    public void setOrders(List<OrderItem> orders) { this.orders = orders; }
    public LocalDateTime getGeneratedAt() { return generatedAt; }
    public void setGeneratedAt(LocalDateTime generatedAt) { this.generatedAt = generatedAt; }
    public LocalDateTime getConfirmedAt() { return confirmedAt; }
    public void setConfirmedAt(LocalDateTime confirmedAt) { this.confirmedAt = confirmedAt; }
    public String getDisputeReason() { return disputeReason; }
    public void setDisputeReason(String disputeReason) { this.disputeReason = disputeReason; }
    public LocalDateTime getDisputedAt() { return disputedAt; }
    public void setDisputedAt(LocalDateTime disputedAt) { this.disputedAt = disputedAt; }
    public BigDecimal getSettlementAmount() { return settlementAmount; }
    public void setSettlementAmount(BigDecimal settlementAmount) { this.settlementAmount = settlementAmount; }

    @Schema(description = "订单项")
    public static class OrderItem {

        @Schema(description = "订单ID")
        private String orderId;

        @Schema(description = "日期")
        private LocalDate date;

        @Schema(description = "金额")
        private BigDecimal amount;

        @Schema(description = "商品明细")
        private String items;

        public OrderItem() {}

        public OrderItem(String orderId, LocalDate date, BigDecimal amount, String items) {
            this.orderId = orderId;
            this.date = date;
            this.amount = amount;
            this.items = items;
        }

        public String getOrderId() { return orderId; }
        public void setOrderId(String orderId) { this.orderId = orderId; }
        public LocalDate getDate() { return date; }
        public void setDate(LocalDate date) { this.date = date; }
        public BigDecimal getAmount() { return amount; }
        public void setAmount(BigDecimal amount) { this.amount = amount; }
        public String getItems() { return items; }
        public void setItems(String items) { this.items = items; }
    }
}
