package com.bucketwater.oms.module.notification.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class NotificationDTO {
    private Long id;
    private Long userId;
    private String type;
    private String title;
    private String content;
    private String relatedId;
    private Boolean isRead;
    private LocalDateTime createdAt;
}
