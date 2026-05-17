package com.bucketwater.oms.module.admin.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class ReportStatsDTO {
    private SalesTrendReport salesTrend;
    private ProductDistributionReport productDistribution;
    private List<StationRanking> stationRankings;
    private List<DailySalesReport> dailyReports;

    public SalesTrendReport getSalesTrend() {
        return salesTrend;
    }

    public void setSalesTrend(SalesTrendReport salesTrend) {
        this.salesTrend = salesTrend;
    }

    public ProductDistributionReport getProductDistribution() {
        return productDistribution;
    }

    public void setProductDistribution(ProductDistributionReport productDistribution) {
        this.productDistribution = productDistribution;
    }

    public List<StationRanking> getStationRankings() {
        return stationRankings;
    }

    public void setStationRankings(List<StationRanking> stationRankings) {
        this.stationRankings = stationRankings;
    }

    public List<DailySalesReport> getDailyReports() {
        return dailyReports;
    }

    public void setDailyReports(List<DailySalesReport> dailyReports) {
        this.dailyReports = dailyReports;
    }

    @Data
    public static class SalesTrendReport {
        private String startMonth;
        private String endMonth;
        private List<MonthlyData> data;

        public String getStartMonth() {
            return startMonth;
        }

        public void setStartMonth(String startMonth) {
            this.startMonth = startMonth;
        }

        public String getEndMonth() {
            return endMonth;
        }

        public void setEndMonth(String endMonth) {
            this.endMonth = endMonth;
        }

        public List<MonthlyData> getData() {
            return data;
        }

        public void setData(List<MonthlyData> data) {
            this.data = data;
        }
    }

    @Data
    public static class MonthlyData {
        private String month;
        private BigDecimal salesAmount;
        private Integer orderCount;

        public String getMonth() {
            return month;
        }

        public void setMonth(String month) {
            this.month = month;
        }

        public BigDecimal getSalesAmount() {
            return salesAmount;
        }

        public void setSalesAmount(BigDecimal salesAmount) {
            this.salesAmount = salesAmount;
        }

        public Integer getOrderCount() {
            return orderCount;
        }

        public void setOrderCount(Integer orderCount) {
            this.orderCount = orderCount;
        }
    }

    @Data
    public static class ProductDistributionReport {
        private Integer totalQuantity;
        private List<CategoryDistribution> categories;

        public Integer getTotalQuantity() {
            return totalQuantity;
        }

        public void setTotalQuantity(Integer totalQuantity) {
            this.totalQuantity = totalQuantity;
        }

        public List<CategoryDistribution> getCategories() {
            return categories;
        }

        public void setCategories(List<CategoryDistribution> categories) {
            this.categories = categories;
        }
    }

    @Data
    public static class CategoryDistribution {
        private String category;
        private String categoryText;
        private Integer quantity;
        private Double percentage;

        public String getCategory() {
            return category;
        }

        public void setCategory(String category) {
            this.category = category;
        }

        public String getCategoryText() {
            return categoryText;
        }

        public void setCategoryText(String categoryText) {
            this.categoryText = categoryText;
        }

        public Integer getQuantity() {
            return quantity;
        }

        public void setQuantity(Integer quantity) {
            this.quantity = quantity;
        }

        public Double getPercentage() {
            return percentage;
        }

        public void setPercentage(Double percentage) {
            this.percentage = percentage;
        }
    }

    @Data
    public static class StationRanking {
        private Integer rank;
        private String stationId;
        private String stationName;
        private BigDecimal totalAmount;
        private Double percentage;

        public Integer getRank() {
            return rank;
        }

        public void setRank(Integer rank) {
            this.rank = rank;
        }

        public String getStationId() {
            return stationId;
        }

        public void setStationId(String stationId) {
            this.stationId = stationId;
        }

        public String getStationName() {
            return stationName;
        }

        public void setStationName(String stationName) {
            this.stationName = stationName;
        }

        public BigDecimal getTotalAmount() {
            return totalAmount;
        }

        public void setTotalAmount(BigDecimal totalAmount) {
            this.totalAmount = totalAmount;
        }

        public Double getPercentage() {
            return percentage;
        }

        public void setPercentage(Double percentage) {
            this.percentage = percentage;
        }
    }

    @Data
    public static class DailySalesReport {
        private String date;
        private String dateText;
        private Integer orderQuantity;
        private Integer bucketReturned;
        private BigDecimal salesAmount;
        private Integer newStations;

        public String getDate() {
            return date;
        }

        public void setDate(String date) {
            this.date = date;
        }

        public String getDateText() {
            return dateText;
        }

        public void setDateText(String dateText) {
            this.dateText = dateText;
        }

        public Integer getOrderQuantity() {
            return orderQuantity;
        }

        public void setOrderQuantity(Integer orderQuantity) {
            this.orderQuantity = orderQuantity;
        }

        public Integer getBucketReturned() {
            return bucketReturned;
        }

        public void setBucketReturned(Integer bucketReturned) {
            this.bucketReturned = bucketReturned;
        }

        public BigDecimal getSalesAmount() {
            return salesAmount;
        }

        public void setSalesAmount(BigDecimal salesAmount) {
            this.salesAmount = salesAmount;
        }

        public Integer getNewStations() {
            return newStations;
        }

        public void setNewStations(Integer newStations) {
            this.newStations = newStations;
        }
    }
}
