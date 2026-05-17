package com.bucketwater.oms.module.admin.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class InventoryRecordDTO {
    private String id;
    private LocalDateTime operateTime;
    private String businessType;
    private String businessTypeText;
    private String productName;
    private Integer quantityChange;
    private String relatedObject;
    private String operator;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public LocalDateTime getOperateTime() {
        return operateTime;
    }

    public void setOperateTime(LocalDateTime operateTime) {
        this.operateTime = operateTime;
    }

    public String getBusinessType() {
        return businessType;
    }

    public void setBusinessType(String businessType) {
        this.businessType = businessType;
    }

    public String getBusinessTypeText() {
        return businessTypeText;
    }

    public void setBusinessTypeText(String businessTypeText) {
        this.businessTypeText = businessTypeText;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public Integer getQuantityChange() {
        return quantityChange;
    }

    public void setQuantityChange(Integer quantityChange) {
        this.quantityChange = quantityChange;
    }

    public String getRelatedObject() {
        return relatedObject;
    }

    public void setRelatedObject(String relatedObject) {
        this.relatedObject = relatedObject;
    }

    public String getOperator() {
        return operator;
    }

    public void setOperator(String operator) {
        this.operator = operator;
    }
}
