package com.bucketwater.oms.module.bucket.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;

/**
 * 空桶入库 DTO
 */
@Schema(description = "空桶入库响应DTO")
public class BucketInboundDTO {

    @Schema(description = "主键ID")
    private Long id;

    @Schema(description = "入库单号")
    private String inboundNo;

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

    @Schema(description = "入库类型: driver_return(司机回桶)/clean(清洗入库)/transfer_in(调拨入库)")
    private String type;

    @Schema(description = "类型文本")
    private String typeText;

    @Schema(description = "桶类型")
    private String bucketType;

    @Schema(description = "入库数量")
    private Integer quantity;

    @Schema(description = "状态: pending(待核验)/confirmed(已入库)/rejected(已拒绝)")
    private String status;

    @Schema(description = "状态文本")
    private String statusText;

    @Schema(description = "来源描述")
    private String source;

    @Schema(description = "备注")
    private String remark;

    @Schema(description = "创建人")
    private String creator;

    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @Schema(description = "核验人")
    private String checker;

    @Schema(description = "核验时间")
    private LocalDateTime checkTime;

    public BucketInboundDTO() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getInboundNo() { return inboundNo; }
    public void setInboundNo(String inboundNo) { this.inboundNo = inboundNo; }

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

    public String getSource() { return source; }
    public void setSource(String source) { this.source = source; }

    public String getRemark() { return remark; }
    public void setRemark(String remark) { this.remark = remark; }

    public String getCreator() { return creator; }
    public void setCreator(String creator) { this.creator = creator; }

    public LocalDateTime getCreateTime() { return createTime; }
    public void setCreateTime(LocalDateTime createTime) { this.createTime = createTime; }

    public String getChecker() { return checker; }
    public void setChecker(String checker) { this.checker = checker; }

    public LocalDateTime getCheckTime() { return checkTime; }
    public void setCheckTime(LocalDateTime checkTime) { this.checkTime = checkTime; }
}
