package com.bucketwater.oms.module.warehouse.dto;

import java.time.LocalDateTime;
import java.util.List;

public class WarehouseOutboundDTO {
    private Long id;
    private String outboundNo;
    private String type;
    private String status;
    private String orderId;
    private String stationName;
    private String driverName;
    private String operator;
    private LocalDateTime createdAt;
    private List<OutboundItemDTO> items;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getOutboundNo() { return outboundNo; }
    public void setOutboundNo(String outboundNo) { this.outboundNo = outboundNo; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getOrderId() { return orderId; }
    public void setOrderId(String orderId) { this.orderId = orderId; }
    public String getStationName() { return stationName; }
    public void setStationName(String stationName) { this.stationName = stationName; }
    public String getDriverName() { return driverName; }
    public void setDriverName(String driverName) { this.driverName = driverName; }
    public String getOperator() { return operator; }
    public void setOperator(String operator) { this.operator = operator; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public List<OutboundItemDTO> getItems() { return items; }
    public void setItems(List<OutboundItemDTO> items) { this.items = items; }

    public static class OutboundItemDTO {
        private Long productId;
        private String productName;
        private Integer quantity;

        public Long getProductId() { return productId; }
        public void setProductId(Long productId) { this.productId = productId; }
        public String getProductName() { return productName; }
        public void setProductName(String productName) { this.productName = productName; }
        public Integer getQuantity() { return quantity; }
        public void setQuantity(Integer quantity) { this.quantity = quantity; }
    }
}
