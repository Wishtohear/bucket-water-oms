package com.bucketwater.oms.module.driver.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

@Schema(description = "司机状态更新请求")
public class DriverStatusUpdateRequest {

    @NotBlank(message = "在线状态不能为空")
    @Schema(description = "在线状态: online/offline/break")
    private String onlineStatus;

    public String getOnlineStatus() {
        return onlineStatus;
    }

    public void setOnlineStatus(String onlineStatus) {
        this.onlineStatus = onlineStatus;
    }
}
