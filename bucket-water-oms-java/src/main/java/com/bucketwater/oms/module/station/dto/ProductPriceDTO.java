package com.bucketwater.oms.module.station.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "水站商品价格DTO，包含单价和最低起订量")
public class ProductPriceDTO {

    @Schema(description = "商品ID")
    private Long productId;

    @Schema(description = "商品名称")
    private String productName;

    @Schema(description = "单价（元）")
    private BigDecimal unitPrice;

    @Schema(description = "最低起订量")
    private Integer minOrderQuantity;

    @Schema(description = "阶梯价信息")
    private TierPriceInfo tierPrice;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Schema(description = "阶梯价信息")
    public static class TierPriceInfo {
        @Schema(description = "阶梯价")
        private BigDecimal price;

        @Schema(description = "最低数量要求")
        private Integer minQuantity;
    }
}
