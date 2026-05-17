package com.bucketwater.oms.module.platform.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.platform.entity.PlatformConfig;
import com.bucketwater.oms.module.platform.mapper.PlatformConfigMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class PlatformConfigService {

    @Autowired
    private PlatformConfigMapper configMapper;

    public List<PlatformConfig> getConfigList(String configGroup) {
        LambdaQueryWrapper<PlatformConfig> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(configGroup)) {
            wrapper.eq(PlatformConfig::getConfigGroup, configGroup);
        }
        wrapper.orderByAsc(PlatformConfig::getSortOrder);
        return configMapper.selectList(wrapper);
    }

    public Map<String, String> getConfigMap(String configGroup) {
        List<PlatformConfig> configs = getConfigList(configGroup);
        Map<String, String> configMap = new HashMap<>();
        configs.forEach(config -> configMap.put(config.getConfigKey(), config.getConfigValue()));
        return configMap;
    }

    public PlatformConfig getConfigById(Long id) {
        PlatformConfig config = configMapper.selectById(id);
        if (config == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "配置不存在");
        }
        return config;
    }

    public PlatformConfig getConfigByKey(String configKey) {
        LambdaQueryWrapper<PlatformConfig> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(PlatformConfig::getConfigKey, configKey);
        return configMapper.selectOne(wrapper);
    }

    public String getConfigValue(String configKey) {
        PlatformConfig config = getConfigByKey(configKey);
        return config != null ? config.getConfigValue() : null;
    }

    public String getConfigValue(String configKey, String defaultValue) {
        String value = getConfigValue(configKey);
        return value != null ? value : defaultValue;
    }

    @Transactional
    public PlatformConfig createConfig(PlatformConfig config) {
        PlatformConfig existing = getConfigByKey(config.getConfigKey());
        if (existing != null) {
            throw new BusinessException(ResultCode.DATA_EXISTS, "配置键已存在: " + config.getConfigKey());
        }
        
        config.setCreateTime(LocalDateTime.now());
        config.setUpdateTime(LocalDateTime.now());
        config.setEnabled(1);
        
        configMapper.insert(config);
        return config;
    }

    @Transactional
    public PlatformConfig updateConfig(Long id, PlatformConfig config) {
        PlatformConfig existing = getConfigById(id);

        if (config.getConfigName() != null) {
            existing.setConfigName(config.getConfigName());
        }
        if (config.getConfigValue() != null) {
            existing.setConfigValue(config.getConfigValue());
        }
        if (config.getDescription() != null) {
            existing.setDescription(config.getDescription());
        }
        if (config.getConfigType() != null) {
            existing.setConfigType(config.getConfigType());
        }
        if (config.getEnabled() != null) {
            existing.setEnabled(config.getEnabled());
        }
        if (config.getSortOrder() != null) {
            existing.setSortOrder(config.getSortOrder());
        }

        existing.setUpdateTime(LocalDateTime.now());
        configMapper.updateById(existing);
        return existing;
    }

    @Transactional
    public void updateConfigValue(String configKey, String configValue) {
        PlatformConfig config = getConfigByKey(configKey);
        if (config == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "配置不存在: " + configKey);
        }
        config.setConfigValue(configValue);
        config.setUpdateTime(LocalDateTime.now());
        configMapper.updateById(config);
    }

    @Transactional
    public void deleteConfig(Long id) {
        PlatformConfig config = getConfigById(id);
        configMapper.deleteById(id);
    }

    @Transactional
    public void batchUpdateConfigs(Map<String, String> configMap) {
        configMap.forEach(this::updateConfigValue);
    }
}
