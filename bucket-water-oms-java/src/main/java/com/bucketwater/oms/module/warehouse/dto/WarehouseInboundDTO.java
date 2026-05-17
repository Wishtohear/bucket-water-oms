package com.bucketwater.oms.module.warehouse.dto;

import java.time.LocalDateTime;
import java.util.List;

public class WarehouseInboundDTO {
    private Long id;
    private String inboundNo;
    private String type;
    private String status;
    private String operator;
    private LocalDateTime createdAt;
    private LocalDateTime checkedAt;
    private String checker;
    private List<InboundItemDTO> items;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getInboundNo() { return inboundNo; }
    public void setInboundNo(String inboundNo) { this.inboundNo = inboundNo; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getOperator() { return operator; }
    public void setOperator(String operator) { this.operator = operator; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getCheckedAt() { return checkedAt; }
    public void setCheckedAt(LocalDateTime checkedAt) { this.checkedAt = checkedAt; }
    public String getChecker() { return checker; }
    public void setChecker(String checker) { this.checker = checker; }
    public List<InboundItemDTO> getItems() { return items; }
    public void setItems(List<InboundItemDTO> items) { this.items = items; }

    public static class InboundItemDTO {
        private Long productId;
        private String productName;
        private Integer quantity;
        private String remark;

        public Long getProductId() { return productId; }
        public void setProductId(Long productId) { this.productId = productId; }
        public String getProductName() { return productName; }
        public void setProductName(String productName) { this.productName = productName; }
        public Integer getQuantity() { return quantity; }
        public void setQuantity(Integer quantity) { this.quantity = quantity; }
        public String getRemark() { return remark; }
        public void setRemark(String remark) { this.remark = remark; }
    }
}
