package com.bucketwater.oms.module.order.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;

@Schema(description = "派单请求")
public class DispatchOrderRequest {

    @NotNull(message = "司机ID不能为空")
    @Schema(description = "司机ID")
    private Long driverId;

    public Long getDriverId() {
        return driverId;
    }

    public void setDriverId(Long driverId) {
        this.driverId = driverId;
    }
}
