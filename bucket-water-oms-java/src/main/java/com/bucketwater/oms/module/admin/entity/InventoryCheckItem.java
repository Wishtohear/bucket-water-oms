package com.bucketwater.oms.module.admin.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("inventory_check_item")
public class InventoryCheckItem {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long checkId;
    
    private Long productId;
    
    private String productName;
    
    private String category;
    
    private Integer systemQuantity;
    
    private Integer actualQuantity;
    
    private Integer discrepancy;
    
    private String remark;
    
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
    
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
    
    @TableLogic
    private Integer deleted;
}
