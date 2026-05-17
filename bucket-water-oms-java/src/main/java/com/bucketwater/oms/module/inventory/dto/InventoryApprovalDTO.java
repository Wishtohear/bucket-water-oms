package com.bucketwater.oms.module.inventory.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Schema(description = "库存调整审批DTO")
public class InventoryApprovalDTO {

    @Schema(description = "审批ID")
    private Long id;

    @Schema(description = "审批单号")
    private String approvalNo;

    @Schema(description = "仓库ID")
    private Long warehouseId;

    @Schema(description = "仓库名称")
    private String warehouseName;

    @Schema(description = "调整类型: add/reduce/set")
    private String adjustmentType;

    @Schema(description = "调整原因")
    private String reason;

    @Schema(description = "审批状态: pending/approved/rejected")
    private String status;

    @Schema(description = "申请人")
    private String applicant;

    @Schema(description = "申请时间")
    private LocalDateTime applyTime;

    @Schema(description = "审批人")
    private String approver;

    @Schema(description = "审批时间")
    private LocalDateTime approveTime;

    @Schema(description = "审批备注")
    private String approveRemark;

    @Schema(description = "调整明细")
    private List<AdjustmentItemDTO> items;

    @Data
    @Schema(description = "调整明细DTO")
    public static class AdjustmentItemDTO {
        @Schema(description = "商品ID")
        private Long productId;

        @Schema(description = "商品名称")
        private String productName;

        @Schema(description = "商品分类")
        private String category;

        @Schema(description = "调整数量")
        private Integer quantity;

        @Schema(description = "备注")
        private String remark;
    }
}
