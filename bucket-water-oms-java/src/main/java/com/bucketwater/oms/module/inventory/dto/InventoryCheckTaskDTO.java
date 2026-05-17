package com.bucketwater.oms.module.inventory.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Schema(description = "库存盘点任务DTO")
public class InventoryCheckTaskDTO {

    @Schema(description = "ID")
    private Long id;

    @Schema(description = "任务单号")
    private String taskNo;

    @Schema(description = "仓库ID")
    private Long warehouseId;

    @Schema(description = "仓库名称")
    private String warehouseName;

    @Schema(description = "状态: in_progress-盘点中, completed-已完成, cancelled-已取消")
    private String status;

    @Schema(description = "状态文本")
    private String statusText;

    @Schema(description = "总产品数")
    private Integer totalProducts;

    @Schema(description = "已盘点产品数")
    private Integer checkedProducts;

    @Schema(description = "盘盈产品数")
    private Integer surplusCount;

    @Schema(description = "盘亏产品数")
    private Integer lossCount;

    @Schema(description = "无差异产品数")
    private Integer matchedCount;

    @Schema(description = "盘点总结")
    private String summary;

    @Schema(description = "创建人")
    private String creator;

    @Schema(description = "确认人")
    private String checker;

    @Schema(description = "开始时间")
    private LocalDateTime startTime;

    @Schema(description = "结束时间")
    private LocalDateTime endTime;

    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @Schema(description = "盘点明细")
    private List<InventoryCheckTaskItemDTO> items;
}
