package com.bucketwater.oms.module.inventory.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
@Schema(description = "库存调整审批请求")
public class InventoryAdjustmentRequest {

    @NotNull(message = "仓库ID不能为空")
    @Schema(description = "仓库ID")
    private Long warehouseId;

    @Schema(description = "调整类型: add/reduce/set")
    private String adjustmentType;

    @Schema(description = "调整原因")
    private String reason;

    @Schema(description = "调整明细")
    private List<AdjustmentItem> items;

    @Data
    @Schema(description = "调整明细项")
    public static class AdjustmentItem {
        @Schema(description = "商品ID")
        private Long productId;

        @Schema(description = "调整数量")
        private Integer quantity;

        @Schema(description = "备注")
        private String remark;
    }
}
