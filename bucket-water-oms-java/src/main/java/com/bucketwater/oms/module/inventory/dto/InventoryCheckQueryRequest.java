package com.bucketwater.oms.module.inventory.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

@Data
@Schema(description = "库存盘点查询请求")
public class InventoryCheckQueryRequest {

    @Schema(description = "仓库ID")
    private Long warehouseId;

    @Schema(description = "产品ID")
    private Long productId;

    @Schema(description = "状态: pending-待确认, confirmed-已确认, in_progress-盘点中, completed-已完成")
    private String status;

    @Schema(description = "开始日期")
    private String startDate;

    @Schema(description = "结束日期")
    private String endDate;

    @Schema(description = "页码")
    private Integer page = 1;

    @Schema(description = "每页数量")
    private Integer size = 20;
}
