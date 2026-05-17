package com.bucketwater.oms.module.admin.dto;

import lombok.Data;

import java.math.BigDecimal;

/**
 * Dashboard统计DTO - 匹配前端期望的数据结构
 */
@Data
public class DashboardStatsDTO {
    /**
     * 今日销售额
     */
    private BigDecimal todaySales;

    /**
     * 今日订单数
     */
    private Integer todayOrders;

    /**
     * 活跃水站数
     */
    private Integer activeStations;

    /**
     * 库存预警数 (兼容PC端 lowStockItems)
     */
    private Integer stockWarnings;

    /**
     * 库存预警数 (兼容PC端 lowStockItems)
     */
    private Integer lowStockItems;

    /**
     * 告警数量
     */
    private Integer alerts;

    /**
     * 销售额增长率(百分比)
     */
    private Double salesGrowth;

    /**
     * 订单增长率(百分比)
     */
    private Double ordersGrowth;

    public BigDecimal getTodaySales() {
        return todaySales;
    }

    public void setTodaySales(BigDecimal todaySales) {
        this.todaySales = todaySales;
    }

    public Integer getTodayOrders() {
        return todayOrders;
    }

    public void setTodayOrders(Integer todayOrders) {
        this.todayOrders = todayOrders;
    }

    public Integer getActiveStations() {
        return activeStations;
    }

    public void setActiveStations(Integer activeStations) {
        this.activeStations = activeStations;
    }

    public Integer getStockWarnings() {
        return stockWarnings;
    }

    public void setStockWarnings(Integer stockWarnings) {
        this.stockWarnings = stockWarnings;
    }

    public Integer getLowStockItems() {
        return lowStockItems;
    }

    public void setLowStockItems(Integer lowStockItems) {
        this.lowStockItems = lowStockItems;
    }

    public Integer getAlerts() {
        return alerts;
    }

    public void setAlerts(Integer alerts) {
        this.alerts = alerts;
    }

    public Double getSalesGrowth() {
        return salesGrowth;
    }

    public void setSalesGrowth(Double salesGrowth) {
        this.salesGrowth = salesGrowth;
    }

    public Double getOrdersGrowth() {
        return ordersGrowth;
    }

    public void setOrdersGrowth(Double ordersGrowth) {
        this.ordersGrowth = ordersGrowth;
    }
}
