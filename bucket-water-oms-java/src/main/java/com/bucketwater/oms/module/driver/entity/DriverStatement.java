package com.bucketwater.oms.module.driver.entity;

import com.baomidou.mybatisplus.annotation.*;
import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@TableName("driver_statement")
@Schema(description = "司机对账单实体")
public class DriverStatement {

    @TableId(type = IdType.AUTO)
    @Schema(description = "主键ID")
    private Long id;

    @Schema(description = "对账单号")
    private String statementNo;

    @Schema(description = "司机ID")
    private Long driverId;

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

    @TableField(fill = FieldFill.INSERT)
    @Schema(description = "生成时间")
    private LocalDateTime createdAt;

    @Schema(description = "确认时间")
    private LocalDateTime confirmedAt;

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

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getConfirmedAt() {
        return confirmedAt;
    }

    public void setConfirmedAt(LocalDateTime confirmedAt) {
        this.confirmedAt = confirmedAt;
    }
}
