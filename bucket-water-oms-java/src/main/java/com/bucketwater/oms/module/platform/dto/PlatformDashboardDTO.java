package com.bucketwater.oms.module.platform.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.util.List;
import java.util.Map;

@Data
@Schema(description = "平台Dashboard统计数据")
public class PlatformDashboardDTO {

    @Schema(description = "统计数据")
    private Stats stats;

    @Schema(description = "水厂列表")
    private List<Map<String, Object>> factories;

    @Data
    public static class Stats {
        @Schema(description = "水厂总数")
        private Long totalFactories;

        @Schema(description = "水站总数")
        private Long totalStations;

        @Schema(description = "司机总数")
        private Long totalDrivers;

        @Schema(description = "订单总数")
        private Long totalOrders;

        @Schema(description = "今日订单数")
        private Long todayOrders;

        @Schema(description = "今日销售额")
        private java.math.BigDecimal todaySales;

        @Schema(description = "在用仓库数")
        private Long totalWarehouses;
    }
}
