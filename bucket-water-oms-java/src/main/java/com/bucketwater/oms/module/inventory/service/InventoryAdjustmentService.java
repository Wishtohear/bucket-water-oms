package com.bucketwater.oms.module.inventory.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.inventory.dto.InventoryAdjustmentRequest;
import com.bucketwater.oms.module.inventory.dto.InventoryAdjustmentDTO;
import com.bucketwater.oms.module.inventory.dto.InventoryApprovalDTO;
import com.bucketwater.oms.module.inventory.entity.InventoryAdjustment;
import com.bucketwater.oms.module.inventory.entity.ProductInventoryTransaction;
import com.bucketwater.oms.module.inventory.mapper.InventoryAdjustmentMapper;
import com.bucketwater.oms.module.inventory.mapper.ProductInventoryTransactionMapper;
import com.bucketwater.oms.module.product.entity.Product;
import com.bucketwater.oms.module.product.entity.ProductInventory;
import com.bucketwater.oms.module.product.mapper.ProductInventoryMapper;
import com.bucketwater.oms.module.product.mapper.ProductMapper;
import com.bucketwater.oms.module.warehouse.entity.Warehouse;
import com.bucketwater.oms.module.warehouse.mapper.WarehouseMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class InventoryAdjustmentService {

    private static final Logger log = LoggerFactory.getLogger(InventoryAdjustmentService.class);
    private static final DateTimeFormatter ADJUSTMENT_NO_FORMATTER = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

    @Autowired
    private InventoryAdjustmentMapper adjustmentMapper;

    @Autowired
    private ProductInventoryMapper inventoryMapper;

    @Autowired
    private ProductInventoryTransactionMapper transactionMapper;

    @Autowired
    private ProductMapper productMapper;

    @Autowired
    private WarehouseMapper warehouseMapper;

    public Page<InventoryAdjustmentDTO> queryAdjustments(Long warehouseId, String status, Integer page, Integer size) {
        Page<InventoryAdjustment> pageParam = new Page<>(page, size);

        LambdaQueryWrapper<InventoryAdjustment> wrapper = new LambdaQueryWrapper<InventoryAdjustment>()
                .eq(warehouseId != null, InventoryAdjustment::getWarehouseId, warehouseId)
                .eq(status != null && !status.isEmpty(), InventoryAdjustment::getStatus, status)
                .orderByDesc(InventoryAdjustment::getCreateTime);

        Page<InventoryAdjustment> pageResult = adjustmentMapper.selectPage(pageParam, wrapper);
        Page<InventoryAdjustmentDTO> dtoPage = new Page<>(pageResult.getCurrent(), pageResult.getSize(), pageResult.getTotal());

        List<InventoryAdjustmentDTO> records = pageResult.getRecords().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());

        dtoPage.setRecords(records);
        return dtoPage;
    }

    public InventoryAdjustmentDTO getAdjustmentById(Long adjustmentId) {
        InventoryAdjustment adjustment = adjustmentMapper.selectById(adjustmentId);
        if (adjustment == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "库存调整单不存在");
        }
        return convertToDTO(adjustment);
    }

    @Transactional
    public InventoryAdjustmentDTO createAdjustment(Long warehouseId, String applicant, InventoryAdjustmentRequest request) {
        Warehouse warehouse = warehouseMapper.selectById(warehouseId);
        if (warehouse == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "仓库不存在");
        }

        String adjustmentNo = generateAdjustmentNo();

        InventoryAdjustment adjustment = new InventoryAdjustment();
        adjustment.setAdjustmentNo(adjustmentNo);
        adjustment.setWarehouseId(warehouseId);
        adjustment.setWarehouseName(warehouse.getName());
        adjustment.setAdjustmentType(request.getAdjustmentType());
        adjustment.setReason(request.getReason());
        adjustment.setApplicant(applicant);
        adjustment.setApplyTime(LocalDateTime.now());
        adjustment.setStatus("pending");
        adjustment.setCreateTime(LocalDateTime.now());
        adjustment.setUpdateTime(LocalDateTime.now());

        adjustmentMapper.insert(adjustment);
        log.info("创建库存调整单成功，ID:{}, 单号:{}", adjustment.getId(), adjustmentNo);

        return convertToDTO(adjustment);
    }

    @Transactional
    public InventoryAdjustmentDTO approveAdjustment(Long adjustmentId, String approver, String remark) {
        InventoryAdjustment adjustment = adjustmentMapper.selectById(adjustmentId);
        if (adjustment == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "库存调整单不存在");
        }

        if (!"pending".equals(adjustment.getStatus())) {
            throw new BusinessException(ResultCode.PARAM_ERROR, "只能审批待审批的调整单");
        }

        adjustment.setStatus("approved");
        adjustment.setApprover(approver);
        adjustment.setApproveTime(LocalDateTime.now());
        adjustment.setApproveRemark(remark);
        adjustment.setUpdateTime(LocalDateTime.now());
        adjustmentMapper.updateById(adjustment);

        log.info("审批库存调整单成功，ID:{}, 审批人:{}", adjustmentId, approver);

        return convertToDTO(adjustment);
    }

    @Transactional
    public InventoryAdjustmentDTO rejectAdjustment(Long adjustmentId, String approver, String remark) {
        InventoryAdjustment adjustment = adjustmentMapper.selectById(adjustmentId);
        if (adjustment == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "库存调整单不存在");
        }

        if (!"pending".equals(adjustment.getStatus())) {
            throw new BusinessException(ResultCode.PARAM_ERROR, "只能拒绝待审批的调整单");
        }

        adjustment.setStatus("rejected");
        adjustment.setApprover(approver);
        adjustment.setApproveTime(LocalDateTime.now());
        adjustment.setApproveRemark(remark);
        adjustment.setUpdateTime(LocalDateTime.now());
        adjustmentMapper.updateById(adjustment);

        log.info("拒绝库存调整单，ID:{}, 审批人:{}", adjustmentId, approver);

        return convertToDTO(adjustment);
    }

    private String generateAdjustmentNo() {
        return "IA" + LocalDateTime.now().format(ADJUSTMENT_NO_FORMATTER);
    }

    private InventoryAdjustmentDTO convertToDTO(InventoryAdjustment adjustment) {
        InventoryAdjustmentDTO dto = new InventoryAdjustmentDTO();
        dto.setId(adjustment.getId());
        dto.setAdjustmentNo(adjustment.getAdjustmentNo());
        dto.setWarehouseId(adjustment.getWarehouseId());
        dto.setWarehouseName(adjustment.getWarehouseName());
        dto.setAdjustmentType(adjustment.getAdjustmentType());
        dto.setReason(adjustment.getReason());
        dto.setApplicant(adjustment.getApplicant());
        dto.setApplyTime(adjustment.getApplyTime());
        dto.setStatus(adjustment.getStatus());
        dto.setStatusText(getStatusText(adjustment.getStatus()));
        dto.setApprover(adjustment.getApprover());
        dto.setApproveTime(adjustment.getApproveTime());
        dto.setApproveRemark(adjustment.getApproveRemark());
        dto.setCreateTime(adjustment.getCreateTime());
        return dto;
    }

    private String getStatusText(String status) {
        if (status == null) {
            return "";
        }
        return switch (status) {
            case "pending" -> "待审批";
            case "approved" -> "已审批";
            case "rejected" -> "已拒绝";
            default -> status;
        };
    }
}
