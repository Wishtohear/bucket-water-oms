package com.bucketwater.oms.module.station.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Schema(description = "水站月度对账单DTO")
public class MonthlyStatementDTO {

    @Schema(description = "对账单ID")
    private String id;

    @Schema(description = "水站ID")
    private String stationId;

    @Schema(description = "水站名称")
    private String stationName;

    @Schema(description = "账单月份 (格式: yyyy-MM)")
    private String yearMonth;

    @Schema(description = "账期开始日期")
    private LocalDate startDate;

    @Schema(description = "账期结束日期")
    private LocalDate endDate;

    @Schema(description = "期初余额 (上月期末结转)")
    private BigDecimal openingBalance;

    @Schema(description = "本月进货总额")
    private BigDecimal totalAmount;

    @Schema(description = "本月回款金额 (已付款)")
    private BigDecimal paymentReceived;

    @Schema(description = "期末余额 (待结算)")
    private BigDecimal closingBalance;

    @Schema(description = "订单总数")
    private Integer totalOrders;

    @Schema(description = "已完成订单数")
    private Integer completedOrders;

    @Schema(description = "总桶数")
    private Integer totalBuckets;

    @Schema(description = "状态: pending(待确认)/confirmed(已确认)/paid(已结清)/disputed(有争议)")
    private String status;

    @Schema(description = "生成时间")
    private LocalDateTime generatedAt;

    @Schema(description = "确认时间")
    private LocalDateTime confirmedAt;

    @Schema(description = "异议原因")
    private String disputeReason;

    @Schema(description = "异议时间")
    private LocalDateTime disputedAt;

    @Schema(description = "订单明细列表")
    private List<OrderSummary> orders;

    @Schema(description = "商品统计列表")
    private List<ProductSummary> products;

    public MonthlyStatementDTO() {}

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
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
    public Integer getTotalOrders() { return totalOrders; }
    public void setTotalOrders(Integer totalOrders) { this.totalOrders = totalOrders; }
    public Integer getCompletedOrders() { return completedOrders; }
    public void setCompletedOrders(Integer completedOrders) { this.completedOrders = completedOrders; }
    public Integer getTotalBuckets() { return totalBuckets; }
    public void setTotalBuckets(Integer totalBuckets) { this.totalBuckets = totalBuckets; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDateTime getGeneratedAt() { return generatedAt; }
    public void setGeneratedAt(LocalDateTime generatedAt) { this.generatedAt = generatedAt; }
    public LocalDateTime getConfirmedAt() { return confirmedAt; }
    public void setConfirmedAt(LocalDateTime confirmedAt) { this.confirmedAt = confirmedAt; }
    public String getDisputeReason() { return disputeReason; }
    public void setDisputeReason(String disputeReason) { this.disputeReason = disputeReason; }
    public LocalDateTime getDisputedAt() { return disputedAt; }
    public void setDisputedAt(LocalDateTime disputedAt) { this.disputedAt = disputedAt; }
    public List<OrderSummary> getOrders() { return orders; }
    public void setOrders(List<OrderSummary> orders) { this.orders = orders; }
    public List<ProductSummary> getProducts() { return products; }
    public void setProducts(List<ProductSummary> products) { this.products = products; }

    @Schema(description = "订单汇总")
    public static class OrderSummary {
        @Schema(description = "订单ID")
        private String orderId;

        @Schema(description = "订单号")
        private String orderNo;

        @Schema(description = "订单日期")
        private LocalDate orderDate;

        @Schema(description = "订单金额")
        private BigDecimal amount;

        @Schema(description = "桶数")
        private Integer buckets;

        @Schema(description = "订单状态")
        private String status;

        @Schema(description = "商品明细")
        private String items;

        public OrderSummary() {}

        public String getOrderId() { return orderId; }
        public void setOrderId(String orderId) { this.orderId = orderId; }
        public String getOrderNo() { return orderNo; }
        public void setOrderNo(String orderNo) { this.orderNo = orderNo; }
        public LocalDate getOrderDate() { return orderDate; }
        public void setOrderDate(LocalDate orderDate) { this.orderDate = orderDate; }
        public BigDecimal getAmount() { return amount; }
        public void setAmount(BigDecimal amount) { this.amount = amount; }
        public Integer getBuckets() { return buckets; }
        public void setBuckets(Integer buckets) { this.buckets = buckets; }
        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }
        public String getItems() { return items; }
        public void setItems(String items) { this.items = items; }
    }

    @Schema(description = "商品汇总")
    public static class ProductSummary {
        @Schema(description = "商品ID")
        private String productId;

        @Schema(description = "商品名称")
        private String productName;

        @Schema(description = "数量")
        private Integer quantity;

        @Schema(description = "单位")
        private String unit;

        @Schema(description = "单价")
        private BigDecimal unitPrice;

        @Schema(description = "小计")
        private BigDecimal subtotal;

        public ProductSummary() {}

        public String getProductId() { return productId; }
        public void setProductId(String productId) { this.productId = productId; }
        public String getProductName() { return productName; }
        public void setProductName(String productName) { this.productName = productName; }
        public Integer getQuantity() { return quantity; }
        public void setQuantity(Integer quantity) { this.quantity = quantity; }
        public String getUnit() { return unit; }
        public void setUnit(String unit) { this.unit = unit; }
        public BigDecimal getUnitPrice() { return unitPrice; }
        public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }
        public BigDecimal getSubtotal() { return subtotal; }
        public void setSubtotal(BigDecimal subtotal) { this.subtotal = subtotal; }
    }
}
