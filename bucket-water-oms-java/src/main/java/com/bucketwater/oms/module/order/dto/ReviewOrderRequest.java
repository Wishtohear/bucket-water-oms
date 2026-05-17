package com.bucketwater.oms.module.order.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

@Schema(description = "订单审查请求")
public class ReviewOrderRequest {

    @NotBlank(message = "操作不能为空")
    @Schema(description = "操作: accept/reject")
    private String action;

    @Schema(description = "拒单原因")
    private String reason;

    @Schema(description = "拒单类型")
    private String rejectType;

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public String getRejectType() {
        return rejectType;
    }

    public void setRejectType(String rejectType) {
        this.rejectType = rejectType;
    }
}
