package com.bucketwater.oms.module.bucket.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

/**
 * 确认空桶入库请求
 */
@Schema(description = "确认空桶入库请求")
public class ConfirmBucketInboundRequest {

    @Schema(description = "实际核验数量")
    @NotNull(message = "实际核验数量不能为空")
    @Min(value = 0, message = "实际核验数量不能为负数")
    private Integer actualQuantity;

    @Schema(description = "核验人")
    private String checker;

    @Schema(description = "备注")
    private String remark;

    public ConfirmBucketInboundRequest() {}

    public Integer getActualQuantity() { return actualQuantity; }
    public void setActualQuantity(Integer actualQuantity) { this.actualQuantity = actualQuantity; }

    public String getChecker() { return checker; }
    public void setChecker(String checker) { this.checker = checker; }

    public String getRemark() { return remark; }
    public void setRemark(String remark) { this.remark = remark; }
}
