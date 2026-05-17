package com.bucketwater.oms.module.driver.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;

@TableName("driver_return")
@Schema(description = "司机回仓实体")
public class DriverReturn {

    @TableId(type = IdType.AUTO)
    @Schema(description = "主键ID")
    private Long id;

    @TableField("driver_id")
    @Schema(description = "司机ID")
    private Long driverId;

    @TableField("warehouse_id")
    @Schema(description = "仓库ID")
    private Long warehouseId;

    @Schema(description = "状态: pending/checked")
    private String status;

    @Schema(description = "司机上报交回数量")
    private Integer bucketReturned;

    @Schema(description = "仓库实收数量")
    private Integer actualBucketQty;

    @Schema(description = "差异数量")
    private Integer difference;

    @Schema(description = "差异原因")
    private String differenceReason;

    @Schema(description = "补货申请(JSON)")
    private String replenishment;

    @Schema(description = "是否为新水站派送")
    private Boolean isNewStationDelivery;

    @Schema(description = "新水站派送明细(JSON)，格式：[{\"stationId\": 1, \"bucketCount\": 10}]")
    private String stationDeliveries;

    @Schema(description = "创建时间")
    private LocalDateTime createdAt;

    @Schema(description = "核对时间")
    private LocalDateTime checkedAt;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getDriverId() {
        return driverId;
    }

    public void setDriverId(Long driverId) {
        this.driverId = driverId;
    }

    public Long getWarehouseId() {
        return warehouseId;
    }

    public void setWarehouseId(Long warehouseId) {
        this.warehouseId = warehouseId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getBucketReturned() {
        return bucketReturned;
    }

    public void setBucketReturned(Integer bucketReturned) {
        this.bucketReturned = bucketReturned;
    }

    public Integer getActualBucketQty() {
        return actualBucketQty;
    }

    public void setActualBucketQty(Integer actualBucketQty) {
        this.actualBucketQty = actualBucketQty;
    }

    public Integer getDifference() {
        return difference;
    }

    public void setDifference(Integer difference) {
        this.difference = difference;
    }

    public String getDifferenceReason() {
        return differenceReason;
    }

    public void setDifferenceReason(String differenceReason) {
        this.differenceReason = differenceReason;
    }

    public String getReplenishment() {
        return replenishment;
    }

    public void setReplenishment(String replenishment) {
        this.replenishment = replenishment;
    }

    public Boolean getIsNewStationDelivery() {
        return isNewStationDelivery;
    }

    public void setIsNewStationDelivery(Boolean isNewStationDelivery) {
        this.isNewStationDelivery = isNewStationDelivery;
    }

    public String getStationDeliveries() {
        return stationDeliveries;
    }

    public void setStationDeliveries(String stationDeliveries) {
        this.stationDeliveries = stationDeliveries;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getCheckedAt() {
        return checkedAt;
    }

    public void setCheckedAt(LocalDateTime checkedAt) {
        this.checkedAt = checkedAt;
    }
}
