package com.bucketwater.oms.module.station.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.util.List;

@Schema(description = "库存响应")
public class InventoryDTO {

    @Schema(description = "仓库列表")
    private List<WarehouseInventory> warehouses;

    public InventoryDTO() {}

    public InventoryDTO(List<WarehouseInventory> warehouses) {
        this.warehouses = warehouses;
    }

    public List<WarehouseInventory> getWarehouses() { return warehouses; }
    public void setWarehouses(List<WarehouseInventory> warehouses) { this.warehouses = warehouses; }

    @Schema(description = "仓库库存")
    public static class WarehouseInventory {

        @Schema(description = "仓库ID")
        private String warehouseId;

        @Schema(description = "仓库名称")
        private String warehouseName;

        @Schema(description = "距离(公里)")
        private BigDecimal distanceKm;

        @Schema(description = "商品列表")
        private List<ProductInventory> products;

        public WarehouseInventory() {}

        public WarehouseInventory(String warehouseId, String warehouseName, BigDecimal distanceKm, List<ProductInventory> products) {
            this.warehouseId = warehouseId;
            this.warehouseName = warehouseName;
            this.distanceKm = distanceKm;
            this.products = products;
        }

        public String getWarehouseId() { return warehouseId; }
        public void setWarehouseId(String warehouseId) { this.warehouseId = warehouseId; }
        public String getWarehouseName() { return warehouseName; }
        public void setWarehouseName(String warehouseName) { this.warehouseName = warehouseName; }
        public BigDecimal getDistanceKm() { return distanceKm; }
        public void setDistanceKm(BigDecimal distanceKm) { this.distanceKm = distanceKm; }
        public List<ProductInventory> getProducts() { return products; }
        public void setProducts(List<ProductInventory> products) { this.products = products; }
    }

    @Schema(description = "商品库存")
    public static class ProductInventory {

        @Schema(description = "商品ID")
        private String productId;

        @Schema(description = "商品名称")
        private String productName;

        @Schema(description = "可用数量")
        private Integer availableQty;

        @Schema(description = "单价")
        private BigDecimal unitPrice;

        public ProductInventory() {}

        public ProductInventory(String productId, String productName, Integer availableQty, BigDecimal unitPrice) {
            this.productId = productId;
            this.productName = productName;
            this.availableQty = availableQty;
            this.unitPrice = unitPrice;
        }

        public String getProductId() { return productId; }
        public void setProductId(String productId) { this.productId = productId; }
        public String getProductName() { return productName; }
        public void setProductName(String productName) { this.productName = productName; }
        public Integer getAvailableQty() { return availableQty; }
        public void setAvailableQty(Integer availableQty) { this.availableQty = availableQty; }
        public BigDecimal getUnitPrice() { return unitPrice; }
        public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }
    }
}
