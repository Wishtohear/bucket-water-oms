package com.bucketwater.oms.module.notification.sse;

import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.stream.Collectors;

@Component
public class SseEmitterManager {

    private static final Logger log = LoggerFactory.getLogger(SseEmitterManager.class);

    @PostConstruct
    public void init() {
        log.info("✅ SseEmitterManager 已初始化");
    }

    private static final long SSE_TIMEOUT = Long.MAX_VALUE;

    private final Map<Long, SseEmitter> userEmitters = new ConcurrentHashMap<>();
    private final Map<String, List<SseEmitter>> roleEmitters = new ConcurrentHashMap<>();

    public SseEmitter createEmitter(Long userId) {
        SseEmitter emitter = new SseEmitter(SSE_TIMEOUT);
        
        userEmitters.put(userId, emitter);
        
        emitter.onCompletion(() -> {
            log.info("SSE连接完成: userId={}", userId);
            userEmitters.remove(userId);
            removeUserFromRoles(userId);
        });
        
        emitter.onTimeout(() -> {
            log.info("SSE连接超时: userId={}", userId);
            userEmitters.remove(userId);
            removeUserFromRoles(userId);
        });
        
        emitter.onError(e -> {
            log.error("SSE连接错误: userId={}, error={}", userId, e.getMessage());
            userEmitters.remove(userId);
            removeUserFromRoles(userId);
        });
        
        try {
            emitter.send(SseEmitter.event()
                    .name("ping")
                    .data("{\"type\":\"ping\",\"timestamp\":" + System.currentTimeMillis() + "}"));
            log.info("SSE连接初始化ping已发送: userId={}", userId);
        } catch (Exception e) {
            log.warn("发送SSE初始化ping失败: userId={}, error={}", userId, e.getMessage());
        }
        
        log.info("创建SSE连接: userId={}, 当前在线用户数={}", userId, userEmitters.size());
        
        return emitter;
    }

    public void addUserToRole(Long userId, String role, SseEmitter emitter) {
        roleEmitters.computeIfAbsent(getRoleKey(role), k -> new CopyOnWriteArrayList<>()).add(emitter);
        log.info("用户添加到角色组: userId={}, role={}", userId, role);
    }

    private String getRoleKey(String role) {
        return role.toLowerCase();
    }

    private void removeUserFromRoles(Long userId) {
        for (Map.Entry<String, List<SseEmitter>> entry : roleEmitters.entrySet()) {
            entry.getValue().removeIf(emitter -> {
                boolean shouldRemove = !isEmitterActive(emitter);
                return shouldRemove;
            });
        }
    }

    private boolean isEmitterActive(SseEmitter emitter) {
        try {
            emitter.send(SseEmitter.event().name("ping").data(""));
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public void sendToUser(Long userId, String eventName, Object data) {
        SseEmitter emitter = userEmitters.get(userId);
        if (emitter != null) {
            try {
                String jsonData = data instanceof String ? (String) data : toJson(data);
                emitter.send(SseEmitter.event()
                    .name(eventName)
                    .data(jsonData));
                log.info("发送消息给用户: userId={}, event={}", userId, eventName);
            } catch (IOException e) {
                log.error("发送消息失败: userId={}, error={}", userId, e.getMessage());
                userEmitters.remove(userId);
            }
        } else {
            log.debug("用户不在线，跳过推送: userId={}", userId);
        }
    }

    public void sendToUsers(List<Long> userIds, String eventName, Object data) {
        for (Long userId : userIds) {
            sendToUser(userId, eventName, data);
        }
    }

    public void sendToRole(String role, String eventName, Object data) {
        String roleKey = getRoleKey(role);
        List<SseEmitter> emitters = roleEmitters.get(roleKey);
        
        if (emitters != null && !emitters.isEmpty()) {
            String jsonData = data instanceof String ? (String) data : toJson(data);
            for (SseEmitter emitter : emitters) {
                try {
                    emitter.send(SseEmitter.event()
                        .name(eventName)
                        .data(jsonData));
                } catch (IOException e) {
                    log.error("发送消息到角色失败: role={}, error={}", role, e.getMessage());
                }
            }
            log.info("发送消息到角色: role={}, event={}, 在线数={}", role, eventName, emitters.size());
        } else {
            log.debug("角色组无在线用户: role={}", role);
        }
    }

    public void sendToAllWarehouses(String eventName, Object data) {
        sendToRole("warehouse", eventName, data);
        sendToRole("WAREHOUSE_ADMIN", eventName, data);
    }

    public void sendToAllDrivers(String eventName, Object data) {
        sendToRole("driver", eventName, data);
        sendToRole("DRIVER", eventName, data);
    }

    public void sendToStationOwner(Long stationId, String eventName, Object data) {
        sendToRole("station", eventName, data);
        sendToRole("STATION", eventName, data);
    }

    public void sendHeartbeat(Long userId) {
        sendToUser(userId, "heartbeat", System.currentTimeMillis());
    }

    public boolean isUserOnline(Long userId) {
        return userEmitters.containsKey(userId);
    }

    public int getOnlineUserCount() {
        return userEmitters.size();
    }

    public int getOnlineUserCountByRole(String role) {
        String roleKey = getRoleKey(role);
        List<SseEmitter> emitters = roleEmitters.get(roleKey);
        return emitters != null ? emitters.size() : 0;
    }

    public void disconnectUser(Long userId) {
        SseEmitter emitter = userEmitters.remove(userId);
        if (emitter != null) {
            try {
                emitter.complete();
            } catch (Exception e) {
                log.error("断开连接失败: userId={}", userId, e);
            }
        }
    }

    private String toJson(Object obj) {
        try {
            com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
            return mapper.writeValueAsString(obj);
        } catch (Exception e) {
            log.error("JSON序列化失败: {}", e.getMessage());
            return "{\"error\": \"Serialization failed\"}";
        }
    }
}
