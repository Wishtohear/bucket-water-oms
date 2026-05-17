package com.bucketwater.oms.module.order.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;

import java.util.List;

/**
 * 修改订单请求
 * 所有字段都是可选的，只更新传入的字段
 */
@Schema(description = "修改订单请求")
public class UpdateOrderRequest {

    @Schema(description = "仓库ID（可选）")
    private Long warehouseId;

    @Valid
    @Schema(description = "商品列表（可选）")
    private List<OrderItemDTO> items;

    @Schema(description = "配送地址（可选）")
    private String deliveryAddress;

    @Schema(description = "联系人（可选）")
    private String contactName;

    @Schema(description = "联系电话（可选）")
    private String contactPhone;

    @Schema(description = "支付方式: prepaid/monthly/credit（可选）")
    private String paymentType;

    @Schema(description = "备注（可选）")
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

    /**
     * 检查是否有任何字段被更新
     */
    public boolean hasUpdates() {
        return warehouseId != null
            || (items != null && !items.isEmpty())
            || deliveryAddress != null
            || contactName != null
            || contactPhone != null
            || paymentType != null
            || remark != null;
    }

    @Schema(description = "订单商品项")
    public static class OrderItemDTO {

        @Schema(description = "商品ID")
        private Long productId;

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
