package com.bucketwater.oms.module.platform.entity;

import com.baomidou.mybatisplus.annotation.*;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("platform_config")
@Schema(description = "平台配置实体")
public class PlatformConfig {

    @TableId(type = IdType.ASSIGN_ID)
    @Schema(description = "配置ID")
    private Long id;

    @Schema(description = "配置分组")
    private String configGroup;

    @Schema(description = "配置键")
    private String configKey;

    @Schema(description = "配置值")
    private String configValue;

    @Schema(description = "配置类型: STRING/INT/BOOLEAN/JSON")
    private String configType;

    @Schema(description = "配置名称")
    private String configName;

    @Schema(description = "配置描述")
    private String description;

    @Schema(description = "是否启用: 0-禁用, 1-启用")
    private Integer enabled;

    @Schema(description = "排序")
    private Integer sortOrder;

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
}
