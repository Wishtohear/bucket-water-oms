package com.bucketwater.oms.module.warehouse.service;

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
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class WarehouseOperationLogService {

    private static final Logger log = LoggerFactory.getLogger(WarehouseOperationLogService.class);

    private final AuditLogMapper auditLogMapper;

    public WarehouseOperationLogService(AuditLogMapper auditLogMapper) {
        this.auditLogMapper = auditLogMapper;
    }

    public IPage<AuditLogDTO> queryLogsByWarehouse(String warehouseId, AuditLogQueryDTO query) {
        LambdaQueryWrapper<AuditLog> wrapper = new LambdaQueryWrapper<>();

        if (StringUtils.hasText(warehouseId)) {
            try {
                Long whId = Long.parseLong(warehouseId);
                wrapper.eq(AuditLog::getUserId, whId);
            } catch (NumberFormatException e) {
                log.warn("无效的仓库ID格式: {}", warehouseId);
            }
        }

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

        log.info("查询仓库操作日志, warehouseId={}, wrapper={}", warehouseId, wrapper);

        Page<AuditLog> page = new Page<>(query.getPage(), query.getPageSize());
        IPage<AuditLog> pageResult = auditLogMapper.selectPage(page, wrapper);

        log.info("查询结果: total={}, records={}", pageResult.getTotal(), pageResult.getRecords().size());

        return pageResult.convert(auditLog -> {
            AuditLogDTO dto = new AuditLogDTO();
            BeanUtils.copyProperties(auditLog, dto);
            return dto;
        });
    }

    public List<AuditLogDTO> queryRecentLogsByWarehouse(String warehouseId, int limit) {
        LambdaQueryWrapper<AuditLog> wrapper = new LambdaQueryWrapper<>();

        if (StringUtils.hasText(warehouseId)) {
            try {
                Long whId = Long.parseLong(warehouseId);
                wrapper.eq(AuditLog::getUserId, whId);
            } catch (NumberFormatException e) {
                log.warn("无效的仓库ID格式: {}", warehouseId);
            }
        }

        wrapper.orderByDesc(AuditLog::getCreateTime);
        wrapper.last("LIMIT " + limit);

        List<AuditLog> logs = auditLogMapper.selectList(wrapper);
        log.info("查询仓库最近{}条日志, warehouseId={}, 结果数量={}", limit, warehouseId, logs.size());

        return logs.stream().map(auditLog -> {
            AuditLogDTO dto = new AuditLogDTO();
            BeanUtils.copyProperties(auditLog, dto);
            return dto;
        }).collect(Collectors.toList());
    }

    public AuditLogDTO getLogById(String warehouseId, Long id) {
        AuditLog auditLog = auditLogMapper.selectById(id);

        if (auditLog == null) {
            log.warn("操作日志不存在, id={}", id);
            return null;
        }

        if (StringUtils.hasText(warehouseId)) {
            try {
                Long whId = Long.parseLong(warehouseId);
                if (!whId.equals(auditLog.getUserId())) {
                    log.warn("无权访问该日志, warehouseId={}, logUserId={}", warehouseId, auditLog.getUserId());
                    return null;
                }
            } catch (NumberFormatException e) {
                log.warn("无效的仓库ID格式: {}", warehouseId);
            }
        }

        AuditLogDTO dto = new AuditLogDTO();
        BeanUtils.copyProperties(auditLog, dto);
        return dto;
    }
}
