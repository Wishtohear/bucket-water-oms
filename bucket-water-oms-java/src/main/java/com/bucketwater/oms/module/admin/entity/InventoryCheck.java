package com.bucketwater.oms.module.admin.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
@TableName("inventory_check")
public class InventoryCheck {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long warehouseId;
    
    private String warehouseName;
    
    private LocalDateTime checkDate;
    
    private String checker;
    
    private String status;
    
    private String summary;
    
    private Integer totalProducts;
    
    private Integer matchedProducts;
    
    private Integer discrepancyProducts;
    
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
    
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
    
    private String createBy;
    
    private String updateBy;
    
    @TableLogic
    private Integer deleted;
    
    @TableField(exist = false)
    private List<InventoryCheckItem> items;
}
