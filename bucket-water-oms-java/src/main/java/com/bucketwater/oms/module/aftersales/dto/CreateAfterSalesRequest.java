package com.bucketwater.oms.module.aftersales.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;

@Data
@Schema(description = "创建售后请求")
public class CreateAfterSalesRequest {

    @NotBlank(message = "原订单ID不能为空")
    @Schema(description = "原订单ID")
    private String originalOrderId;

    @NotBlank(message = "售后类型不能为空")
    @Schema(description = "类型: quality_issue/wrong_product/shortage")
    private String type;

    @NotBlank(message = "原因不能为空")
    @Schema(description = "原因")
    private String reason;

    @Schema(description = "图片列表")
    private List<String> photos;

    @NotBlank(message = "请求类型不能为空")
    @Schema(description = "请求类型: replenishment/refund")
    private String request;

    @Valid
    @Schema(description = "请求商品")
    private List<RequestedItem> requestedItems;

    public String getOriginalOrderId() {
        return originalOrderId;
    }

    public void setOriginalOrderId(String originalOrderId) {
        this.originalOrderId = originalOrderId;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public List<String> getPhotos() {
        return photos;
    }

    public void setPhotos(List<String> photos) {
        this.photos = photos;
    }

    public String getRequest() {
        return request;
    }

    public void setRequest(String request) {
        this.request = request;
    }

    public List<RequestedItem> getRequestedItems() {
        return requestedItems;
    }

    public void setRequestedItems(List<RequestedItem> requestedItems) {
        this.requestedItems = requestedItems;
    }

    @Data
    @Schema(description = "请求商品项")
    public static class RequestedItem {

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
