package com.bucketwater.oms.module.factory.entity;

import com.baomidou.mybatisplus.annotation.*;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("factory")
@Schema(description = "水厂实体")
public class Factory {

    @TableId(type = IdType.ASSIGN_ID)
    @Schema(description = "水厂ID")
    private Long id;

    @Schema(description = "水厂名称")
    private String name;

    @Schema(description = "水厂编码")
    private String code;

    @Schema(description = "联系人")
    private String contact;

    @Schema(description = "联系电话")
    private String phone;

    @Schema(description = "地址")
    private String address;

    @Schema(description = "纬度")
    private BigDecimal lat;

    @Schema(description = "经度")
    private BigDecimal lng;

    @Schema(description = "状态: active/inactive")
    private String status;

    @Schema(description = "备注")
    private String remark;

    @TableField(fill = FieldFill.INSERT)
    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    @Schema(description = "更新时间")
    private LocalDateTime updateTime;

    @TableField(fill = FieldFill.INSERT)
    @Schema(description = "创建人")
    private String createBy;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    @Schema(description = "更新人")
    private String updateBy;

    @TableLogic
    @Schema(description = "删除标记: 0-未删除, 1-已删除")
    private Integer deleted;
}
