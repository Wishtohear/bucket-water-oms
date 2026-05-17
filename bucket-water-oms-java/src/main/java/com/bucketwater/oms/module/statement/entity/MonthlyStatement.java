package com.bucketwater.oms.module.statement.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("monthly_statement")
@Schema(description = "对账单实体")
public class MonthlyStatement {

    @TableId(type = IdType.AUTO)
    @Schema(description = "主键ID")
    private Long id;

    @TableField("station_id")
    @Schema(description = "水站ID")
    private Long stationId;

    @Schema(description = "账单月份（如2026-04）")
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

    @Schema(description = "状态: generated/confirmed/disputed")
    private String status;

    @Schema(description = "生成时间")
    private LocalDateTime generatedAt;

    @Schema(description = "确认时间")
    private LocalDateTime confirmedAt;

    @Schema(description = "异议内容")
    private String disputeReason;

    @Schema(description = "异议时间")
    private LocalDateTime disputedAt;

    @Schema(description = "结算金额")
    private BigDecimal settlementAmount;

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

    public String getYearMonth() {
        return yearMonth;
    }

    public void setYearMonth(String yearMonth) {
        this.yearMonth = yearMonth;
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

    public BigDecimal getOpeningBalance() {
        return openingBalance;
    }

    public void setOpeningBalance(BigDecimal openingBalance) {
        this.openingBalance = openingBalance;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public BigDecimal getPaymentReceived() {
        return paymentReceived;
    }

    public void setPaymentReceived(BigDecimal paymentReceived) {
        this.paymentReceived = paymentReceived;
    }

    public BigDecimal getClosingBalance() {
        return closingBalance;
    }

    public void setClosingBalance(BigDecimal closingBalance) {
        this.closingBalance = closingBalance;
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

    public String getDisputeReason() {
        return disputeReason;
    }

    public void setDisputeReason(String disputeReason) {
        this.disputeReason = disputeReason;
    }

    public LocalDateTime getDisputedAt() {
        return disputedAt;
    }

    public void setDisputedAt(LocalDateTime disputedAt) {
        this.disputedAt = disputedAt;
    }

    public BigDecimal getSettlementAmount() {
        return settlementAmount;
    }

    public void setSettlementAmount(BigDecimal settlementAmount) {
        this.settlementAmount = settlementAmount;
    }
}
