package com.bucketwater.oms.module.inventory.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("inventory_check_task_item")
public class InventoryCheckTaskItem {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long taskId;

    private Long productId;

    private String productName;

    private String productCategory;

    private Integer systemQuantity;

    private Integer actualQuantity;

    private Integer discrepancy;

    private String discrepancyType;

    private String remark;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}
