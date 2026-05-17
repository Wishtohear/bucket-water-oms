package com.bucketwater.oms.module.warehouse.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

@Data
@Schema(description = "库存校准请求")
public class WarehouseCalibrateRequest {

    @Schema(description = "校准后的库存数量")
    private Integer quantity;

    @Schema(description = "校准原因")
    private String reason;
}
