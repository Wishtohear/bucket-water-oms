package com.bucketwater.oms.module.warehouse.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 备货订单 DTO
 */
@Schema(description = "备货订单响应DTO")
public class PreparingOrderDTO {

    @Schema(description = "订单ID")
    private String orderId;

    @Schema(description = "订单号")
    private String orderNo;

    @Schema(description = "水站ID")
    private Long stationId;

    @Schema(description = "水站名称")
    private String stationName;

    @Schema(description = "配送地址")
    private String deliveryAddress;

    @Schema(description = "联系人")
    private String contactName;

    @Schema(description = "联系电话")
    private String contactPhone;

    @Schema(description = "订单总金额")
    private BigDecimal totalAmount;

    @Schema(description = "支付方式")
    private String paymentType;

    @Schema(description = "状态")
    private String status;

    @Schema(description = "状态文本")
    private String statusText;

    @Schema(description = "商品清单")
    private List<OrderItemDTO> items;

    @Schema(description = "商品总数")
    private Integer totalQuantity;

    @Schema(description = "备货进度")
    private Integer preparingProgress;

    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @Schema(description = "派单时间")
    private LocalDateTime dispatchedAt;

    @Schema(description = "是否可操作")
    private Boolean canOperate;

    public PreparingOrderDTO() {}

    public String getOrderId() { return orderId; }
    public void setOrderId(String orderId) { this.orderId = orderId; }

    public String getOrderNo() { return orderNo; }
    public void setOrderNo(String orderNo) { this.orderNo = orderNo; }

    public Long getStationId() { return stationId; }
    public void setStationId(Long stationId) { this.stationId = stationId; }

    public String getStationName() { return stationName; }
    public void setStationName(String stationName) { this.stationName = stationName; }

    public String getDeliveryAddress() { return deliveryAddress; }
    public void setDeliveryAddress(String deliveryAddress) { this.deliveryAddress = deliveryAddress; }

    public String getContactName() { return contactName; }
    public void setContactName(String contactName) { this.contactName = contactName; }

    public String getContactPhone() { return contactPhone; }
    public void setContactPhone(String contactPhone) { this.contactPhone = contactPhone; }

    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }

    public String getPaymentType() { return paymentType; }
    public void setPaymentType(String paymentType) { this.paymentType = paymentType; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getStatusText() { return statusText; }
    public void setStatusText(String statusText) { this.statusText = statusText; }

    public List<OrderItemDTO> getItems() { return items; }
    public void setItems(List<OrderItemDTO> items) { this.items = items; }

    public Integer getTotalQuantity() { return totalQuantity; }
    public void setTotalQuantity(Integer totalQuantity) { this.totalQuantity = totalQuantity; }

    public Integer getPreparingProgress() { return preparingProgress; }
    public void setPreparingProgress(Integer preparingProgress) { this.preparingProgress = preparingProgress; }

    public LocalDateTime getCreateTime() { return createTime; }
    public void setCreateTime(LocalDateTime createTime) { this.createTime = createTime; }

    public LocalDateTime getDispatchedAt() { return dispatchedAt; }
    public void setDispatchedAt(LocalDateTime dispatchedAt) { this.dispatchedAt = dispatchedAt; }

    public Boolean getCanOperate() { return canOperate; }
    public void setCanOperate(Boolean canOperate) { this.canOperate = canOperate; }

    @Schema(description = "订单商品项")
    public static class OrderItemDTO {
        @Schema(description = "商品ID")
        private String productId;

        @Schema(description = "商品名称")
        private String productName;

        @Schema(description = "订购数量")
        private Integer quantity;

        @Schema(description = "是否已备货")
        private Boolean prepared;

        public OrderItemDTO() {}

        public OrderItemDTO(String productId, String productName, Integer quantity, Boolean prepared) {
            this.productId = productId;
            this.productName = productName;
            this.quantity = quantity;
            this.prepared = prepared;
        }

        public String getProductId() { return productId; }
        public void setProductId(String productId) { this.productId = productId; }

        public String getProductName() { return productName; }
        public void setProductName(String productName) { this.productName = productName; }

        public Integer getQuantity() { return quantity; }
        public void setQuantity(Integer quantity) { this.quantity = quantity; }

        public Boolean getPrepared() { return prepared; }
        public void setPrepared(Boolean prepared) { this.prepared = prepared; }
    }
}
