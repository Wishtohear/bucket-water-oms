package com.bucketwater.oms.module.audit.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("audit_log")
public class AuditLog {

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("user_id")
    private Long userId;

    @TableField("username")
    private String username;

    @TableField("user_role")
    private String userRole;

    @TableField("action")
    private String action;

    @TableField("module")
    private String module;

    @TableField("entity_type")
    private String entityType;

    @TableField("entity_id")
    private String entityId;

    @TableField("entity_name")
    private String entityName;

    @TableField("method")
    private String method;

    @TableField("request_url")
    private String requestUrl;

    @TableField("request_method")
    private String requestMethod;

    @TableField("ip_address")
    private String ipAddress;

    @TableField("user_agent")
    private String userAgent;

    @TableField("request_params")
    private String requestParams;

    @TableField("response_status")
    private Integer responseStatus;

    @TableField("error_message")
    private String errorMessage;

    @TableField(value = "create_time", fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField("deleted")
    @TableLogic
    private Integer deleted;
}
