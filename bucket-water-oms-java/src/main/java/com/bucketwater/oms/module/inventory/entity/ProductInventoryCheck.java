package com.bucketwater.oms.module.inventory.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("product_inventory_check")
public class ProductInventoryCheck {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String checkNo;

    private Long warehouseId;

    private String warehouseName;

    private Long productId;

    private String productName;

    private String productCategory;

    private Integer systemQuantity;

    private Integer actualQuantity;

    private Integer discrepancy;

    private String discrepancyType;

    private String status;

    private String checker;

    private LocalDateTime checkTime;

    private String remark;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}
