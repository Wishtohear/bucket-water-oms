package com.bucketwater.oms.module.admin.entity;

import com.baomidou.mybatisplus.annotation.*;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Data
@TableName("policy_template")
@Schema(description = "政策模板实体")
public class PolicyTemplate {

    @TableId(type = IdType.AUTO)
    @Schema(description = "政策模板ID")
    private Long id;

    @Schema(description = "政策名称")
    private String name;

    @Schema(description = "政策类型: default/vip/promotion")
    private String type;

    @Schema(description = "状态: active/inactive")
    private String status;

    @Schema(description = "政策描述")
    private String remark;

    @Schema(description = "桶装水单价")
    private BigDecimal bucketWaterPrice;

    @Schema(description = "最低起订量")
    private Integer minOrderQuantity;

    @Schema(description = "信用额度")
    private BigDecimal creditLimit;

    @Schema(description = "账期类型: immediate/monthly/quarterly")
    private String paymentType;

    @Schema(description = "预存金要求")
    private BigDecimal preDeposit;

    @Schema(description = "欠桶阈值")
    private Integer bucketThreshold;

    @Schema(description = "覆盖水站数量")
    private Integer coverageCount;

    @Schema(description = "促销开始日期")
    private LocalDate startDate;

    @Schema(description = "促销结束日期")
    private LocalDate endDate;

    @Schema(description = "赠送比例")
    private String giftRatio;

    @TableField(select = false)
    private List<PricingRule> pricingRules;

    @TableField(fill = FieldFill.INSERT)
    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    @Schema(description = "更新时间")
    private LocalDateTime updateTime;

    @Schema(description = "创建人")
    private String createBy;

    @Schema(description = "更新人")
    private String updateBy;

    @TableLogic
    @Schema(description = "删除标记: 0-未删除, 1-已删除")
    private Integer deleted;

    @Data
    public static class PricingRule {
        private String productId;
        private String productName;
        private String category;
        private BigDecimal price;
        private Integer minQuantity;
    }
}
