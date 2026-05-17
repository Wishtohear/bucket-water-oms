package com.bucketwater.oms.module.aftersales.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;

/**
 * 创建售后请求DTO（新版本）
 */
@Data
@Schema(description = "创建售后请求DTO（新版本）")
public class CreateAfterSalesRequestV2 {

    @NotBlank(message = "订单ID不能为空")
    @Schema(description = "关联订单ID")
    private String orderId;

    @NotBlank(message = "售后类型不能为空")
    @Schema(description = "售后类型: replenishment-补货, refund-退款, return-退货")
    private String type;

    @Valid
    @NotEmpty(message = "售后商品不能为空")
    @Schema(description = "售后商品明细")
    private List<AfterSalesItemRequest> items;

    @Schema(description = "售后原因")
    private String reason;

    @Schema(description = "图片列表（Base64编码）")
    private List<String> images;

    public String getOrderId() {
        return orderId;
    }

    public void setOrderId(String orderId) {
        this.orderId = orderId;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public List<AfterSalesItemRequest> getItems() {
        return items;
    }

    public void setItems(List<AfterSalesItemRequest> items) {
        this.items = items;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public List<String> getImages() {
        return images;
    }

    public void setImages(List<String> images) {
        this.images = images;
    }

    @Data
    @Schema(description = "售后商品请求项")
    public static class AfterSalesItemRequest {

        @NotBlank(message = "商品ID不能为空")
        @Schema(description = "商品ID")
        private String productId;

        @NotNull(message = "数量不能为空")
        @Schema(description = "数量")
        private Integer quantity;

        public String getProductId() {
            return productId;
        }

        public void setProductId(String productId) {
            this.productId = productId;
        }

        public Integer getQuantity() {
            return quantity;
        }

        public void setQuantity(Integer quantity) {
            this.quantity = quantity;
        }
    }
}
