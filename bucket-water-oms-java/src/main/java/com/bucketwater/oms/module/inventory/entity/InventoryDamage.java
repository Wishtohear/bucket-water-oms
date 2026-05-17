package com.bucketwater.oms.module.inventory.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("inventory_damage")
public class InventoryDamage {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private String damageNo;
    
    private Long warehouseId;
    
    private Long productId;
    
    private String type;
    
    private Integer quantity;
    
    private String reason;
    
    private String reporter;
    
    private LocalDateTime createTime;
    
    private String handler;
    
    private LocalDateTime handleTime;
    
    private LocalDateTime updateTime;
}
