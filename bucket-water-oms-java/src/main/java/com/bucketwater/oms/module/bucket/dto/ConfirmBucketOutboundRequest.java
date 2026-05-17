package com.bucketwater.oms.module.bucket.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

/**
 * 确认空桶出库请求
 */
@Schema(description = "确认空桶出库请求")
public class ConfirmBucketOutboundRequest {

    @Schema(description = "确认人")
    private String confirmer;

    @Schema(description = "备注")
    private String remark;

    public ConfirmBucketOutboundRequest() {}

    public String getConfirmer() { return confirmer; }
    public void setConfirmer(String confirmer) { this.confirmer = confirmer; }

    public String getRemark() { return remark; }
    public void setRemark(String remark) { this.remark = remark; }
}
