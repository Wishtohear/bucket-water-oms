package com.bucketwater.oms.module.warehouse.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

@Data
@Schema(description = "仓库库存DTO")
public class WarehouseInventoryDTO {

    @Schema(description = "库存ID")
    private Long id;

    @Schema(description = "仓库ID")
    private Long warehouseId;

    @Schema(description = "商品ID")
    private Long productId;

    @Schema(description = "商品名称")
    private String productName;

    @Schema(description = "商品分类")
    private String category;

    @Schema(description = "库存数量")
    private Integer quantity;

    @Schema(description = "安全库存")
    private Integer safeStock;

    @Schema(description = "更新时间")
    private String updatedAt;
}
