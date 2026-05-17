package com.bucketwater.oms.module.warehouse.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;

@Schema(description = "审核入库请求")
public class CheckInboundRequest {

    @NotNull(message = "审核状态不能为空")
    @Schema(description = "操作: approve/reject")
    private String action;

    @Schema(description = "原因")
    private String reason;

    @NotNull(message = "审核人不能为空")
    @Schema(description = "审核人")
    private String checkedBy;

    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }
    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
    public String getCheckedBy() { return checkedBy; }
    public void setCheckedBy(String checkedBy) { this.checkedBy = checkedBy; }
}
