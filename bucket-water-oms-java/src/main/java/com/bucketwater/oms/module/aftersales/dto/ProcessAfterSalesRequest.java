package com.bucketwater.oms.module.aftersales.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
@Schema(description = "处理售后请求")
public class ProcessAfterSalesRequest {

    @NotBlank(message = "操作不能为空")
    @Schema(description = "操作: approve/reject")
    private String action;

    @Schema(description = "拒绝原因")
    private String reason;

    @Schema(description = "新订单ID（同意售后时生成）")
    private String newOrderId;

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

    public String getNewOrderId() {
        return newOrderId;
    }

    public void setNewOrderId(String newOrderId) {
        this.newOrderId = newOrderId;
    }
}
