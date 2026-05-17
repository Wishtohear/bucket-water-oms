package com.bucketwater.oms.module.bucket.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;

/**
 * 空桶出库 DTO
 */
@Schema(description = "空桶出库响应DTO")
public class BucketOutboundDTO {

    @Schema(description = "主键ID")
    private Long id;

    @Schema(description = "出库单号")
    private String outboundNo;

    @Schema(description = "仓库ID")
    private Long warehouseId;

    @Schema(description = "仓库名称")
    private String warehouseName;

    @Schema(description = "司机ID")
    private Long driverId;

    @Schema(description = "司机名称")
    private String driverName;

    @Schema(description = "司机电话")
    private String driverPhone;

    @Schema(description = "出库类型: driver_pickup(司机领用)/transfer_out(调拨出库)/damage(损耗出库)")
    private String type;

    @Schema(description = "类型文本")
    private String typeText;

    @Schema(description = "桶类型")
    private String bucketType;

    @Schema(description = "出库数量")
    private Integer quantity;

    @Schema(description = "状态: pending(待出库)/confirmed(已出库)/rejected(已拒绝)")
    private String status;

    @Schema(description = "状态文本")
    private String statusText;

    @Schema(description = "去向描述")
    private String destination;

    @Schema(description = "备注")
    private String remark;

    @Schema(description = "创建人")
    private String creator;

    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @Schema(description = "确认人")
    private String confirmer;

    @Schema(description = "确认时间")
    private LocalDateTime confirmTime;

    public BucketOutboundDTO() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getOutboundNo() { return outboundNo; }
    public void setOutboundNo(String outboundNo) { this.outboundNo = outboundNo; }

    public Long getWarehouseId() { return warehouseId; }
    public void setWarehouseId(Long warehouseId) { this.warehouseId = warehouseId; }

    public String getWarehouseName() { return warehouseName; }
    public void setWarehouseName(String warehouseName) { this.warehouseName = warehouseName; }

    public Long getDriverId() { return driverId; }
    public void setDriverId(Long driverId) { this.driverId = driverId; }

    public String getDriverName() { return driverName; }
    public void setDriverName(String driverName) { this.driverName = driverName; }

    public String getDriverPhone() { return driverPhone; }
    public void setDriverPhone(String driverPhone) { this.driverPhone = driverPhone; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getTypeText() { return typeText; }
    public void setTypeText(String typeText) { this.typeText = typeText; }

    public String getBucketType() { return bucketType; }
    public void setBucketType(String bucketType) { this.bucketType = bucketType; }

    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getStatusText() { return statusText; }
    public void setStatusText(String statusText) { this.statusText = statusText; }

    public String getDestination() { return destination; }
    public void setDestination(String destination) { this.destination = destination; }

    public String getRemark() { return remark; }
    public void setRemark(String remark) { this.remark = remark; }

    public String getCreator() { return creator; }
    public void setCreator(String creator) { this.creator = creator; }

    public LocalDateTime getCreateTime() { return createTime; }
    public void setCreateTime(LocalDateTime createTime) { this.createTime = createTime; }

    public String getConfirmer() { return confirmer; }
    public void setConfirmer(String confirmer) { this.confirmer = confirmer; }

    public LocalDateTime getConfirmTime() { return confirmTime; }
    public void setConfirmTime(LocalDateTime confirmTime) { this.confirmTime = confirmTime; }
}
