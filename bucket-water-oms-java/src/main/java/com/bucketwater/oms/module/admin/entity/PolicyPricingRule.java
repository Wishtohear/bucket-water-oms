package com.bucketwater.oms.module.admin.entity;

import com.baomidou.mybatisplus.annotation.*;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("policy_pricing_rule")
@Schema(description = "政策定价规则实体")
public class PolicyPricingRule {

    @TableId(type = IdType.AUTO)
    @Schema(description = "定价规则ID")
    private Long id;

    @Schema(description = "政策模板ID")
    private Long policyId;

    @Schema(description = "产品ID")
    private Long productId;

    @Schema(description = "产品名称")
    private String productName;

    @Schema(description = "产品分类")
    private String category;

    @Schema(description = "单价")
    private BigDecimal price;

    @Schema(description = "最低起订量")
    private Integer minQuantity;

    @TableField(fill = FieldFill.INSERT)
    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    @Schema(description = "更新时间")
    private LocalDateTime updateTime;

    @TableLogic
    @Schema(description = "删除标记: 0-未删除, 1-已删除")
    private Integer deleted;
}
