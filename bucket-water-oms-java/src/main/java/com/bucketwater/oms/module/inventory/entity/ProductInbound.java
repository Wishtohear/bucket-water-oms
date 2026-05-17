package com.bucketwater.oms.module.inventory.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("product_inbound")
public class ProductInbound {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private String inboundNo;
    
    private Long warehouseId;
    
    private Long productId;
    
    private String type;
    
    private Integer quantity;
    
    private String status;
    
    private String source;
    
    private String remark;
    
    private String creator;
    
    private LocalDateTime createTime;
    
    private String confirmer;
    
    private LocalDateTime confirmTime;
    
    private LocalDateTime updateTime;
}
