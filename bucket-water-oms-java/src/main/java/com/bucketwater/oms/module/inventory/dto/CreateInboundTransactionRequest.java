package com.bucketwater.oms.module.inventory.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
@Schema(description = "创建入库记录请求")
public class CreateInboundTransactionRequest {

    @Schema(description = "入库类型: production-生产入库, purchase-采购入库, transfer_in-调拨入库, return-退货入库")
    @NotBlank(message = "入库类型不能为空")
    private String inboundType;

    @Schema(description = "产品列表")
    @NotNull(message = "产品列表不能为空")
    private List<InboundItem> items;

    @Schema(description = "来源")
    private String source;

    @Schema(description = "关联订单号")
    private String relatedOrderNo;

    @Schema(description = "备注")
    private String remark;

    @Data
    public static class InboundItem {
        @Schema(description = "产品ID")
        @NotNull(message = "产品ID不能为空")
        private Long productId;

        @Schema(description = "入库数量")
        @NotNull(message = "入库数量不能为空")
        @Min(value = 1, message = "入库数量必须大于0")
        private Integer quantity;

        @Schema(description = "单价")
        private BigDecimal unitPrice;

        @Schema(description = "备注")
        private String remark;
    }
}
