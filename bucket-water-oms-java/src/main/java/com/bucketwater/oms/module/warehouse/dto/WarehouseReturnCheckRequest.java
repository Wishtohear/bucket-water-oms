package com.bucketwater.oms.module.warehouse.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;

@Schema(description = "回仓核对请求")
public class WarehouseReturnCheckRequest {

    @NotNull(message = "实收数量不能为空")
    @Schema(description = "实收桶数")
    private Integer actualBucketQty;

    @Schema(description = "差异数量")
    private Integer differenceQty;

    @Schema(description = "差异原因")
    private String differenceReason;

    @Schema(description = "核对人")
    private String checkedBy;

    public Integer getActualBucketQty() { return actualBucketQty; }
    public void setActualBucketQty(Integer actualBucketQty) { this.actualBucketQty = actualBucketQty; }
    public Integer getDifferenceQty() { return differenceQty; }
    public void setDifferenceQty(Integer differenceQty) { this.differenceQty = differenceQty; }
    public String getDifferenceReason() { return differenceReason; }
    public void setDifferenceReason(String differenceReason) { this.differenceReason = differenceReason; }
    public String getCheckedBy() { return checkedBy; }
    public void setCheckedBy(String checkedBy) { this.checkedBy = checkedBy; }
}
