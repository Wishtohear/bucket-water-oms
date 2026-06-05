package com.bucketwater.oms.module.factory.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.util.List;
import java.util.Map;

@Data
@Schema(description = "水厂详情(含统计与关联账号)")
public class FactoryDetailDTO {

    @Schema(description = "水厂基本信息")
    private Map<String, Object> factory;

    @Schema(description = "统计数据")
    private Stats stats;

    @Schema(description = "关联账号列表")
    private List<Map<String, Object>> admins;

    @Data
    public static class Stats {
        @Schema(description = "水站数量")
        private Long stations;
        @Schema(description = "仓库数量")
        private Long warehouses;
        @Schema(description = "司机数量")
        private Long drivers;
        @Schema(description = "订单数量")
        private Long orders;
        @Schema(description = "今日订单数")
        private Long todayOrders;
        @Schema(description = "本月销售额")
        private java.math.BigDecimal monthSales;
    }
}
