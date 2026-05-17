package com.bucketwater.oms.module.driver.entity;

import com.baomidou.mybatisplus.annotation.*;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("driver_warehouse")
@Schema(description = "司机仓库关联实体")
public class DriverWarehouse {

    @TableId(type = IdType.AUTO)
    @Schema(description = "主键ID")
    private Long id;

    @TableField("driver_id")
    @Schema(description = "司机ID")
    private Long driverId;

    @TableField("warehouse_id")
    @Schema(description = "仓库ID")
    private Long warehouseId;

    @TableField("is_primary")
    @Schema(description = "是否主仓库")
    private Boolean isPrimary;

    @Schema(description = "状态: active-生效, inactive-失效")
    private String status;

    @TableField("create_time")
    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @TableField("update_time")
    @Schema(description = "更新时间")
    private LocalDateTime updateTime;

    @TableField("create_by")
    @Schema(description = "创建人")
    private String createBy;

    @TableField("update_by")
    @Schema(description = "更新人")
    private String updateBy;

    @TableLogic
    @TableField(select = false)
    @Schema(description = "逻辑删除标记")
    private Integer deleted;
}
