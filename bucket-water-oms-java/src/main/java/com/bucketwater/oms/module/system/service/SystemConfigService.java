package com.bucketwater.oms.module.system.service;

import com.bucketwater.oms.module.system.entity.SystemConfig;
import com.bucketwater.oms.module.system.mapper.SystemConfigMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class SystemConfigService {

    private static final Logger log = LoggerFactory.getLogger(SystemConfigService.class);

    @Autowired
    private SystemConfigMapper systemConfigMapper;

    @Autowired
    private StringRedisTemplate redisTemplate;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private static final String CONFIG_CACHE_PREFIX = "system:config:";

    public String getConfigValue(String key) {
        String cacheKey = CONFIG_CACHE_PREFIX + key;
        String cachedValue = redisTemplate.opsForValue().get(cacheKey);
        if (cachedValue != null) {
            return cachedValue;
        }

        SystemConfig config = systemConfigMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<SystemConfig>()
                .eq(SystemConfig::getConfigKey, key)
        );

        if (config != null) {
            redisTemplate.opsForValue().set(cacheKey, config.getConfigValue());
            return config.getConfigValue();
        }

        return null;
    }

    public List<SystemConfig> getConfigsByGroup(String group) {
        return systemConfigMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<SystemConfig>()
                .eq(SystemConfig::getConfigGroup, group)
                .orderByAsc(SystemConfig::getConfigKey)
        );
    }

    public List<SystemConfig> getAllConfigs() {
        return systemConfigMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<SystemConfig>()
                .orderByAsc(SystemConfig::getConfigGroup, SystemConfig::getConfigKey)
        );
    }

    @Transactional
    public SystemConfig createConfig(SystemConfig config) {
        config.setCreateTime(LocalDateTime.now());
        config.setUpdateTime(LocalDateTime.now());
        config.setIsSystem(false);

        systemConfigMapper.insert(config);

        redisTemplate.delete(CONFIG_CACHE_PREFIX + config.getConfigKey());

        return config;
    }

    @Transactional
    public SystemConfig updateConfig(Long id, String value) {
        SystemConfig config = systemConfigMapper.selectById(id);
        if (config == null) {
            throw new RuntimeException("配置不存在");
        }

        if (config.getIsSystem()) {
            throw new RuntimeException("系统内置配置不可修改");
        }

        config.setConfigValue(value);
        config.setUpdateTime(LocalDateTime.now());
        systemConfigMapper.updateById(config);

        redisTemplate.delete(CONFIG_CACHE_PREFIX + config.getConfigKey());

        return config;
    }

    public void initDefaultConfigs() {
        if (!ensureTableExists()) {
            log.warn("system_config 表创建失败或已存在，跳过配置初始化");
            return;
        }

        createDefaultConfig("statement.day", "1", "integer", "statement", "每月对账日", false);
        createDefaultConfig("statement.auto_generate", "true", "boolean", "statement", "自动生成对账单", false);
        createDefaultConfig("statement.generate_hour", "2", "integer", "statement", "对账单生成时间（小时）", false);
        createDefaultConfig("order.timeout_hours", "2", "integer", "order", "订单超时时间（小时）", false);
        createDefaultConfig("bucket.default_deposit", "30", "decimal", "bucket", "默认每桶押金金额", false);
        createDefaultConfig("bucket.default_threshold", "10", "integer", "bucket", "默认欠桶阈值", false);
    }

    private boolean ensureTableExists() {
        try {
            String checkSql = "SELECT COUNT(*) FROM pg_tables WHERE tablename = 'system_config' AND schemaname = 'public'";
            Integer count = jdbcTemplate.queryForObject(checkSql, Integer.class);

            if (count != null && count > 0) {
                log.info("system_config 表已存在");
                return true;
            }

            log.info("system_config 表不存在，开始创建...");

            try {
                jdbcTemplate.execute("CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\"");
                log.info("uuid-ossp 扩展已启用");
            } catch (Exception e) {
                log.warn("创建 uuid-ossp 扩展失败，将使用 Java 生成 UUID: {}", e.getMessage());
            }

            String createTableSql = """
                CREATE TABLE system_config (
                    id UUID PRIMARY KEY,
                    config_key VARCHAR(100) NOT NULL UNIQUE,
                    config_value TEXT,
                    config_type VARCHAR(20) DEFAULT 'string',
                    config_group VARCHAR(50),
                    description VARCHAR(255),
                    is_system BOOLEAN DEFAULT false,
                    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    deleted INTEGER DEFAULT 0
                )
                """;
            jdbcTemplate.execute(createTableSql);
            log.info("system_config 表创建成功");

            String createIndexSql = "CREATE UNIQUE INDEX idx_system_config_key ON system_config(config_key)";
            jdbcTemplate.execute(createIndexSql);
            log.info("system_config 索引创建成功");

            return true;

        } catch (Exception e) {
            log.error("创建 system_config 表失败: {}", e.getMessage(), e);
            return false;
        }
    }

    private void createDefaultConfig(String key, String value, String type, String group, String desc, boolean isSystem) {
        SystemConfig existing = systemConfigMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<SystemConfig>()
                .eq(SystemConfig::getConfigKey, key)
        );

        if (existing == null) {
            SystemConfig config = new SystemConfig();
            config.setConfigKey(key);
            config.setConfigValue(value);
            config.setConfigType(type);
            config.setConfigGroup(group);
            config.setDescription(desc);
            config.setIsSystem(isSystem);
            createConfig(config);
        }
    }
}
