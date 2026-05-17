package com.bucketwater.oms.module.warehouse.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.bucketwater.oms.module.product.entity.Product;
import com.bucketwater.oms.module.product.entity.ProductInventory;
import com.bucketwater.oms.module.product.mapper.ProductInventoryMapper;
import com.bucketwater.oms.module.product.mapper.ProductMapper;
import com.bucketwater.oms.module.warehouse.dto.CheckInboundRequest;
import com.bucketwater.oms.module.warehouse.dto.CreateInboundRequest;
import com.bucketwater.oms.module.warehouse.dto.WarehouseInboundDTO;
import com.bucketwater.oms.module.warehouse.entity.WarehouseInbound;
import com.bucketwater.oms.module.warehouse.entity.WarehouseInboundItem;
import com.bucketwater.oms.module.warehouse.mapper.WarehouseInboundItemMapper;
import com.bucketwater.oms.module.warehouse.mapper.WarehouseInboundMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

import java.util.stream.Collectors;

@Service
public class WarehouseInboundService {

    @Autowired
    private WarehouseInboundMapper inboundMapper;

    @Autowired
    private WarehouseInboundItemMapper inboundItemMapper;

    @Autowired
    private ProductMapper productMapper;

    @Autowired
    private ProductInventoryMapper inventoryMapper;

    private static final DateTimeFormatter INBOUND_NO_FORMATTER = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

    public List<WarehouseInboundDTO> getInboundList(Long warehouseId, String status) {
        List<WarehouseInbound> inbounds;
        if (status != null && !status.isBlank()) {
            inbounds = inboundMapper.findByWarehouseIdAndStatus(warehouseId, status);
        } else {
            inbounds = inboundMapper.findByWarehouseId(warehouseId);
        }
        return inbounds.stream().map(this::convertToDTO).collect(Collectors.toList());
    }

    public WarehouseInboundDTO getInboundById(Long inboundId) {
        WarehouseInbound inbound = inboundMapper.selectById(inboundId);
        if (inbound == null) {
            return null;
        }
        return convertToDTO(inbound);
    }

    @Transactional
    public WarehouseInboundDTO createInbound(Long warehouseId, String operator, CreateInboundRequest request) {
        WarehouseInbound inbound = new WarehouseInbound();
        inbound.setInboundNo("RK" + LocalDateTime.now().format(INBOUND_NO_FORMATTER));
        inbound.setWarehouseId(warehouseId);
        inbound.setType(request.getType());
        inbound.setStatus("pending_check");
        inbound.setOperator(operator);
        inbound.setRemark(request.getRemark());
        inboundMapper.insert(inbound);

        if (request.getItems() != null) {
            for (CreateInboundRequest.InboundItem item : request.getItems()) {
                WarehouseInboundItem itemEntity = new WarehouseInboundItem();
                itemEntity.setInboundId(inbound.getId());
                itemEntity.setProductId(item.getProductId());
                itemEntity.setQuantity(item.getQuantity());
                itemEntity.setRemark(item.getRemark());
                inboundItemMapper.insert(itemEntity);
            }
        }

        return convertToDTO(inbound);
    }

    @Transactional
    public WarehouseInboundDTO checkInbound(Long inboundId, CheckInboundRequest request) {
        WarehouseInbound inbound = inboundMapper.selectById(inboundId);
        if (inbound == null) {
            return null;
        }

        if ("approve".equals(request.getAction())) {
            inbound.setStatus("approved");
            inbound.setChecker(request.getCheckedBy());
            inbound.setCheckedAt(LocalDateTime.now());

            List<WarehouseInboundItem> items = inboundItemMapper.findByInboundId(inboundId);
            for (WarehouseInboundItem item : items) {
                ProductInventory inventory = inventoryMapper.selectOne(
                    new QueryWrapper<ProductInventory>()
                        .eq("warehouse_id", inbound.getWarehouseId())
                        .eq("product_id", item.getProductId())
                );
                if (inventory != null) {
                    inventory.setQuantity(inventory.getQuantity() + item.getQuantity());
                    inventoryMapper.updateById(inventory);
                } else {
                    inventory = new ProductInventory();
                    inventory.setWarehouseId(inbound.getWarehouseId());
                    inventory.setProductId(item.getProductId());
                    inventory.setQuantity(item.getQuantity());
                    inventoryMapper.insert(inventory);
                }
            }
        } else if ("reject".equals(request.getAction())) {
            inbound.setStatus("rejected");
            inbound.setChecker(request.getCheckedBy());
            inbound.setCheckedAt(LocalDateTime.now());
        }

        inboundMapper.updateById(inbound);
        return convertToDTO(inbound);
    }

    private WarehouseInboundDTO convertToDTO(WarehouseInbound inbound) {
        WarehouseInboundDTO dto = new WarehouseInboundDTO();
        dto.setId(inbound.getId());
        dto.setInboundNo(inbound.getInboundNo());
        dto.setType(inbound.getType());
        dto.setStatus(inbound.getStatus());
        dto.setOperator(inbound.getOperator());
        dto.setCreatedAt(inbound.getCreatedAt());
        dto.setCheckedAt(inbound.getCheckedAt());
        dto.setChecker(inbound.getChecker());

        List<WarehouseInboundItem> items = inboundItemMapper.findByInboundId(inbound.getId());
        dto.setItems(items.stream().map(item -> {
            WarehouseInboundDTO.InboundItemDTO itemDTO = new WarehouseInboundDTO.InboundItemDTO();
            itemDTO.setProductId(item.getProductId());
            itemDTO.setQuantity(item.getQuantity());
            itemDTO.setRemark(item.getRemark());

            Product product = productMapper.selectById(item.getProductId());
            if (product != null) {
                itemDTO.setProductName(product.getName());
            }

            return itemDTO;
        }).collect(Collectors.toList()));

        return dto;
    }
}
