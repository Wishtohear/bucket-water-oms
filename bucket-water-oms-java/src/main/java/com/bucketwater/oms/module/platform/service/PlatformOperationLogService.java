package com.bucketwater.oms.module.platform.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.bucketwater.oms.module.platform.entity.PlatformOperationLog;
import com.bucketwater.oms.module.platform.mapper.PlatformOperationLogMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class PlatformOperationLogService {

    @Autowired
    private PlatformOperationLogMapper logMapper;

    @Transactional
    public PlatformOperationLog saveLog(PlatformOperationLog log) {
        if (log.getCreateTime() == null) {
            log.setCreateTime(LocalDateTime.now());
        }
        logMapper.insert(log);
        return log;
    }

    public IPage<PlatformOperationLog> getLogPage(
            String module,
            String action,
            Long userId,
            String userName,
            String targetType,
            LocalDateTime startTime,
            LocalDateTime endTime,
            Integer page,
            Integer size) {
        
        Page<PlatformOperationLog> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<PlatformOperationLog> wrapper = new LambdaQueryWrapper<>();
        
        if (StringUtils.hasText(module)) {
            wrapper.eq(PlatformOperationLog::getModule, module);
        }
        
        if (StringUtils.hasText(action)) {
            wrapper.eq(PlatformOperationLog::getAction, action);
        }
        
        if (userId != null) {
            wrapper.eq(PlatformOperationLog::getUserId, userId);
        }
        
        if (StringUtils.hasText(userName)) {
            wrapper.like(PlatformOperationLog::getUserName, userName);
        }
        
        if (StringUtils.hasText(targetType)) {
            wrapper.eq(PlatformOperationLog::getTargetType, targetType);
        }
        
        if (startTime != null) {
            wrapper.ge(PlatformOperationLog::getCreateTime, startTime);
        }
        
        if (endTime != null) {
            wrapper.le(PlatformOperationLog::getCreateTime, endTime);
        }
        
        wrapper.orderByDesc(PlatformOperationLog::getCreateTime);
        
        return logMapper.selectPage(pageParam, wrapper);
    }

    public List<PlatformOperationLog> getLogList(
            String module,
            String action,
            Long userId,
            String userName,
            String targetType,
            LocalDateTime startTime,
            LocalDateTime endTime,
            Integer limit) {
        
        LambdaQueryWrapper<PlatformOperationLog> wrapper = new LambdaQueryWrapper<>();
        
        if (StringUtils.hasText(module)) {
            wrapper.eq(PlatformOperationLog::getModule, module);
        }
        
        if (StringUtils.hasText(action)) {
            wrapper.eq(PlatformOperationLog::getAction, action);
        }
        
        if (userId != null) {
            wrapper.eq(PlatformOperationLog::getUserId, userId);
        }
        
        if (StringUtils.hasText(userName)) {
            wrapper.like(PlatformOperationLog::getUserName, userName);
        }
        
        if (StringUtils.hasText(targetType)) {
            wrapper.eq(PlatformOperationLog::getTargetType, targetType);
        }
        
        if (startTime != null) {
            wrapper.ge(PlatformOperationLog::getCreateTime, startTime);
        }
        
        if (endTime != null) {
            wrapper.le(PlatformOperationLog::getCreateTime, endTime);
        }
        
        wrapper.orderByDesc(PlatformOperationLog::getCreateTime);
        
        if (limit != null && limit > 0) {
            wrapper.last("LIMIT " + limit);
        }
        
        return logMapper.selectList(wrapper);
    }

    public PlatformOperationLog getLogById(Long id) {
        return logMapper.selectById(id);
    }

    @Transactional
    public void deleteLog(Long id) {
        logMapper.deleteById(id);
    }

    @Transactional
    public void deleteLogs(List<Long> ids) {
        logMapper.deleteBatchIds(ids);
    }

    @Transactional
    public void clearLogs(LocalDateTime beforeTime) {
        LambdaQueryWrapper<PlatformOperationLog> wrapper = new LambdaQueryWrapper<>();
        wrapper.le(PlatformOperationLog::getCreateTime, beforeTime);
        logMapper.delete(wrapper);
    }
}
