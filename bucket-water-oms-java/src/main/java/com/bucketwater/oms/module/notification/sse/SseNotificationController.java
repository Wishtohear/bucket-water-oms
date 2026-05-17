package com.bucketwater.oms.module.notification.sse;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

@RestController
@RequestMapping("/api/notifications")
@Tag(name = "SSE通知推送", description = "SSE实时消息推送接口")
public class SseNotificationController {

    private static final Logger log = LoggerFactory.getLogger(SseNotificationController.class);

    private final SseEmitterManager sseEmitterManager;

    @Autowired
    public SseNotificationController(SseEmitterManager sseEmitterManager) {
        this.sseEmitterManager = sseEmitterManager;
        log.info("✅ SseNotificationController 已初始化");
    }

    @RequestMapping(value = "/subscribe", method = RequestMethod.GET)
    @Operation(summary = "订阅SSE通知", description = "建立SSE长连接，接收实时通知推送")
    public SseEmitter subscribe(
            @RequestParam(value = "userId") Long userId,
            @RequestParam(value = "role", required = false) String role) {

        log.info("SSE连接请求: userId={}, role={}", userId, role);

        SseEmitter emitter = sseEmitterManager.createEmitter(userId);

        if (role != null && !role.isEmpty()) {
            sseEmitterManager.addUserToRole(userId, role, emitter);
        }

        try {
            String connectedData = "{\"status\":\"connected\",\"userId\":" + userId + ",\"timestamp\":" + System.currentTimeMillis() + "}";
            emitter.send(SseEmitter.event()
                    .name("connected")
                    .data(connectedData, MediaType.APPLICATION_JSON));
            log.info("SSE连接初始化事件已发送: userId={}", userId);
        } catch (Exception e) {
            log.warn("发送SSE初始化事件失败: userId={}, error={}", userId, e.getMessage());
        }

        return emitter;
    }

    @GetMapping("/status")
    @Operation(summary = "获取连接状态", description = "查看当前SSE连接状态")
    public Result<?> getStatus(@RequestParam Long userId) {
        boolean online = sseEmitterManager.isUserOnline(userId);
        int totalOnline = sseEmitterManager.getOnlineUserCount();
        return Result.ok(new StatusVO(online, totalOnline));
    }

    @PostMapping("/heartbeat")
    @Operation(summary = "发送心跳", description = "保持连接活跃")
    public Result<?> heartbeat(@RequestParam Long userId) {
        if (sseEmitterManager.isUserOnline(userId)) {
            sseEmitterManager.sendHeartbeat(userId);
            return Result.ok("心跳发送成功");
        } else {
            return Result.fail("用户不在线");
        }
    }

    @PostMapping("/disconnect")
    @Operation(summary = "断开连接", description = "主动断开SSE连接")
    public Result<?> disconnect(@RequestParam Long userId) {
        sseEmitterManager.disconnectUser(userId);
        return Result.ok("连接已断开");
    }

    @GetMapping("/online-stats")
    @Operation(summary = "获取在线统计", description = "获取各角色在线人数统计")
    public Result<?> getOnlineStats() {
        OnlineStats stats = new OnlineStats();
        stats.setTotalOnline(sseEmitterManager.getOnlineUserCount());
        stats.setWarehouseOnline(sseEmitterManager.getOnlineUserCountByRole("warehouse"));
        stats.setDriverOnline(sseEmitterManager.getOnlineUserCountByRole("driver"));
        stats.setStationOnline(sseEmitterManager.getOnlineUserCountByRole("station"));
        stats.setAdminOnline(sseEmitterManager.getOnlineUserCountByRole("admin"));
        return Result.ok(stats);
    }

    public static class StatusVO {
        private boolean online;
        private int totalOnline;

        public StatusVO() {}
        public StatusVO(boolean online, int totalOnline) {
            this.online = online;
            this.totalOnline = totalOnline;
        }
        public boolean isOnline() { return online; }
        public void setOnline(boolean online) { this.online = online; }
        public int getTotalOnline() { return totalOnline; }
        public void setTotalOnline(int totalOnline) { this.totalOnline = totalOnline; }
    }

    public static class OnlineStats {
        private int totalOnline;
        private int warehouseOnline;
        private int driverOnline;
        private int stationOnline;
        private int adminOnline;

        public int getTotalOnline() { return totalOnline; }
        public void setTotalOnline(int totalOnline) { this.totalOnline = totalOnline; }
        public int getWarehouseOnline() { return warehouseOnline; }
        public void setWarehouseOnline(int warehouseOnline) { this.warehouseOnline = warehouseOnline; }
        public int getDriverOnline() { return driverOnline; }
        public void setDriverOnline(int driverOnline) { this.driverOnline = driverOnline; }
        public int getStationOnline() { return stationOnline; }
        public void setStationOnline(int stationOnline) { this.stationOnline = stationOnline; }
        public int getAdminOnline() { return adminOnline; }
        public void setAdminOnline(int adminOnline) { this.adminOnline = adminOnline; }
    }

    public static class Result<T> {
        private boolean success;
        private T data;
        private String message;

        public static <T> Result<T> ok(T data) {
            Result<T> result = new Result<>();
            result.success = true;
            result.data = data;
            return result;
        }
        public static <T> Result<T> ok(String message) {
            Result<T> result = new Result<>();
            result.success = true;
            result.message = message;
            return result;
        }
        public static <T> Result<T> fail(String message) {
            Result<T> result = new Result<>();
            result.success = false;
            result.message = message;
            return result;
        }
        public boolean isSuccess() { return success; }
        public void setSuccess(boolean success) { this.success = success; }
        public T getData() { return data; }
        public void setData(T data) { this.data = data; }
        public String getMessage() { return message; }
        public void setMessage(String message) { this.message = message; }
    }
}
