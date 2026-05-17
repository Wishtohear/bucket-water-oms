package com.bucketwater.oms.module.driver.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Schema(description = "司机对账单DTO")
public class DriverStatementDTO {

    @Schema(description = "对账单ID")
    private Long id;

    @Schema(description = "对账单号")
    private String statementNo;

    @Schema(description = "司机ID")
    private Long driverId;

    @Schema(description = "司机名称")
    private String driverName;

    @Schema(description = "账期开始日期")
    private LocalDate startDate;

    @Schema(description = "账期结束日期")
    private LocalDate endDate;

    @Schema(description = "配送单数")
    private Integer totalOrders;

    @Schema(description = "总桶数")
    private Integer totalBuckets;

    @Schema(description = "总金额")
    private BigDecimal totalAmount;

    @Schema(description = "配送提成")
    private BigDecimal deliveryCommission;

    @Schema(description = "配送提成率(%)")
    private BigDecimal commissionRate;

    @Schema(description = "里程补助")
    private BigDecimal mileageSubsidy;

    @Schema(description = "总里程(km)")
    private BigDecimal totalDistance;

    @Schema(description = "实际应发金额")
    private BigDecimal actualAmount;

    @Schema(description = "状态: pending/confirmed/paid")
    private String status;

    @Schema(description = "生成时间")
    private LocalDateTime generatedAt;

    @Schema(description = "确认时间")
    private LocalDateTime confirmedAt;

    @Schema(description = "配送记录")
    private List<DeliveryRecord> records;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getStatementNo() {
        return statementNo;
    }

    public void setStatementNo(String statementNo) {
        this.statementNo = statementNo;
    }

    public Long getDriverId() {
        return driverId;
    }

    public void setDriverId(Long driverId) {
        this.driverId = driverId;
    }

    public String getDriverName() {
        return driverName;
    }

    public void setDriverName(String driverName) {
        this.driverName = driverName;
    }

    public LocalDate getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }

    public LocalDate getEndDate() {
        return endDate;
    }

    public void setEndDate(LocalDate endDate) {
        this.endDate = endDate;
    }

    public Integer getTotalOrders() {
        return totalOrders;
    }

    public void setTotalOrders(Integer totalOrders) {
        this.totalOrders = totalOrders;
    }

    public Integer getTotalBuckets() {
        return totalBuckets;
    }

    public void setTotalBuckets(Integer totalBuckets) {
        this.totalBuckets = totalBuckets;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public BigDecimal getDeliveryCommission() {
        return deliveryCommission;
    }

    public void setDeliveryCommission(BigDecimal deliveryCommission) {
        this.deliveryCommission = deliveryCommission;
    }

    public BigDecimal getCommissionRate() {
        return commissionRate;
    }

    public void setCommissionRate(BigDecimal commissionRate) {
        this.commissionRate = commissionRate;
    }

    public BigDecimal getMileageSubsidy() {
        return mileageSubsidy;
    }

    public void setMileageSubsidy(BigDecimal mileageSubsidy) {
        this.mileageSubsidy = mileageSubsidy;
    }

    public BigDecimal getTotalDistance() {
        return totalDistance;
    }

    public void setTotalDistance(BigDecimal totalDistance) {
        this.totalDistance = totalDistance;
    }

    public BigDecimal getActualAmount() {
        return actualAmount;
    }

    public void setActualAmount(BigDecimal actualAmount) {
        this.actualAmount = actualAmount;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getGeneratedAt() {
        return generatedAt;
    }

    public void setGeneratedAt(LocalDateTime generatedAt) {
        this.generatedAt = generatedAt;
    }

    public LocalDateTime getConfirmedAt() {
        return confirmedAt;
    }

    public void setConfirmedAt(LocalDateTime confirmedAt) {
        this.confirmedAt = confirmedAt;
    }

    public List<DeliveryRecord> getRecords() {
        return records;
    }

    public void setRecords(List<DeliveryRecord> records) {
        this.records = records;
    }

    @Schema(description = "配送记录")
    public static class DeliveryRecord {

        @Schema(description = "订单ID")
        private String orderId;

        @Schema(description = "水站名称")
        private String stationName;

        @Schema(description = "桶数")
        private Integer buckets;

        @Schema(description = "金额")
        private BigDecimal amount;

        @Schema(description = "配送日期")
        private LocalDate deliveryDate;

        public String getOrderId() {
            return orderId;
        }

        public void setOrderId(String orderId) {
            this.orderId = orderId;
        }

        public String getStationName() {
            return stationName;
        }

        public void setStationName(String stationName) {
            this.stationName = stationName;
        }

        public Integer getBuckets() {
            return buckets;
        }

        public void setBuckets(Integer buckets) {
            this.buckets = buckets;
        }

        public BigDecimal getAmount() {
            return amount;
        }

        public void setAmount(BigDecimal amount) {
            this.amount = amount;
        }

        public LocalDate getDeliveryDate() {
            return deliveryDate;
        }

        public void setDeliveryDate(LocalDate deliveryDate) {
            this.deliveryDate = deliveryDate;
        }
    }
}
