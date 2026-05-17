package com.bucketwater.oms.module.driver.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.util.List;

@Schema(description = "中途回仓请求")
public class WarehouseReturnRequest {

    @NotBlank(message = "仓库ID不能为空")
    @Schema(description = "仓库ID")
    private String warehouseId;

    @NotNull(message = "回桶数量不能为空")
    @Schema(description = "回桶数量")
    private Integer bucketReturn;

    @Schema(description = "补货申请")
    private List<ReplenishmentItem> replenishment;

    @Schema(description = "位置信息")
    private LocationInfo location;

    @Schema(description = "是否为新水站派送（当回桶数量为0时使用）")
    private Boolean isNewStationDelivery;

    @Schema(description = "新水站派送明细列表（当回桶数量为0时使用，可选择多个水站）")
    private List<StationDeliveryItem> stationDeliveries;

    public String getWarehouseId() {
        return warehouseId;
    }

    public void setWarehouseId(String warehouseId) {
        this.warehouseId = warehouseId;
    }

    public Integer getBucketReturn() {
        return bucketReturn;
    }

    public void setBucketReturn(Integer bucketReturn) {
        this.bucketReturn = bucketReturn;
    }

    public List<ReplenishmentItem> getReplenishment() {
        return replenishment;
    }

    public void setReplenishment(List<ReplenishmentItem> replenishment) {
        this.replenishment = replenishment;
    }

    public LocationInfo getLocation() {
        return location;
    }

    public void setLocation(LocationInfo location) {
        this.location = location;
    }

    public Boolean getIsNewStationDelivery() {
        return isNewStationDelivery;
    }

    public void setIsNewStationDelivery(Boolean isNewStationDelivery) {
        this.isNewStationDelivery = isNewStationDelivery;
    }

    public List<StationDeliveryItem> getStationDeliveries() {
        return stationDeliveries;
    }

    public void setStationDeliveries(List<StationDeliveryItem> stationDeliveries) {
        this.stationDeliveries = stationDeliveries;
    }

    @Schema(description = "补货项")
    public static class ReplenishmentItem {

        @Schema(description = "商品ID")
        private String productId;

        @Schema(description = "数量")
        private Integer quantity;

        public String getProductId() {
            return productId;
        }

        public void setProductId(String productId) {
            this.productId = productId;
        }

        public Integer getQuantity() {
            return quantity;
        }

        public void setQuantity(Integer quantity) {
            this.quantity = quantity;
        }
    }

    @Schema(description = "位置信息")
    public static class LocationInfo {

        @Schema(description = "纬度")
        private Double lat;

        @Schema(description = "经度")
        private Double lng;

        public Double getLat() {
            return lat;
        }

        public void setLat(Double lat) {
            this.lat = lat;
        }

        public Double getLng() {
            return lng;
        }

        public void setLng(Double lng) {
            this.lng = lng;
        }
    }

    @Schema(description = "新水站派送项")
    public static class StationDeliveryItem {

        @NotBlank(message = "水站ID不能为空")
        @Schema(description = "水站ID")
        private String stationId;

        @NotNull(message = "派送桶数不能为空")
        @Schema(description = "派送桶数")
        private Integer bucketCount;

        public String getStationId() {
            return stationId;
        }

        public void setStationId(String stationId) {
            this.stationId = stationId;
        }

        public Integer getBucketCount() {
            return bucketCount;
        }

        public void setBucketCount(Integer bucketCount) {
            this.bucketCount = bucketCount;
        }
    }
}
