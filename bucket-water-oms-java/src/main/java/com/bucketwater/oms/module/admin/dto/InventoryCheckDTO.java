package com.bucketwater.oms.module.admin.dto;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
public class InventoryCheckDTO {
    private String id;
    private String warehouseId;
    private String warehouseName;
    private LocalDateTime checkDate;
    private String checker;
    private String status;
    private String statusText;
    private String summary;
    private Integer totalProducts;
    private Integer matchedProducts;
    private Integer discrepancyProducts;
    private LocalDateTime createTime;
    private List<InventoryCheckItemDTO> items;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getWarehouseId() {
        return warehouseId;
    }

    public void setWarehouseId(String warehouseId) {
        this.warehouseId = warehouseId;
    }

    public String getWarehouseName() {
        return warehouseName;
    }

    public void setWarehouseName(String warehouseName) {
        this.warehouseName = warehouseName;
    }

    public LocalDateTime getCheckDate() {
        return checkDate;
    }

    public void setCheckDate(LocalDateTime checkDate) {
        this.checkDate = checkDate;
    }

    public String getChecker() {
        return checker;
    }

    public void setChecker(String checker) {
        this.checker = checker;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
        this.statusText = "confirmed".equals(status) ? "已确认" : "待确认";
    }

    public String getStatusText() {
        return statusText;
    }

    public void setStatusText(String statusText) {
        this.statusText = statusText;
    }

    public String getSummary() {
        return summary;
    }

    public void setSummary(String summary) {
        this.summary = summary;
    }

    public Integer getTotalProducts() {
        return totalProducts;
    }

    public void setTotalProducts(Integer totalProducts) {
        this.totalProducts = totalProducts;
    }

    public Integer getMatchedProducts() {
        return matchedProducts;
    }

    public void setMatchedProducts(Integer matchedProducts) {
        this.matchedProducts = matchedProducts;
    }

    public Integer getDiscrepancyProducts() {
        return discrepancyProducts;
    }

    public void setDiscrepancyProducts(Integer discrepancyProducts) {
        this.discrepancyProducts = discrepancyProducts;
    }

    public LocalDateTime getCreateTime() {
        return createTime;
    }

    public void setCreateTime(LocalDateTime createTime) {
        this.createTime = createTime;
    }

    public List<InventoryCheckItemDTO> getItems() {
        return items;
    }

    public void setItems(List<InventoryCheckItemDTO> items) {
        this.items = items;
    }
}
