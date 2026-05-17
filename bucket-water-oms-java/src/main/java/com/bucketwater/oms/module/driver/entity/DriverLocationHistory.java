package com.bucketwater.oms.module.driver.entity;

import com.baomidou.mybatisplus.annotation.*;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("driver_location_history")
@Schema(description = "司机位置历史记录实体")
public class DriverLocationHistory {

    @TableId(type = IdType.AUTO)
    @Schema(description = "主键ID")
    private Long id;

    @TableField("driver_id")
    @Schema(description = "司机ID")
    private Long driverId;

    @Schema(description = "纬度")
    private BigDecimal lat;

    @Schema(description = "经度")
    private BigDecimal lng;

    @Schema(description = "速度(km/h)")
    private BigDecimal speed;

    @Schema(description = "方向角度")
    private Integer heading;

    @Schema(description = "当前位置地址")
    private String address;

    @Schema(description = "记录时间")
    private LocalDateTime recordTime;

    @Schema(description = "关联订单ID(可选)")
    private String orderId;

    @Schema(description = "位置类型: location_check_in/delivery/normal")
    private String locationType;

    @TableField(fill = FieldFill.INSERT)
    @Schema(description = "创建时间")
    private LocalDateTime createTime;
}
