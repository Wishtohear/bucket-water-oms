package com.bucketwater.oms.module.inventory.entity;

import com.baomidou.mybatisplus.annotation.*;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("inventory_adjustment")
@Schema(description = "库存调整单实体")
public class InventoryAdjustment {

    @TableId(type = IdType.AUTO)
    @Schema(description = "主键ID")
    private Long id;

    @Schema(description = "调整单号")
    private String adjustmentNo;

    @Schema(description = "仓库ID")
    private Long warehouseId;

    @Schema(description = "仓库名称")
    private String warehouseName;

    @Schema(description = "调整类型: add/reduce/set")
    private String adjustmentType;

    @Schema(description = "调整原因")
    private String reason;

    @Schema(description = "申请人")
    private String applicant;

    @Schema(description = "申请时间")
    private LocalDateTime applyTime;

    @Schema(description = "审批状态: pending/approved/rejected")
    private String status;

    @Schema(description = "审批人")
    private String approver;

    @Schema(description = "审批时间")
    private LocalDateTime approveTime;

    @Schema(description = "审批备注")
    private String approveRemark;

    @Schema(description = "删除标记")
    private Integer deleted;

    @TableField(fill = FieldFill.INSERT)
    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    @Schema(description = "更新时间")
    private LocalDateTime updateTime;
}
