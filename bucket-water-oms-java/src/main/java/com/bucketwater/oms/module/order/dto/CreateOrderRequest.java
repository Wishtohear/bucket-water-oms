package com.bucketwater.oms.module.order.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;

import java.util.List;

@Schema(description = "创建订单请求")
public class CreateOrderRequest {

    @NotNull(message = "仓库ID不能为空")
    @Schema(description = "仓库ID")
    private Long warehouseId;

    @NotEmpty(message = "商品列表不能为空")
    @Valid
    @Schema(description = "商品列表")
    private List<OrderItemDTO> items;

    @NotBlank(message = "配送地址不能为空")
    @Schema(description = "配送地址")
    private String deliveryAddress;

    @NotBlank(message = "联系人不能为空")
    @Schema(description = "联系人")
    private String contactName;

    @NotBlank(message = "联系电话不能为空")
    @Schema(description = "联系电话")
    private String contactPhone;

    @Schema(description = "支付方式: prepaid/monthly/credit")
    private String paymentType;

    @Schema(description = "备注")
    private String remark;

    public Long getWarehouseId() {
        return warehouseId;
    }

    public void setWarehouseId(Long warehouseId) {
        this.warehouseId = warehouseId;
    }

    public List<OrderItemDTO> getItems() {
        return items;
    }

    public void setItems(List<OrderItemDTO> items) {
        this.items = items;
    }

    public String getDeliveryAddress() {
        return deliveryAddress;
    }

    public void setDeliveryAddress(String deliveryAddress) {
        this.deliveryAddress = deliveryAddress;
    }

    public String getContactName() {
        return contactName;
    }

    public void setContactName(String contactName) {
        this.contactName = contactName;
    }

    public String getContactPhone() {
        return contactPhone;
    }

    public void setContactPhone(String contactPhone) {
        this.contactPhone = contactPhone;
    }

    public String getPaymentType() {
        return paymentType;
    }

    public void setPaymentType(String paymentType) {
        this.paymentType = paymentType;
    }

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }

    @Schema(description = "订单商品项")
    public static class OrderItemDTO {

        @NotNull(message = "商品ID不能为空")
        @Schema(description = "商品ID")
        private Long productId;

        @NotNull(message = "数量不能为空")
        @Schema(description = "数量")
        private Integer quantity;

        public Long getProductId() {
            return productId;
        }

        public void setProductId(Long productId) {
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
