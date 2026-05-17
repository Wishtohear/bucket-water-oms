package com.bucketwater.oms.module.audit.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.bucketwater.oms.module.audit.dto.AuditLogDTO;
import com.bucketwater.oms.module.audit.dto.AuditLogQueryDTO;
import com.bucketwater.oms.module.audit.entity.AuditLog;
import com.bucketwater.oms.module.audit.mapper.AuditLogMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class AuditLogService {

    private static final Logger log = LoggerFactory.getLogger(AuditLogService.class);

    private final AuditLogMapper auditLogMapper;

    public AuditLogService(AuditLogMapper auditLogMapper) {
        this.auditLogMapper = auditLogMapper;
    }

    public void saveLog(AuditLog auditLog) {
        if (auditLog.getDeleted() == null) {
            auditLog.setDeleted(0);
        }
        auditLogMapper.insert(auditLog);
        log.info("审计日志已保存: id={}, user={}, action={}, module={}",
                auditLog.getId(), auditLog.getUsername(), auditLog.getAction(), auditLog.getModule());
    }

    public IPage<AuditLogDTO> queryLogs(AuditLogQueryDTO query) {
        LambdaQueryWrapper<AuditLog> wrapper = new LambdaQueryWrapper<>();

        if (query.getUserId() != null) {
            wrapper.eq(AuditLog::getUserId, query.getUserId());
        }
        if (query.getUsername() != null && !query.getUsername().isEmpty()) {
            wrapper.like(AuditLog::getUsername, query.getUsername());
        }
        if (query.getAction() != null && !query.getAction().isEmpty()) {
            wrapper.eq(AuditLog::getAction, query.getAction());
        }
        if (query.getModule() != null && !query.getModule().isEmpty()) {
            wrapper.eq(AuditLog::getModule, query.getModule());
        }
        if (query.getEntityType() != null && !query.getEntityType().isEmpty()) {
            wrapper.eq(AuditLog::getEntityType, query.getEntityType());
        }
        if (query.getEntityId() != null && !query.getEntityId().isEmpty()) {
            wrapper.eq(AuditLog::getEntityId, query.getEntityId());
        }
        if (query.getStartTime() != null && !query.getStartTime().isEmpty()) {
            wrapper.ge(AuditLog::getCreateTime, LocalDateTime.parse(query.getStartTime() + "T00:00:00"));
        }
        if (query.getEndTime() != null && !query.getEndTime().isEmpty()) {
            wrapper.le(AuditLog::getCreateTime, LocalDateTime.parse(query.getEndTime() + "T23:59:59"));
        }

        wrapper.orderByDesc(AuditLog::getCreateTime);

        log.info("查询审计日志, wrapper={}", wrapper);
        
        Page<AuditLog> page = new Page<>(query.getPage(), query.getPageSize());
        IPage<AuditLog> pageResult = auditLogMapper.selectPage(page, wrapper);

        log.info("查询结果: total={}, records={}", pageResult.getTotal(), pageResult.getRecords().size());

        return pageResult.convert(auditLog -> {
            AuditLogDTO dto = new AuditLogDTO();
            BeanUtils.copyProperties(auditLog, dto);
            return dto;
        });
    }

    public List<AuditLogDTO> queryRecentLogs(int limit) {
        LambdaQueryWrapper<AuditLog> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByDesc(AuditLog::getCreateTime);
        wrapper.last("LIMIT " + limit);

        List<AuditLog> logs = auditLogMapper.selectList(wrapper);
        log.info("查询最近{}条日志, 结果数量={}", limit, logs.size());
        
        return logs.stream().map(log -> {
            AuditLogDTO dto = new AuditLogDTO();
            BeanUtils.copyProperties(log, dto);
            return dto;
        }).collect(Collectors.toList());
    }

    public AuditLogDTO getLogById(Long id) {
        AuditLog log = auditLogMapper.selectById(id);
        if (log == null) {
            return null;
        }
        AuditLogDTO dto = new AuditLogDTO();
        BeanUtils.copyProperties(log, dto);
        return dto;
    }

    public long countAllLogs() {
        return auditLogMapper.selectCount(null);
    }

    public long countActiveLogs() {
        LambdaQueryWrapper<AuditLog> wrapper = new LambdaQueryWrapper<>();
        return auditLogMapper.selectCount(wrapper);
    }

    public long deleteAllLogs() {
        long count = auditLogMapper.delete(null);
        log.info("删除所有审计日志, 共删除 {} 条记录", count);
        return count;
    }
}
