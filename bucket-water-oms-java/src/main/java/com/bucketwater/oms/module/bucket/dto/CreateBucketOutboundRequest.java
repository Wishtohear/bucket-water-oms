package com.bucketwater.oms.module.bucket.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

/**
 * 创建空桶出库请求
 */
@Schema(description = "创建空桶出库请求")
public class CreateBucketOutboundRequest {

    @Schema(description = "仓库ID")
    @NotNull(message = "仓库ID不能为空")
    private Long warehouseId;

    @Schema(description = "司机ID")
    private Long driverId;

    @Schema(description = "出库类型: driver_pickup(司机领用)/transfer_out(调拨出库)/damage(损耗出库)")
    @NotBlank(message = "出库类型不能为空")
    private String type;

    @Schema(description = "桶类型")
    private String bucketType = "18.9L标准桶";

    @Schema(description = "出库数量")
    @NotNull(message = "出库数量不能为空")
    @Min(value = 1, message = "出库数量必须大于0")
    private Integer quantity;

    @Schema(description = "去向描述")
    private String destination;

    @Schema(description = "备注")
    private String remark;

    @Schema(description = "创建人")
    private String creator;

    public CreateBucketOutboundRequest() {}

    public Long getWarehouseId() { return warehouseId; }
    public void setWarehouseId(Long warehouseId) { this.warehouseId = warehouseId; }

    public Long getDriverId() { return driverId; }
    public void setDriverId(Long driverId) { this.driverId = driverId; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getBucketType() { return bucketType; }
    public void setBucketType(String bucketType) { this.bucketType = bucketType; }

    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }

    public String getDestination() { return destination; }
    public void setDestination(String destination) { this.destination = destination; }

    public String getRemark() { return remark; }
    public void setRemark(String remark) { this.remark = remark; }

    public String getCreator() { return creator; }
    public void setCreator(String creator) { this.creator = creator; }
}
