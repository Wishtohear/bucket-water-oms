package com.bucketwater.oms.module.inventory.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Schema(description = "产品库存盘点DTO")
public class ProductInventoryCheckDTO {

    @Schema(description = "ID")
    private Long id;

    @Schema(description = "盘点单号")
    private String checkNo;

    @Schema(description = "仓库ID")
    private Long warehouseId;

    @Schema(description = "仓库名称")
    private String warehouseName;

    @Schema(description = "产品ID")
    private Long productId;

    @Schema(description = "产品名称")
    private String productName;

    @Schema(description = "产品分类")
    private String productCategory;

    @Schema(description = "系统库存")
    private Integer systemQuantity;

    @Schema(description = "实际库存")
    private Integer actualQuantity;

    @Schema(description = "差异数量")
    private Integer discrepancy;

    @Schema(description = "差异类型: surplus-盘盈, loss-盘亏, matched-无差异")
    private String discrepancyType;

    @Schema(description = "差异类型文本")
    private String discrepancyTypeText;

    @Schema(description = "状态: pending-待确认, confirmed-已确认")
    private String status;

    @Schema(description = "状态文本")
    private String statusText;

    @Schema(description = "盘点人")
    private String checker;

    @Schema(description = "盘点时间")
    private LocalDateTime checkTime;

    @Schema(description = "备注")
    private String remark;

    @Schema(description = "创建时间")
    private LocalDateTime createTime;
}
