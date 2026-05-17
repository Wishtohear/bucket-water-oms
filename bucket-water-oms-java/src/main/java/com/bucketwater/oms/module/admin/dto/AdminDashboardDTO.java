package com.bucketwater.oms.module.admin.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@Data
public class AdminDashboardDTO {
    private TodayStats todayStats;
    private List<SalesTrend> salesTrend;
    private List<Notification> notifications;
    private InventoryWarning inventoryWarning;

    public TodayStats getTodayStats() {
        return todayStats;
    }

    public void setTodayStats(TodayStats todayStats) {
        this.todayStats = todayStats;
    }

    public List<SalesTrend> getSalesTrend() {
        return salesTrend;
    }

    public void setSalesTrend(List<SalesTrend> salesTrend) {
        this.salesTrend = salesTrend;
    }

    public List<Notification> getNotifications() {
        return notifications;
    }

    public void setNotifications(List<Notification> notifications) {
        this.notifications = notifications;
    }

    public InventoryWarning getInventoryWarning() {
        return inventoryWarning;
    }

    public void setInventoryWarning(InventoryWarning inventoryWarning) {
        this.inventoryWarning = inventoryWarning;
    }

    @Data
    public static class TodayStats {
        private BigDecimal todaySales;
        private Double salesGrowthRate;
        private Integer todayOrders;
        private Double ordersGrowthRate;
        private Integer activeStations;
        private Integer inventoryAlerts;

        public BigDecimal getTodaySales() {
            return todaySales;
        }

        public void setTodaySales(BigDecimal todaySales) {
            this.todaySales = todaySales;
        }

        public Double getSalesGrowthRate() {
            return salesGrowthRate;
        }

        public void setSalesGrowthRate(Double salesGrowthRate) {
            this.salesGrowthRate = salesGrowthRate;
        }

        public Integer getTodayOrders() {
            return todayOrders;
        }

        public void setTodayOrders(Integer todayOrders) {
            this.todayOrders = todayOrders;
        }

        public Double getOrdersGrowthRate() {
            return ordersGrowthRate;
        }

        public void setOrdersGrowthRate(Double ordersGrowthRate) {
            this.ordersGrowthRate = ordersGrowthRate;
        }

        public Integer getActiveStations() {
            return activeStations;
        }

        public void setActiveStations(Integer activeStations) {
            this.activeStations = activeStations;
        }

        public Integer getInventoryAlerts() {
            return inventoryAlerts;
        }

        public void setInventoryAlerts(Integer inventoryAlerts) {
            this.inventoryAlerts = inventoryAlerts;
        }
    }

    @Data
    public static class SalesTrend {
        private String date;
        private BigDecimal salesAmount;
        private Integer orderCount;

        public String getDate() {
            return date;
        }

        public void setDate(String date) {
            this.date = date;
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
    public static class Notification {
        private String id;
        private String type;
        private String typeText;
        private String content;
        private String time;
        private String level;

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

        public String getContent() {
            return content;
        }

        public void setContent(String content) {
            this.content = content;
        }

        public String getTime() {
            return time;
        }

        public void setTime(String time) {
            this.time = time;
        }

        public String getLevel() {
            return level;
        }

        public void setLevel(String level) {
            this.level = level;
        }
    }

    @Data
    public static class InventoryWarning {
        private Integer totalWarningProducts;
        private List<Map<String, Object>> warnings;

        public Integer getTotalWarningProducts() {
            return totalWarningProducts;
        }

        public void setTotalWarningProducts(Integer totalWarningProducts) {
            this.totalWarningProducts = totalWarningProducts;
        }

        public List<Map<String, Object>> getWarnings() {
            return warnings;
        }

        public void setWarnings(List<Map<String, Object>> warnings) {
            this.warnings = warnings;
        }
    }
}
