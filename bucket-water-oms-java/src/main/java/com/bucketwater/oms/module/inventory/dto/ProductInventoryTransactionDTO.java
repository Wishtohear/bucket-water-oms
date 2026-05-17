package com.bucketwater.oms.module.inventory.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Schema(description = "产品库存变动DTO")
public class ProductInventoryTransactionDTO {

    @Schema(description = "ID")
    private Long id;

    @Schema(description = "流水单号")
    private String transactionNo;

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

    @Schema(description = "变动类型: INBOUND-入库, OUTBOUND-出库")
    private String transactionType;

    @Schema(description = "变动类型文本")
    private String transactionTypeText;

    @Schema(description = "明细类型")
    private String detailType;

    @Schema(description = "明细类型文本")
    private String detailTypeText;

    @Schema(description = "变动数量")
    private Integer quantity;

    @Schema(description = "单价")
    private BigDecimal unitPrice;

    @Schema(description = "总金额")
    private BigDecimal totalAmount;

    @Schema(description = "变动前库存")
    private Integer balanceBefore;

    @Schema(description = "变动后库存")
    private Integer balanceAfter;

    @Schema(description = "关联订单号")
    private String relatedOrderNo;

    @Schema(description = "关联业务单号")
    private String relatedBusinessNo;

    @Schema(description = "来源/目的地")
    private String source;

    @Schema(description = "目的地")
    private String destination;

    @Schema(description = "备注")
    private String remark;

    @Schema(description = "操作人")
    private String operator;

    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @Schema(description = "更新时间")
    private LocalDateTime updateTime;
}
