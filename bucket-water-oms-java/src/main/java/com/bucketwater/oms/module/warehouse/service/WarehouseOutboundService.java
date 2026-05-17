package com.bucketwater.oms.module.warehouse.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.bucketwater.oms.module.order.entity.Order;
import com.bucketwater.oms.module.order.entity.OrderItem;
import com.bucketwater.oms.module.order.mapper.OrderItemMapper;
import com.bucketwater.oms.module.order.mapper.OrderMapper;
import com.bucketwater.oms.module.product.entity.Product;
import com.bucketwater.oms.module.product.mapper.ProductMapper;
import com.bucketwater.oms.module.station.entity.Station;
import com.bucketwater.oms.module.station.mapper.StationMapper;
import com.bucketwater.oms.module.user.entity.User;
import com.bucketwater.oms.module.user.mapper.UserMapper;
import com.bucketwater.oms.module.warehouse.dto.WarehouseOutboundDTO;
import com.bucketwater.oms.module.warehouse.entity.WarehouseOutbound;
import com.bucketwater.oms.module.warehouse.entity.WarehouseOutboundItem;
import com.bucketwater.oms.module.warehouse.mapper.WarehouseOutboundItemMapper;
import com.bucketwater.oms.module.warehouse.mapper.WarehouseOutboundMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class WarehouseOutboundService {

    @Autowired
    private WarehouseOutboundMapper outboundMapper;

    @Autowired
    private WarehouseOutboundItemMapper outboundItemMapper;

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private OrderItemMapper orderItemMapper;

    @Autowired
    private ProductMapper productMapper;

    @Autowired
    private StationMapper stationMapper;

    @Autowired
    private UserMapper userMapper;

    private static final DateTimeFormatter OUTBOUND_NO_FORMATTER = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

    public List<WarehouseOutboundDTO> getOutboundList(Long warehouseId, String status) {
        List<WarehouseOutbound> outbounds;
        if (status != null && !status.isBlank()) {
            outbounds = outboundMapper.findByWarehouseIdAndStatus(warehouseId, status);
        } else {
            outbounds = outboundMapper.findByWarehouseId(warehouseId);
        }
        return outbounds.stream().map(this::convertToDTO).collect(Collectors.toList());
    }

    public WarehouseOutboundDTO getOutboundById(Long outboundId) {
        WarehouseOutbound outbound = outboundMapper.selectById(outboundId);
        if (outbound == null) {
            return null;
        }
        return convertToDTO(outbound);
    }

    @Transactional
    public WarehouseOutboundDTO createOutboundForOrder(Long warehouseId, Long orderId, String operator) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            return null;
        }

        WarehouseOutbound outbound = new WarehouseOutbound();
        outbound.setOutboundNo("CK" + LocalDateTime.now().format(OUTBOUND_NO_FORMATTER));
        outbound.setWarehouseId(warehouseId);
        outbound.setType("order");
        outbound.setStatus("pending");
        outbound.setOrderId(orderId);
        outbound.setOperator(operator);
        outboundMapper.insert(outbound);

        List<OrderItem> orderItems = orderItemMapper.selectList(
            new QueryWrapper<OrderItem>().eq("order_id", orderId)
        );
        for (OrderItem orderItem : orderItems) {
            WarehouseOutboundItem item = new WarehouseOutboundItem();
            item.setOutboundId(outbound.getId());
            item.setProductId(orderItem.getProductId());
            item.setQuantity(orderItem.getActualQty() != null ? orderItem.getActualQty() : orderItem.getQuantity());
            outboundItemMapper.insert(item);
        }

        return convertToDTO(outbound);
    }

    @Transactional
    public WarehouseOutboundDTO confirmOutbound(Long outboundId) {
        WarehouseOutbound outbound = outboundMapper.selectById(outboundId);
        if (outbound == null) {
            return null;
        }

        outbound.setStatus("completed");
        outboundMapper.updateById(outbound);

        return convertToDTO(outbound);
    }

    private WarehouseOutboundDTO convertToDTO(WarehouseOutbound outbound) {
        WarehouseOutboundDTO dto = new WarehouseOutboundDTO();
        dto.setId(outbound.getId());
        dto.setOutboundNo(outbound.getOutboundNo());
        dto.setType(outbound.getType());
        dto.setStatus(outbound.getStatus());
        dto.setOperator(outbound.getOperator());
        dto.setCreatedAt(outbound.getCreatedAt());

        if (outbound.getOrderId() != null) {
            dto.setOrderId(outbound.getOrderId().toString());
            Order order = orderMapper.selectById(outbound.getOrderId());
            if (order != null) {
                Station station = stationMapper.selectById(order.getStationId());
                if (station != null) {
                    dto.setStationName(station.getName());
                }
                User driver = userMapper.selectById(order.getDriverId());
                if (driver != null) {
                    dto.setDriverName(driver.getName());
                }
            }
        }

        List<WarehouseOutboundItem> items = outboundItemMapper.findByOutboundId(outbound.getId());
        dto.setItems(items.stream().map(item -> {
            WarehouseOutboundDTO.OutboundItemDTO itemDTO = new WarehouseOutboundDTO.OutboundItemDTO();
            itemDTO.setProductId(item.getProductId());
            itemDTO.setQuantity(item.getQuantity());

            Product product = productMapper.selectById(item.getProductId());
            if (product != null) {
                itemDTO.setProductName(product.getName());
            }

            return itemDTO;
        }).collect(Collectors.toList()));

        return dto;
    }
}
