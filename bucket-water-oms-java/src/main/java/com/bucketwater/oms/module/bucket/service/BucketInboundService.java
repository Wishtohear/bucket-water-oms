package com.bucketwater.oms.module.bucket.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.bucket.dto.*;
import com.bucketwater.oms.module.bucket.entity.BucketInbound;
import com.bucketwater.oms.module.bucket.mapper.BucketInboundMapper;
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
 * 空桶入库服务
 */
@Service
public class BucketInboundService {

    @Autowired
    private BucketInboundMapper bucketInboundMapper;

    @Autowired
    private WarehouseMapper warehouseMapper;

    @Autowired
    private DriverMapper driverMapper;

    @Autowired
    private ProductInventoryMapper productInventoryMapper;

    @Autowired
    private NotificationService notificationService;

    /**
     * 获取入库列表
     */
    public List<BucketInboundDTO> getInboundList(Long warehouseId, String status, Integer page, Integer size) {
        LambdaQueryWrapper<BucketInbound> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(BucketInbound::getWarehouseId, warehouseId);

        if (status != null && !status.isEmpty()) {
            wrapper.eq(BucketInbound::getStatus, status);
        }

        wrapper.orderByDesc(BucketInbound::getCreateTime);
        wrapper.last("LIMIT " + size + " OFFSET " + ((page - 1) * size));

        List<BucketInbound> list = bucketInboundMapper.selectList(wrapper);
        return list.stream().map(this::convertToDTO).collect(Collectors.toList());
    }

    /**
     * 获取入库单详情
     */
    public BucketInboundDTO getInboundDetail(Long inboundId) {
        BucketInbound inbound = bucketInboundMapper.selectById(inboundId);
        if (inbound == null) {
            throw new BusinessException(ResultCode.DATA_NOT_FOUND, "入库单不存在");
        }
        return convertToDTO(inbound);
    }

    /**
     * 创建入库单
     */
    @Transactional
    public BucketInboundDTO createInbound(CreateBucketInboundRequest request) {
        BucketInbound inbound = new BucketInbound();
        inbound.setInboundNo(generateInboundNo());
        inbound.setWarehouseId(request.getWarehouseId());
        inbound.setDriverId(request.getDriverId());
        inbound.setType(request.getType());
        inbound.setBucketType(request.getBucketType());
        inbound.setQuantity(request.getQuantity());
        inbound.setStatus("pending");
        inbound.setSource(request.getSource());
        inbound.setRemark(request.getRemark());
        inbound.setCreator(request.getCreator());
        inbound.setCreateTime(LocalDateTime.now());
        inbound.setUpdateTime(LocalDateTime.now());

        bucketInboundMapper.insert(inbound);

        return convertToDTO(inbound);
    }

    /**
     * 确认入库
     */
    @Transactional
    public BucketInboundDTO confirmInbound(Long inboundId, ConfirmBucketInboundRequest request) {
        BucketInbound inbound = bucketInboundMapper.selectById(inboundId);
        if (inbound == null) {
            throw new BusinessException(ResultCode.DATA_NOT_FOUND, "入库单不存在");
        }

        if (!"pending".equals(inbound.getStatus())) {
            throw new BusinessException(ResultCode.ORDER_STATUS_NOT_ALLOWED, "该入库单已处理，无法确认");
        }

        int reportedQty = inbound.getQuantity();
        int actualQty = request.getActualQuantity();
        int difference = reportedQty - actualQty;

        inbound.setQuantity(actualQty);
        inbound.setStatus(difference == 0 ? "confirmed" : "pending");
        inbound.setChecker(request.getChecker());
        inbound.setCheckTime(LocalDateTime.now());
        if (request.getRemark() != null && !request.getRemark().isEmpty()) {
            inbound.setRemark(inbound.getRemark() + " | 核验备注: " + request.getRemark());
        }
        inbound.setUpdateTime(LocalDateTime.now());

        bucketInboundMapper.updateById(inbound);

        // 更新仓库库存
        if (actualQty > 0) {
            ProductInventory inventory = productInventoryMapper.selectOne(
                new LambdaQueryWrapper<ProductInventory>()
                    .eq(ProductInventory::getWarehouseId, inbound.getWarehouseId())
                    .last("ORDER BY id LIMIT 1")
            );

            if (inventory != null) {
                inventory.setQuantity(inventory.getQuantity() + actualQty);
                inventory.setUpdatedAt(LocalDateTime.now());
                productInventoryMapper.updateById(inventory);
            }
        }

        // 如果入库类型是司机回桶，通知水站
        if ("driver_return".equals(inbound.getType()) && inbound.getDriverId() != null) {
            Driver driver = driverMapper.selectById(inbound.getDriverId());
            if (driver != null) {
                // 通知相关水站（如果有订单关联）
            }
        }

        return convertToDTO(inbound);
    }

    /**
     * 拒绝入库
     */
    @Transactional
    public BucketInboundDTO rejectInbound(Long inboundId, String reason, String checker) {
        BucketInbound inbound = bucketInboundMapper.selectById(inboundId);
        if (inbound == null) {
            throw new BusinessException(ResultCode.DATA_NOT_FOUND, "入库单不存在");
        }

        if (!"pending".equals(inbound.getStatus())) {
            throw new BusinessException(ResultCode.ORDER_STATUS_NOT_ALLOWED, "该入库单已处理，无法拒绝");
        }

        inbound.setStatus("rejected");
        inbound.setChecker(checker);
        inbound.setCheckTime(LocalDateTime.now());
        inbound.setRemark(inbound.getRemark() + " | 拒绝原因: " + reason);
        inbound.setUpdateTime(LocalDateTime.now());

        bucketInboundMapper.updateById(inbound);

        return convertToDTO(inbound);
    }

    private BucketInboundDTO convertToDTO(BucketInbound inbound) {
        BucketInboundDTO dto = new BucketInboundDTO();
        dto.setId(inbound.getId());
        dto.setInboundNo(inbound.getInboundNo());
        dto.setWarehouseId(inbound.getWarehouseId());
        dto.setDriverId(inbound.getDriverId());
        dto.setType(inbound.getType());
        dto.setTypeText(getTypeText(inbound.getType()));
        dto.setBucketType(inbound.getBucketType());
        dto.setQuantity(inbound.getQuantity());
        dto.setStatus(inbound.getStatus());
        dto.setStatusText(getStatusText(inbound.getStatus()));
        dto.setSource(inbound.getSource());
        dto.setRemark(inbound.getRemark());
        dto.setCreator(inbound.getCreator());
        dto.setCreateTime(inbound.getCreateTime());
        dto.setChecker(inbound.getChecker());
        dto.setCheckTime(inbound.getCheckTime());

        // 填充仓库名称
        if (inbound.getWarehouseId() != null) {
            Warehouse warehouse = warehouseMapper.selectById(inbound.getWarehouseId());
            if (warehouse != null) {
                dto.setWarehouseName(warehouse.getName());
            }
        }

        // 填充司机信息
        if (inbound.getDriverId() != null) {
            Driver driver = driverMapper.selectById(inbound.getDriverId());
            if (driver != null) {
                dto.setDriverName(driver.getName());
                dto.setDriverPhone(driver.getPhone());
            }
        }

        return dto;
    }

    private String generateInboundNo() {
        return "IN" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"))
            + String.format("%04d", (int) (Math.random() * 10000));
    }

    private String getTypeText(String type) {
        if (type == null) return "";
        return switch (type) {
            case "driver_return" -> "司机回桶";
            case "clean" -> "清洗入库";
            case "transfer_in" -> "调拨入库";
            default -> type;
        };
    }

    private String getStatusText(String status) {
        if (status == null) return "";
        return switch (status) {
            case "pending" -> "待核验";
            case "confirmed" -> "已入库";
            case "rejected" -> "已拒绝";
            default -> status;
        };
    }
}
