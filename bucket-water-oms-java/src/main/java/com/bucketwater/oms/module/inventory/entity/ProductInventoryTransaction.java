package com.bucketwater.oms.module.inventory.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("product_inventory_transaction")
public class ProductInventoryTransaction {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String transactionNo;

    private Long warehouseId;

    private String warehouseName;

    private Long productId;

    private String productName;

    private String productCategory;

    private String transactionType;

    private String detailType;

    private Integer quantity;

    private BigDecimal unitPrice;

    private BigDecimal totalAmount;

    private Integer balanceBefore;

    private Integer balanceAfter;

    private String relatedOrderNo;

    private String relatedBusinessNo;

    private String source;

    private String destination;

    private String remark;

    private String operator;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}
