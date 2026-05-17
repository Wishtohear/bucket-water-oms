package com.bucketwater.oms.module.admin.dto;

import lombok.Data;

import java.util.List;

@Data
public class CreateInventoryCheckRequest {
    private String warehouseId;
    private String checker;
    private String summary;
    private List<InventoryCheckItemDTO> items;

    public String getWarehouseId() {
        return warehouseId;
    }

    public void setWarehouseId(String warehouseId) {
        this.warehouseId = warehouseId;
    }

    public String getChecker() {
        return checker;
    }

    public void setChecker(String checker) {
        this.checker = checker;
    }

    public String getSummary() {
        return summary;
    }

    public void setSummary(String summary) {
        this.summary = summary;
    }

    public List<InventoryCheckItemDTO> getItems() {
        return items;
    }

    public void setItems(List<InventoryCheckItemDTO> items) {
        this.items = items;
    }
}
