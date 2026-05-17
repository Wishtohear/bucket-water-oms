package com.bucketwater.oms.module.warehouse.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;

import java.util.List;

@Schema(description = "创建入库请求")
public class CreateInboundRequest {

    @NotNull(message = "入库类型不能为空")
    @Schema(description = "入库类型: purchase/return")
    private String type;

    @Schema(description = "入库明细")
    private List<InboundItem> items;

    @Schema(description = "备注")
    private String remark;

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public List<InboundItem> getItems() { return items; }
    public void setItems(List<InboundItem> items) { this.items = items; }
    public String getRemark() { return remark; }
    public void setRemark(String remark) { this.remark = remark; }

    @Schema(description = "入库明细项")
    public static class InboundItem {

        @NotNull(message = "商品ID不能为空")
        @Schema(description = "商品ID")
        private Long productId;

        @NotNull(message = "数量不能为空")
        @Schema(description = "数量")
        private Integer quantity;

        @Schema(description = "备注")
        private String remark;

        public Long getProductId() { return productId; }
        public void setProductId(Long productId) { this.productId = productId; }
        public Integer getQuantity() { return quantity; }
        public void setQuantity(Integer quantity) { this.quantity = quantity; }
        public String getRemark() { return remark; }
        public void setRemark(String remark) { this.remark = remark; }
    }
}
