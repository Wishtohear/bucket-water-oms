package com.bucketwater.oms.module.product.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotEmpty;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
@Schema(description = "批量操作请求")
public class BatchProductRequest {

    @NotEmpty(message = "商品ID列表不能为空")
    @Schema(description = "商品ID列表")
    private List<Long> productIds;

    @Schema(description = "是否启用（可选）")
    private Boolean enabled;

    @Schema(description = "指导价（可选）")
    private BigDecimal guidePrice;

    @Schema(description = "最高指导价（可选）")
    private BigDecimal guidePriceMax;

    @Schema(description = "安全库存（可选）")
    private Integer safeStock;

    @Schema(description = "上下架状态: active/inactive（可选）")
    private String status;
}
