package com.bucketwater.oms.module.admin.dto;

import lombok.Data;

import java.util.List;

@Data
public class InventoryOverviewDTO {
    private List<WarehouseInventory> warehouses;
    private List<ProductInventory> products;
    private String lastUpdateTime;

    public List<WarehouseInventory> getWarehouses() {
        return warehouses;
    }

    public void setWarehouses(List<WarehouseInventory> warehouses) {
        this.warehouses = warehouses;
    }

    public List<ProductInventory> getProducts() {
        return products;
    }

    public void setProducts(List<ProductInventory> products) {
        this.products = products;
    }

    public String getLastUpdateTime() {
        return lastUpdateTime;
    }

    public void setLastUpdateTime(String lastUpdateTime) {
        this.lastUpdateTime = lastUpdateTime;
    }

    @Data
    public static class WarehouseInventory {
        private String warehouseId;
        private String warehouseName;
        private String status;
        private List<ProductStock> stocks;

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

        public String getStatus() {
            return status;
        }

        public void setStatus(String status) {
            this.status = status;
        }

        public List<ProductStock> getStocks() {
            return stocks;
        }

        public void setStocks(List<ProductStock> stocks) {
            this.stocks = stocks;
        }
    }

    @Data
    public static class ProductStock {
        private String productId;
        private String productName;
        private String category;
        private Integer quantity;
        private Integer safeStock;
        private String status;
        private String statusText;

        public String getProductId() {
            return productId;
        }

        public void setProductId(String productId) {
            this.productId = productId;
        }

        public String getProductName() {
            return productName;
        }

        public void setProductName(String productName) {
            this.productName = productName;
        }

        public String getCategory() {
            return category;
        }

        public void setCategory(String category) {
            this.category = category;
        }

        public Integer getQuantity() {
            return quantity;
        }

        public void setQuantity(Integer quantity) {
            this.quantity = quantity;
        }

        public Integer getSafeStock() {
            return safeStock;
        }

        public void setSafeStock(Integer safeStock) {
            this.safeStock = safeStock;
        }

        public String getStatus() {
            return status;
        }

        public void setStatus(String status) {
            this.status = status;
        }

        public String getStatusText() {
            return statusText;
        }

        public void setStatusText(String statusText) {
            this.statusText = statusText;
        }
    }

    @Data
    public static class ProductInventory {
        private String productId;
        private String productName;
        private String category;
        private String categoryText;
        private Integer totalQuantity;
        private Integer safeStock;
        private String status;

        public String getProductId() {
            return productId;
        }

        public void setProductId(String productId) {
            this.productId = productId;
        }

        public String getProductName() {
            return productName;
        }

        public void setProductName(String productName) {
            this.productName = productName;
        }

        public String getCategory() {
            return category;
        }

        public void setCategory(String category) {
            this.category = category;
        }

        public String getCategoryText() {
            return categoryText;
        }

        public void setCategoryText(String categoryText) {
            this.categoryText = categoryText;
        }

        public Integer getTotalQuantity() {
            return totalQuantity;
        }

        public void setTotalQuantity(Integer totalQuantity) {
            this.totalQuantity = totalQuantity;
        }

        public Integer getSafeStock() {
            return safeStock;
        }

        public void setSafeStock(Integer safeStock) {
            this.safeStock = safeStock;
        }

        public String getStatus() {
            return status;
        }

        public void setStatus(String status) {
            this.status = status;
        }
    }
}
