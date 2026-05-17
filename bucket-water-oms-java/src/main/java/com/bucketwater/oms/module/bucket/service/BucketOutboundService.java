package com.bucketwater.oms.module.bucket.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.bucket.dto.*;
import com.bucketwater.oms.module.bucket.entity.BucketOutbound;
import com.bucketwater.oms.module.bucket.mapper.BucketOutboundMapper;
import com.bucketwater.oms.module.driver.entity.Driver;
import com.bucketwater.oms.module.driver.mapper.DriverMapper;
import com.bucketwater.oms.module.notification.service.NotificationService;
import com.bucketwater.oms.module.product.entity.ProductInventory;
import com.bucketwater.oms.module.product.mapper.ProductInventoryMapper;
import com.bucketwater.oms.module.warehouse.entity.Warehouse;
import com.bucketwater.oms.module.warehouse.mapper.WarehouseMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 空桶出库服务
 */
@Service
public class BucketOutboundService {

    @Autowired
    private BucketOutboundMapper bucketOutboundMapper;

    @Autowired
    private WarehouseMapper warehouseMapper;

    @Autowired
    private DriverMapper driverMapper;

    @Autowired
    private ProductInventoryMapper productInventoryMapper;

    @Autowired
    private NotificationService notificationService;

    /**
     * 获取出库列表
     */
    public List<BucketOutboundDTO> getOutboundList(Long warehouseId, String status, Integer page, Integer size) {
        LambdaQueryWrapper<BucketOutbound> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(BucketOutbound::getWarehouseId, warehouseId);

        if (status != null && !status.isEmpty()) {
            wrapper.eq(BucketOutbound::getStatus, status);
        }

        wrapper.orderByDesc(BucketOutbound::getCreateTime);
        wrapper.last("LIMIT " + size + " OFFSET " + ((page - 1) * size));

        List<BucketOutbound> list = bucketOutboundMapper.selectList(wrapper);
        return list.stream().map(this::convertToDTO).collect(Collectors.toList());
    }

    /**
     * 获取出库单详情
     */
    public BucketOutboundDTO getOutboundDetail(Long outboundId) {
        BucketOutbound outbound = bucketOutboundMapper.selectById(outboundId);
        if (outbound == null) {
            throw new BusinessException(ResultCode.DATA_NOT_FOUND, "出库单不存在");
        }
        return convertToDTO(outbound);
    }

    /**
     * 创建出库单
     */
    @Transactional
    public BucketOutboundDTO createOutbound(CreateBucketOutboundRequest request) {
        // 检查库存
        ProductInventory inventory = productInventoryMapper.selectOne(
            new LambdaQueryWrapper<ProductInventory>()
                .eq(ProductInventory::getWarehouseId, request.getWarehouseId())
                .last("ORDER BY id LIMIT 1")
        );

        if (inventory == null || inventory.getQuantity() < request.getQuantity()) {
            throw new BusinessException(ResultCode.INSUFFICIENT_STOCK, "仓库库存不足");
        }

        BucketOutbound outbound = new BucketOutbound();
        outbound.setOutboundNo(generateOutboundNo());
        outbound.setWarehouseId(request.getWarehouseId());
        outbound.setDriverId(request.getDriverId());
        outbound.setType(request.getType());
        outbound.setBucketType(request.getBucketType());
        outbound.setQuantity(request.getQuantity());
        outbound.setStatus("pending");
        outbound.setDestination(request.getDestination());
        outbound.setRemark(request.getRemark());
        outbound.setCreator(request.getCreator());
        outbound.setCreateTime(LocalDateTime.now());
        outbound.setUpdateTime(LocalDateTime.now());

        bucketOutboundMapper.insert(outbound);

        return convertToDTO(outbound);
    }

    /**
     * 确认出库
     */
    @Transactional
    public BucketOutboundDTO confirmOutbound(Long outboundId, ConfirmBucketOutboundRequest request) {
        BucketOutbound outbound = bucketOutboundMapper.selectById(outboundId);
        if (outbound == null) {
            throw new BusinessException(ResultCode.DATA_NOT_FOUND, "出库单不存在");
        }

        if (!"pending".equals(outbound.getStatus())) {
            throw new BusinessException(ResultCode.ORDER_STATUS_NOT_ALLOWED, "该出库单已处理，无法确认");
        }

        // 再次检查库存
        ProductInventory inventory = productInventoryMapper.selectOne(
            new LambdaQueryWrapper<ProductInventory>()
                .eq(ProductInventory::getWarehouseId, outbound.getWarehouseId())
                .last("ORDER BY id LIMIT 1")
        );

        if (inventory == null || inventory.getQuantity() < outbound.getQuantity()) {
            throw new BusinessException(ResultCode.INSUFFICIENT_STOCK, "仓库库存不足，无法出库");
        }

        outbound.setStatus("confirmed");
        outbound.setConfirmer(request.getConfirmer());
        outbound.setConfirmTime(LocalDateTime.now());
        if (request.getRemark() != null && !request.getRemark().isEmpty()) {
            outbound.setRemark(outbound.getRemark() + " | 确认备注: " + request.getRemark());
        }
        outbound.setUpdateTime(LocalDateTime.now());

        bucketOutboundMapper.updateById(outbound);

        // 更新仓库库存
        if (outbound.getQuantity() > 0) {
            if (inventory != null) {
                inventory.setQuantity(inventory.getQuantity() - outbound.getQuantity());
                inventory.setUpdatedAt(LocalDateTime.now());
                productInventoryMapper.updateById(inventory);
            }
        }

        // 如果是司机领用，通知司机
        if ("driver_pickup".equals(outbound.getType()) && outbound.getDriverId() != null) {
            Driver driver = driverMapper.selectById(outbound.getDriverId());
            if (driver != null) {
                // 通知司机领取空桶
            }
        }

        return convertToDTO(outbound);
    }

    /**
     * 拒绝出库
     */
    @Transactional
    public BucketOutboundDTO rejectOutbound(Long outboundId, String reason, String confirmer) {
        BucketOutbound outbound = bucketOutboundMapper.selectById(outboundId);
        if (outbound == null) {
            throw new BusinessException(ResultCode.DATA_NOT_FOUND, "出库单不存在");
        }

        if (!"pending".equals(outbound.getStatus())) {
            throw new BusinessException(ResultCode.ORDER_STATUS_NOT_ALLOWED, "该出库单已处理，无法拒绝");
        }

        outbound.setStatus("rejected");
        outbound.setConfirmer(confirmer);
        outbound.setConfirmTime(LocalDateTime.now());
        outbound.setRemark(outbound.getRemark() + " | 拒绝原因: " + reason);
        outbound.setUpdateTime(LocalDateTime.now());

        bucketOutboundMapper.updateById(outbound);

        return convertToDTO(outbound);
    }

    private BucketOutboundDTO convertToDTO(BucketOutbound outbound) {
        BucketOutboundDTO dto = new BucketOutboundDTO();
        dto.setId(outbound.getId());
        dto.setOutboundNo(outbound.getOutboundNo());
        dto.setWarehouseId(outbound.getWarehouseId());
        dto.setDriverId(outbound.getDriverId());
        dto.setType(outbound.getType());
        dto.setTypeText(getTypeText(outbound.getType()));
        dto.setBucketType(outbound.getBucketType());
        dto.setQuantity(outbound.getQuantity());
        dto.setStatus(outbound.getStatus());
        dto.setStatusText(getStatusText(outbound.getStatus()));
        dto.setDestination(outbound.getDestination());
        dto.setRemark(outbound.getRemark());
        dto.setCreator(outbound.getCreator());
        dto.setCreateTime(outbound.getCreateTime());
        dto.setConfirmer(outbound.getConfirmer());
        dto.setConfirmTime(outbound.getConfirmTime());

        // 填充仓库名称
        if (outbound.getWarehouseId() != null) {
            Warehouse warehouse = warehouseMapper.selectById(outbound.getWarehouseId());
            if (warehouse != null) {
                dto.setWarehouseName(warehouse.getName());
            }
        }

        // 填充司机信息
        if (outbound.getDriverId() != null) {
            Driver driver = driverMapper.selectById(outbound.getDriverId());
            if (driver != null) {
                dto.setDriverName(driver.getName());
                dto.setDriverPhone(driver.getPhone());
            }
        }

        return dto;
    }

    private String generateOutboundNo() {
        return "OUT" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"))
            + String.format("%04d", (int) (Math.random() * 10000));
    }

    private String getTypeText(String type) {
        if (type == null) return "";
        return switch (type) {
            case "driver_pickup" -> "司机领用";
            case "transfer_out" -> "调拨出库";
            case "damage" -> "损耗出库";
            default -> type;
        };
    }

    private String getStatusText(String status) {
        if (status == null) return "";
        return switch (status) {
            case "pending" -> "待出库";
            case "confirmed" -> "已出库";
            case "rejected" -> "已拒绝";
            default -> status;
        };
    }
}
