package com.bucketwater.oms.module.bucket.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

/**
 * 创建空桶入库请求
 */
@Schema(description = "创建空桶入库请求")
public class CreateBucketInboundRequest {

    @Schema(description = "仓库ID")
    @NotNull(message = "仓库ID不能为空")
    private Long warehouseId;

    @Schema(description = "司机ID")
    private Long driverId;

    @Schema(description = "入库类型: driver_return(司机回桶)/clean(清洗入库)/transfer_in(调拨入库)")
    @NotBlank(message = "入库类型不能为空")
    private String type;

    @Schema(description = "桶类型")
    private String bucketType = "18.9L标准桶";

    @Schema(description = "入库数量")
    @NotNull(message = "入库数量不能为空")
    @Min(value = 1, message = "入库数量必须大于0")
    private Integer quantity;

    @Schema(description = "来源描述")
    private String source;

    @Schema(description = "备注")
    private String remark;

    @Schema(description = "创建人")
    private String creator;

    public CreateBucketInboundRequest() {}

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

    public String getSource() { return source; }
    public void setSource(String source) { this.source = source; }

    public String getRemark() { return remark; }
    public void setRemark(String remark) { this.remark = remark; }

    public String getCreator() { return creator; }
    public void setCreator(String creator) { this.creator = creator; }
}
