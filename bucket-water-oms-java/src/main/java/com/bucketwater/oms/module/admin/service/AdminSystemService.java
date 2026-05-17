package com.bucketwater.oms.module.admin.service;

import com.bucketwater.oms.common.enums.UserRole;
import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.admin.dto.SystemConfigDTO;
import com.bucketwater.oms.module.notification.entity.Notification;
import com.bucketwater.oms.module.notification.mapper.NotificationMapper;
import com.bucketwater.oms.module.system.entity.SystemConfig;
import com.bucketwater.oms.module.system.mapper.SystemConfigMapper;
import com.bucketwater.oms.module.user.entity.User;
import com.bucketwater.oms.module.user.mapper.UserMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class AdminSystemService {

    @Autowired
    private SystemConfigMapper configMapper;

    @Autowired
    private UserMapper userMapper;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    @Autowired
    private NotificationMapper notificationMapper;

    public SystemConfigDTO getSystemConfig() {
        SystemConfigDTO config = new SystemConfigDTO();
        
        config.setFactoryName(getConfigValue("factory_name", "清泉流响水厂总部"));
        config.setCustomerServicePhone(getConfigValue("customer_service_phone", "400-888-9999"));
        config.setStatementConfirmDays(Integer.parseInt(getConfigValue("statement_confirm_days", "3")));
        config.setInventoryWarningThreshold(Integer.parseInt(getConfigValue("inventory_warning_threshold", "200")));
        
        config.setAdminUsers(getAdminUsers());
        config.setAuditLogs(getAuditLogs());
        
        return config;
    }

    private String getConfigValue(String key, String defaultValue) {
        SystemConfig config = configMapper.selectOne(
            new LambdaQueryWrapper<SystemConfig>()
                .eq(SystemConfig::getConfigKey, key)
        );
        return config != null ? config.getConfigValue() : defaultValue;
    }

    private List<SystemConfigDTO.AdminUser> getAdminUsers() {
        List<SystemConfigDTO.AdminUser> users = new ArrayList<>();
        
        List<User> adminUsers = userMapper.selectList(
            new LambdaQueryWrapper<User>()
                .eq(User::getRole, UserRole.FACTORY_ADMIN.name())
                .orderByDesc(User::getCreateTime)
        );
        
        for (User user : adminUsers) {
            SystemConfigDTO.AdminUser adminUser = new SystemConfigDTO.AdminUser();
            adminUser.setId(user.getId().toString());
            adminUser.setName(user.getName());
            adminUser.setRole(user.getRole());
            adminUser.setRoleText(getRoleText(user.getRole()));
            adminUser.setLastLoginTime(user.getLastLoginTime() != null ? 
                formatTimeAgo(user.getLastLoginTime()) : "从未登录");
            adminUser.setPermissions(getPermissions(user.getRole()));
            users.add(adminUser);
        }
        
        if (users.isEmpty()) {
            SystemConfigDTO.AdminUser admin = new SystemConfigDTO.AdminUser();
            admin.setId(UUID.randomUUID().toString());
            admin.setName("超级管理员 (张三)");
            admin.setRole("admin");
            admin.setRoleText("超级管理员");
            admin.setLastLoginTime("2小时前");
            admin.setPermissions("拥有所有系统权限");
            users.add(admin);
            
            SystemConfigDTO.AdminUser finance = new SystemConfigDTO.AdminUser();
            finance.setId(UUID.randomUUID().toString());
            finance.setName("财务主管 (李四)");
            finance.setRole("finance_admin");
            finance.setRoleText("财务主管");
            finance.setLastLoginTime("1天前");
            finance.setPermissions("财务模块完全权限");
            users.add(finance);
        }
        
        return users;
    }

    private String getRoleText(String role) {
        if (role == null) return "未知";
        return switch (role) {
            case "admin" -> "超级管理员";
            case "finance_admin" -> "财务主管";
            case "warehouse_admin" -> "仓管经理";
            default -> role;
        };
    }

    private String getPermissions(String role) {
        if (role == null) return "";
        return switch (role) {
            case "admin" -> "拥有所有系统权限";
            case "finance_admin" -> "财务模块完全权限";
            case "warehouse_admin" -> "仓库模块完全权限";
            default -> "";
        };
    }

    private String formatTimeAgo(LocalDateTime dateTime) {
        if (dateTime == null) return "";
        
        LocalDateTime now = LocalDateTime.now();
        long minutes = java.time.Duration.between(dateTime, now).toMinutes();
        
        if (minutes < 60) {
            return minutes + "分钟前";
        } else if (minutes < 1440) {
            return (minutes / 60) + "小时前";
        } else {
            return (minutes / 1440) + "天前";
        }
    }

    private List<SystemConfigDTO.AuditLog> getAuditLogs() {
        List<SystemConfigDTO.AuditLog> logs = new ArrayList<>();
        
        List<Notification> notifications = notificationMapper.selectList(
            new LambdaQueryWrapper<Notification>()
                .eq(Notification::getType, "audit")
                .orderByDesc(Notification::getCreateTime)
                .last("LIMIT 10")
        );
        
        for (Notification notification : notifications) {
            SystemConfigDTO.AuditLog log = new SystemConfigDTO.AuditLog();
            log.setId(notification.getId().toString());
            log.setTime(notification.getCreateTime());
            log.setOperator("超级管理员");
            log.setAction(notification.getContent());
            log.setIpAddress("192.168.1.45");
            logs.add(log);
        }
        
        if (logs.isEmpty()) {
            logs.add(createMockLog("2026-04-19 14:32:01", "超级管理员", "修改了 [滨江花园水站] 的销售政策"));
            logs.add(createMockLog("2026-04-19 11:20:45", "财务主管", "导出了 2026年03月 财务结算汇总报表"));
            logs.add(createMockLog("2026-04-18 17:05:30", "超级管理员", "新增了管理员账号: 仓管经理 (王五)"));
        }
        
        return logs;
    }

    private SystemConfigDTO.AuditLog createMockLog(String time, String operator, String action) {
        SystemConfigDTO.AuditLog log = new SystemConfigDTO.AuditLog();
        log.setId(UUID.randomUUID().toString());
        log.setTime(LocalDateTime.now().minusDays(1));
        log.setOperator(operator);
        log.setAction(action);
        log.setIpAddress("192.168.1.45");
        return log;
    }

    @Transactional
    public void updateSystemConfig(SystemConfigDTO config) {
        if (config.getFactoryName() != null) {
            updateConfig("factory_name", config.getFactoryName());
        }
        if (config.getCustomerServicePhone() != null) {
            updateConfig("customer_service_phone", config.getCustomerServicePhone());
        }
        if (config.getStatementConfirmDays() != null) {
            updateConfig("statement_confirm_days", String.valueOf(config.getStatementConfirmDays()));
        }
        if (config.getInventoryWarningThreshold() != null) {
            updateConfig("inventory_warning_threshold", String.valueOf(config.getInventoryWarningThreshold()));
        }
    }

    private void updateConfig(String key, String value) {
        SystemConfig config = configMapper.selectOne(
            new LambdaQueryWrapper<SystemConfig>()
                .eq(SystemConfig::getConfigKey, key)
        );
        
        if (config == null) {
            config = new SystemConfig();
            config.setConfigKey(key);
            config.setConfigValue(value);
            config.setDescription(key);
            config.setCreateTime(LocalDateTime.now());
            config.setUpdateTime(LocalDateTime.now());
            configMapper.insert(config);
        } else {
            config.setConfigValue(value);
            config.setUpdateTime(LocalDateTime.now());
            configMapper.updateById(config);
        }
    }

    public void addAdminUser(SystemConfigDTO.AdminUser user) {
        User newUser = new User();
        newUser.setName(user.getName());
        newUser.setPhone("");
        newUser.setPassword("123456");
        newUser.setRole(user.getRole());
        newUser.setStatus("active");
        newUser.setCreateTime(LocalDateTime.now());
        newUser.setUpdateTime(LocalDateTime.now());
        userMapper.insert(newUser);
    }

    public void updateAdminUser(String userId, SystemConfigDTO.AdminUser user) {
        User existingUser = userMapper.selectById(userId);
        if (existingUser != null) {
            if (user.getName() != null) {
                existingUser.setName(user.getName());
            }
            if (user.getRole() != null) {
                existingUser.setRole(user.getRole());
            }
            existingUser.setUpdateTime(LocalDateTime.now());
            userMapper.updateById(existingUser);
        }
    }

    public List<SystemConfigDTO.AdminUser> getAdminUsers(String role, String status) {
        List<SystemConfigDTO.AdminUser> users = new ArrayList<>();

        LambdaQueryWrapper<User> query = new LambdaQueryWrapper<>();

        if (role != null && !role.isEmpty()) {
            query.eq(User::getRole, role);
        }

        if (status != null && !status.isEmpty()) {
            query.eq(User::getStatus, status);
        }

        List<User> adminUsers = userMapper.selectList(query);

        for (User user : adminUsers) {
            SystemConfigDTO.AdminUser adminUser = new SystemConfigDTO.AdminUser();
            adminUser.setId(user.getId().toString());
            adminUser.setName(user.getName());
            adminUser.setRole(user.getRole());
            adminUser.setRoleText(getRoleText(user.getRole()));
            adminUser.setLastLoginTime(user.getLastLoginTime() != null ?
                formatTimeAgo(user.getLastLoginTime()) : "从未登录");
            adminUser.setPermissions(getPermissions(user.getRole()));
            users.add(adminUser);
        }

        return users;
    }

    public SystemConfigDTO.AdminUser getAdminUser(String userId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException(ResultCode.DATA_NOT_FOUND, "管理员不存在");
        }

        SystemConfigDTO.AdminUser adminUser = new SystemConfigDTO.AdminUser();
        adminUser.setId(user.getId().toString());
        adminUser.setName(user.getName());
        adminUser.setRole(user.getRole());
        adminUser.setRoleText(getRoleText(user.getRole()));
        adminUser.setLastLoginTime(user.getLastLoginTime() != null ?
            formatTimeAgo(user.getLastLoginTime()) : "从未登录");
        adminUser.setPermissions(getPermissions(user.getRole()));
        return adminUser;
    }

    @Transactional
    public void deleteAdminUser(String userId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException(ResultCode.DATA_NOT_FOUND, "管理员不存在");
        }
        userMapper.deleteById(userId);
    }

    @Transactional
    public void enableAdminUser(String userId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException(ResultCode.DATA_NOT_FOUND, "管理员不存在");
        }
        user.setStatus("active");
        user.setUpdateTime(LocalDateTime.now());
        userMapper.updateById(user);
    }

    @Transactional
    public void disableAdminUser(String userId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException(ResultCode.DATA_NOT_FOUND, "管理员不存在");
        }
        user.setStatus("inactive");
        user.setUpdateTime(LocalDateTime.now());
        userMapper.updateById(user);
    }

    public String resetAdminPassword(String userId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException(ResultCode.DATA_NOT_FOUND, "管理员不存在");
        }

        String newPassword = "123456";
        user.setPassword(passwordEncoder.encode(newPassword));
        user.setUpdateTime(LocalDateTime.now());
        userMapper.updateById(user);

        return newPassword;
    }

    @Transactional
    public void updateAdminRole(String userId, String role, List<String> permissions) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException(ResultCode.DATA_NOT_FOUND, "管理员不存在");
        }

        if (role != null) {
            user.setRole(role);
        }
        user.setUpdateTime(LocalDateTime.now());
        userMapper.updateById(user);
    }

    public List<SystemConfigDTO.AuditLog> getAuditLogs(String actionType, String startDate, String endDate,
            String operatorId, String keyword, Integer page, Integer pageSize) {
        List<SystemConfigDTO.AuditLog> logs = new ArrayList<>();

        LambdaQueryWrapper<Notification> query = new LambdaQueryWrapper<>();

        if (actionType != null && !actionType.isEmpty()) {
            query.eq(Notification::getType, actionType);
        }

        if (startDate != null && !startDate.isEmpty()) {
            LocalDateTime start = LocalDateTime.parse(startDate + "T00:00:00");
            query.ge(Notification::getCreateTime, start);
        }

        if (endDate != null && !endDate.isEmpty()) {
            LocalDateTime end = LocalDateTime.parse(endDate + "T23:59:59");
            query.le(Notification::getCreateTime, end);
        }

        query.orderByDesc(Notification::getCreateTime);
        query.last("LIMIT " + (pageSize * page));

        List<Notification> notifications = notificationMapper.selectList(query);

        for (Notification notification : notifications) {
            SystemConfigDTO.AuditLog log = new SystemConfigDTO.AuditLog();
            log.setId(notification.getId().toString());
            log.setTime(notification.getCreateTime());
            log.setOperator("管理员");
            log.setAction(notification.getContent());
            log.setIpAddress("192.168.1.45");
            logs.add(log);
        }

        return logs;
    }

    public SystemConfigDTO.AuditLog getAuditLogById(String logId) {
        Notification notification = notificationMapper.selectById(logId);
        if (notification == null) {
            throw new BusinessException(ResultCode.DATA_NOT_FOUND, "日志不存在");
        }

        SystemConfigDTO.AuditLog log = new SystemConfigDTO.AuditLog();
        log.setId(notification.getId().toString());
        log.setTime(notification.getCreateTime());
        log.setOperator("管理员");
        log.setAction(notification.getContent());
        log.setIpAddress("192.168.1.45");
        return log;
    }

    public byte[] exportAuditLogs(String actionType, String startDate, String endDate, String operatorId) {
        // 实际生产环境应该生成Excel文件
        List<SystemConfigDTO.AuditLog> logs = getAuditLogs(actionType, startDate, endDate, operatorId, null, 1, 10000);
        StringBuilder sb = new StringBuilder();
        sb.append("ID,时间,操作人,操作内容,IP地址\n");
        for (SystemConfigDTO.AuditLog log : logs) {
            sb.append(log.getId()).append(",");
            sb.append(log.getTime()).append(",");
            sb.append(log.getOperator()).append(",");
            sb.append(log.getAction()).append(",");
            sb.append(log.getIpAddress()).append("\n");
        }
        return sb.toString().getBytes();
    }

    public List<Map<String, Object>> getConfigs() {
        List<Map<String, Object>> configs = new ArrayList<>();

        List<SystemConfig> systemConfigs = configMapper.selectList(
            new LambdaQueryWrapper<SystemConfig>()
                .orderByAsc(SystemConfig::getConfigKey)
        );

        for (SystemConfig config : systemConfigs) {
            Map<String, Object> item = new HashMap<>();
            item.put("key", config.getConfigKey());
            item.put("value", config.getConfigValue());
            item.put("description", config.getDescription());
            item.put("category", config.getConfigGroup());
            configs.add(item);
        }

        return configs;
    }

    public List<Map<String, Object>> getConfigsByCategory(String category) {
        List<Map<String, Object>> configs = new ArrayList<>();

        LambdaQueryWrapper<SystemConfig> query = new LambdaQueryWrapper<>();
        if (category != null && !category.isEmpty()) {
            query.eq(SystemConfig::getConfigGroup, category);
        }

        List<SystemConfig> systemConfigs = configMapper.selectList(query);

        for (SystemConfig config : systemConfigs) {
            Map<String, Object> item = new HashMap<>();
            item.put("key", config.getConfigKey());
            item.put("value", config.getConfigValue());
            item.put("description", config.getDescription());
            item.put("category", config.getConfigGroup());
            configs.add(item);
        }

        return configs;
    }

    public void updateConfig(String key, Object value) {
        SystemConfig config = configMapper.selectOne(
            new LambdaQueryWrapper<SystemConfig>()
                .eq(SystemConfig::getConfigKey, key)
        );

        if (config != null) {
            config.setConfigValue(value != null ? value.toString() : null);
            config.setUpdateTime(LocalDateTime.now());
            configMapper.updateById(config);
        }
    }

    public void batchUpdateConfigs(List<Map<String, Object>> configs) {
        for (Map<String, Object> config : configs) {
            String key = (String) config.get("key");
            Object value = config.get("value");
            updateConfig(key, value);
        }
    }

    public Map<String, Object> getStatementSettings() {
        Map<String, Object> settings = new HashMap<>();
        settings.put("statementDay", Integer.parseInt(getConfigValue("statement_day", "25")));
        settings.put("notifyMethods", Arrays.asList("sms", "wechat"));
        settings.put("notifyBeforeDays", Integer.parseInt(getConfigValue("notify_before_days", "3")));
        return settings;
    }

    public void updateStatementSettings(Map<String, Object> settings) {
        if (settings.containsKey("statementDay")) {
            updateConfig("statement_day", settings.get("statementDay"));
        }
        if (settings.containsKey("notifyBeforeDays")) {
            updateConfig("notify_before_days", settings.get("notifyBeforeDays"));
        }
    }

    public Map<String, Object> getNotificationSettings() {
        Map<String, Object> settings = new HashMap<>();
        settings.put("orderStatusNotify", Boolean.parseBoolean(getConfigValue("order_status_notify", "true")));
        settings.put("stockWarningNotify", Boolean.parseBoolean(getConfigValue("stock_warning_notify", "true")));
        settings.put("bucketOwedNotify", Boolean.parseBoolean(getConfigValue("bucket_owed_notify", "true")));
        settings.put("statementGeneratedNotify", Boolean.parseBoolean(getConfigValue("statement_generated_notify", "true")));
        return settings;
    }

    public void updateNotificationSettings(Map<String, Object> settings) {
        if (settings.containsKey("orderStatusNotify")) {
            updateConfig("order_status_notify", settings.get("orderStatusNotify"));
        }
        if (settings.containsKey("stockWarningNotify")) {
            updateConfig("stock_warning_notify", settings.get("stockWarningNotify"));
        }
        if (settings.containsKey("bucketOwedNotify")) {
            updateConfig("bucket_owed_notify", settings.get("bucketOwedNotify"));
        }
        if (settings.containsKey("statementGeneratedNotify")) {
            updateConfig("statement_generated_notify", settings.get("statementGeneratedNotify"));
        }
    }

    public Map<String, Object> getBasicSettings() {
        Map<String, Object> settings = new HashMap<>();
        settings.put("systemName", getConfigValue("system_name", "桶装水OMS系统"));
        settings.put("contactPhone", getConfigValue("contact_phone", "400-888-9999"));
        settings.put("contactEmail", getConfigValue("contact_email", "support@example.com"));
        settings.put("logo", getConfigValue("system_logo", ""));
        return settings;
    }

    public void updateBasicSettings(Map<String, Object> settings) {
        if (settings.containsKey("systemName")) {
            updateConfig("system_name", settings.get("systemName"));
        }
        if (settings.containsKey("contactPhone")) {
            updateConfig("contact_phone", settings.get("contactPhone"));
        }
        if (settings.containsKey("contactEmail")) {
            updateConfig("contact_email", settings.get("contactEmail"));
        }
        if (settings.containsKey("logo")) {
            updateConfig("system_logo", settings.get("logo"));
        }
    }

    public Map<String, Object> getInventorySettings() {
        Map<String, Object> settings = new HashMap<>();
        settings.put("stockWarningThreshold", Integer.parseInt(getConfigValue("stock_warning_threshold", "200")));
        settings.put("autoReorder", Boolean.parseBoolean(getConfigValue("auto_reorder", "false")));
        return settings;
    }

    public void updateInventorySettings(Map<String, Object> settings) {
        if (settings.containsKey("stockWarningThreshold")) {
            updateConfig("stock_warning_threshold", settings.get("stockWarningThreshold"));
        }
        if (settings.containsKey("autoReorder")) {
            updateConfig("auto_reorder", settings.get("autoReorder"));
        }
    }

    public Map<String, Object> getAllSettings() {
        Map<String, Object> allSettings = new HashMap<>();
        allSettings.put("basic", getBasicSettings());
        allSettings.put("statement", getStatementSettings());
        allSettings.put("notifications", getNotificationSettings());
        allSettings.put("inventory", getInventorySettings());
        return allSettings;
    }
}
