package com.bucketwater.oms.module.inventory.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;

@Data
@Schema(description = "创建库存盘点任务请求")
public class CreateInventoryCheckRequest {

    @Schema(description = "仓库ID")
    @NotNull(message = "仓库ID不能为空")
    private Long warehouseId;

    @Schema(description = "备注")
    private String remark;

    @Schema(description = "盘点产品列表(如果为空则盘点仓库所有产品)")
    private List<CheckProduct> products;

    @Data
    public static class CheckProduct {
        @Schema(description = "产品ID")
        @NotNull(message = "产品ID不能为空")
        private Long productId;

        @Schema(description = "实际库存数量")
        @NotNull(message = "实际库存不能为空")
        private Integer actualQuantity;

        @Schema(description = "备注")
        private String remark;
    }
}
