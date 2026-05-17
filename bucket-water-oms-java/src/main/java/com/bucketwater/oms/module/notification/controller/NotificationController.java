package com.bucketwater.oms.module.notification.controller;

import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.module.notification.entity.Notification;
import com.bucketwater.oms.module.notification.service.NotificationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;


@RestController
@RequestMapping("/notifications")
@Tag(name = "消息通知模块", description = "消息通知获取、已读标记、发送")
public class NotificationController {

    @Autowired
    private NotificationService notificationService;

    @GetMapping("/unread")
    @Operation(summary = "获取未读消息", description = "获取用户未读消息列表")
    public Result<List<Notification>> getUnreadNotifications(
            @RequestHeader("X-User-Id") @Parameter(description = "用户ID") Long userId) {
        List<Notification> notifications = notificationService.getUnreadNotifications(userId);
        return Result.ok(notifications);
    }

    @GetMapping
    @Operation(summary = "获取全部消息", description = "获取用户所有消息列表")
    public Result<List<Notification>> getAllNotifications(
            @RequestHeader("X-User-Id") @Parameter(description = "用户ID") Long userId,
            @RequestParam(required = false) @Parameter(description = "消息类型") String type,
            @RequestParam(defaultValue = "1") @Parameter(description = "页码") Integer page,
            @RequestParam(defaultValue = "20") @Parameter(description = "每页数量") Integer size) {
        List<Notification> notifications = notificationService.getAllNotifications(userId, type, page, size);
        return Result.ok(notifications);
    }

    @PostMapping("/{notificationId}/read")
    @Operation(summary = "标记已读", description = "将单条消息标记为已读")
    public Result<Void> markAsRead(
            @PathVariable @Parameter(description = "通知ID") Long notificationId) {
        notificationService.markAsRead(notificationId);
        return Result.ok();
    }

    @PostMapping("/read-all")
    @Operation(summary = "标记全部已读", description = "将用户所有未读消息标记为已读")
    public Result<Void> markAllAsRead(
            @RequestHeader("X-User-Id") @Parameter(description = "用户ID") Long userId) {
        notificationService.markAllAsRead(userId);
        return Result.ok();
    }

    @GetMapping("/unread-count")
    @Operation(summary = "获取未读数量", description = "获取用户未读消息数量")
    public Result<Map<String, Long>> getUnreadCount(
            @RequestHeader("X-User-Id") @Parameter(description = "用户ID") Long userId) {
        long count = notificationService.getUnreadCount(userId);
        return Result.ok(Map.of("count", count));
    }

    @PostMapping("/send")
    @Operation(summary = "发送消息", description = "发送系统消息（仅管理员）")
    public Result<Void> sendNotification(
            @RequestParam @Parameter(description = "用户ID") Long userId,
            @RequestParam @Parameter(description = "消息类型") String type,
            @RequestParam @Parameter(description = "标题") String title,
            @RequestParam @Parameter(description = "内容") String content) {
        notificationService.sendNotification(userId, type, title, content);
        return Result.ok();
    }

    @DeleteMapping("/{notificationId}")
    @Operation(summary = "删除消息", description = "删除指定消息")
    public Result<Void> deleteNotification(
            @PathVariable @Parameter(description = "通知ID") Long notificationId) {
        notificationService.deleteNotification(notificationId);
        return Result.ok();
    }
}
