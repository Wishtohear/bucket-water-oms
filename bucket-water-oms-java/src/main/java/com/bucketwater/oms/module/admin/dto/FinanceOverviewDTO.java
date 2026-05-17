package com.bucketwater.oms.module.admin.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class FinanceOverviewDTO {
    private BigDecimal monthTotalReceivable;
    private Double receivableGrowthRate;
    private BigDecimal monthCollected;
    private Double collectionRate;
    private Integer pendingDisputes;
    private BigDecimal totalArrears;
    private Integer arrearsStations;
    private List<StatementItem> recentStatements;

    public BigDecimal getMonthTotalReceivable() {
        return monthTotalReceivable;
    }

    public void setMonthTotalReceivable(BigDecimal monthTotalReceivable) {
        this.monthTotalReceivable = monthTotalReceivable;
    }

    public Double getReceivableGrowthRate() {
        return receivableGrowthRate;
    }

    public void setReceivableGrowthRate(Double receivableGrowthRate) {
        this.receivableGrowthRate = receivableGrowthRate;
    }

    public BigDecimal getMonthCollected() {
        return monthCollected;
    }

    public void setMonthCollected(BigDecimal monthCollected) {
        this.monthCollected = monthCollected;
    }

    public Double getCollectionRate() {
        return collectionRate;
    }

    public void setCollectionRate(Double collectionRate) {
        this.collectionRate = collectionRate;
    }

    public Integer getPendingDisputes() {
        return pendingDisputes;
    }

    public void setPendingDisputes(Integer pendingDisputes) {
        this.pendingDisputes = pendingDisputes;
    }

    public BigDecimal getTotalArrears() {
        return totalArrears;
    }

    public void setTotalArrears(BigDecimal totalArrears) {
        this.totalArrears = totalArrears;
    }

    public Integer getArrearsStations() {
        return arrearsStations;
    }

    public void setArrearsStations(Integer arrearsStations) {
        this.arrearsStations = arrearsStations;
    }

    public List<StatementItem> getRecentStatements() {
        return recentStatements;
    }

    public void setRecentStatements(List<StatementItem> recentStatements) {
        this.recentStatements = recentStatements;
    }

    @Data
    public static class StatementItem {
        private String statementId;
        private String period;
        private String stationName;
        private BigDecimal transactionAmount;
        private BigDecimal currentBalance;
        private String status;
        private String statusText;

        public String getStatementId() {
            return statementId;
        }

        public void setStatementId(String statementId) {
            this.statementId = statementId;
        }

        public String getPeriod() {
            return period;
        }

        public void setPeriod(String period) {
            this.period = period;
        }

        public String getStationName() {
            return stationName;
        }

        public void setStationName(String stationName) {
            this.stationName = stationName;
        }

        public BigDecimal getTransactionAmount() {
            return transactionAmount;
        }

        public void setTransactionAmount(BigDecimal transactionAmount) {
            this.transactionAmount = transactionAmount;
        }

        public BigDecimal getCurrentBalance() {
            return currentBalance;
        }

        public void setCurrentBalance(BigDecimal currentBalance) {
            this.currentBalance = currentBalance;
        }

        public String getStatus() {
            return status;
        }

        public void setStatus(String status) {
            this.status = status;
        }

        public String getStatusText() {
            return statusText;
        }

        public void setStatusText(String statusText) {
            this.statusText = statusText;
        }
    }
}
