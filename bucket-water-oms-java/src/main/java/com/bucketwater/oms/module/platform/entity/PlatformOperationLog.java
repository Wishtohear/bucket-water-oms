package com.bucketwater.oms.module.platform.entity;

import com.baomidou.mybatisplus.annotation.*;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("platform_operation_log")
@Schema(description = "平台操作日志实体")
public class PlatformOperationLog {

    @TableId(type = IdType.ASSIGN_ID)
    @Schema(description = "日志ID")
    private Long id;

    @Schema(description = "操作用户ID")
    private Long userId;

    @Schema(description = "操作用户名称")
    private String userName;

    @Schema(description = "操作用户角色")
    private String userRole;

    @Schema(description = "操作模块")
    private String module;

    @Schema(description = "操作类型: CREATE/UPDATE/DELETE/QUERY/LOGIN/LOGOUT")
    private String action;

    @Schema(description = "操作对象类型")
    private String targetType;

    @Schema(description = "操作对象ID")
    private Long targetId;

    @Schema(description = "操作对象名称")
    private String targetName;

    @Schema(description = "操作描述")
    private String description;

    @Schema(description = "请求方法")
    private String requestMethod;

    @Schema(description = "请求URL")
    private String requestUrl;

    @Schema(description = "请求参数")
    private String requestParams;

    @Schema(description = "响应状态")
    private String responseStatus;

    @Schema(description = "错误信息")
    private String errorMessage;

    @Schema(description = "IP地址")
    private String ipAddress;

    @Schema(description = "用户代理")
    private String userAgent;

    @Schema(description = "执行时长(毫秒)")
    private Long duration;

    @TableField(fill = FieldFill.INSERT)
    @Schema(description = "创建时间")
    private LocalDateTime createTime;
}
