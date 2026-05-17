package com.bucketwater.oms.module.inventory.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("inventory_check_task")
public class InventoryCheckTask {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String taskNo;

    private Long warehouseId;

    private String warehouseName;

    private String status;

    private Integer totalProducts;

    private Integer checkedProducts;

    private Integer surplusCount;

    private Integer lossCount;

    private Integer matchedCount;

    private String summary;

    private String creator;

    private String checker;

    private LocalDateTime startTime;

    private LocalDateTime endTime;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}
