package com.bucketwater.oms.module.audit.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class AuditLogDTO {
    private Long id;
    private Long userId;
    private String username;
    private String userRole;
    private String action;
    private String module;
    private String entityType;
    private String entityId;
    private String entityName;
    private String method;
    private String requestUrl;
    private String requestMethod;
    private String ipAddress;
    private String requestParams;
    private Integer responseStatus;
    private String errorMessage;
    private LocalDateTime createTime;
}
