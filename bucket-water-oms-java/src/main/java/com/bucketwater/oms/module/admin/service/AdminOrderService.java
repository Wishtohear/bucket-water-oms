package com.bucketwater.oms.module.admin.service;

import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.admin.dto.OrderManagementDTO;
import com.bucketwater.oms.module.order.entity.Order;
import com.bucketwater.oms.module.order.entity.OrderItem;
import com.bucketwater.oms.module.order.mapper.OrderItemMapper;
import com.bucketwater.oms.module.order.mapper.OrderMapper;
import com.bucketwater.oms.module.product.mapper.ProductMapper;
import com.bucketwater.oms.module.station.entity.Station;
import com.bucketwater.oms.module.station.mapper.StationMapper;
import com.bucketwater.oms.module.warehouse.entity.Warehouse;
import com.bucketwater.oms.module.warehouse.mapper.WarehouseMapper;
import com.bucketwater.oms.module.driver.entity.Driver;
import com.bucketwater.oms.module.driver.mapper.DriverMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@Service
public class AdminOrderService {

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private OrderItemMapper orderItemMapper;

    @Autowired
    private StationMapper stationMapper;

    @Autowired
    private WarehouseMapper warehouseMapper;

    @Autowired
    private DriverMapper driverMapper;

    @Autowired
    private ProductMapper productMapper;

    public OrderManagementDTO.OrderPageResult queryOrders(OrderManagementDTO.OrderQueryDTO query) {
        return queryOrders(query, null);
    }

    public OrderManagementDTO.OrderPageResult queryOrders(OrderManagementDTO.OrderQueryDTO query, Long factoryId) {
        LambdaQueryWrapper<Order> wrapper = new LambdaQueryWrapper<>();

        if (query.getKeyword() != null && !query.getKeyword().isEmpty()) {
            wrapper.and(w -> w.like(Order::getOrderNo, query.getKeyword()));
        }

        if (query.getStatus() != null && !query.getStatus().isEmpty()) {
            wrapper.eq(Order::getStatus, convertStatusToDb(query.getStatus()));
        }

        if (query.getWarehouseId() != null) {
            wrapper.eq(Order::getWarehouseId, query.getWarehouseId());
        }

        if (query.getStationId() != null) {
            wrapper.eq(Order::getStationId, query.getStationId());
        }

        if (query.getStartDate() != null && !query.getStartDate().isEmpty()) {
            LocalDate startDate = LocalDate.parse(query.getStartDate());
            wrapper.ge(Order::getCreateTime, startDate.atStartOfDay());
        }

        if (query.getEndDate() != null && !query.getEndDate().isEmpty()) {
            LocalDate endDate = LocalDate.parse(query.getEndDate());
            wrapper.le(Order::getCreateTime, endDate.atTime(LocalTime.MAX));
        }

        if (factoryId != null) {
            wrapper.eq(Order::getFactoryId, factoryId);
        }

        wrapper.orderByDesc(Order::getCreateTime);

        int page = query.getPage() != null ? query.getPage() : 1;
        int size = query.getSize() != null ? query.getSize() : 20;

        Page<Order> pageParam = new Page<>(page, size);
        IPage<Order> pageResult = orderMapper.selectPage(pageParam, wrapper);

        List<OrderManagementDTO> records = new ArrayList<>();
        for (Order order : pageResult.getRecords()) {
            records.add(convertToDTO(order));
        }

        if (query.getKeyword() != null && !query.getKeyword().isEmpty()) {
            final String keyword = query.getKeyword().toLowerCase();
            records = records.stream()
                .filter(r -> {
                    if (r.getStationName() != null && r.getStationName().toLowerCase().contains(keyword)) {
                        return true;
                    }
                    return r.getOrderNo().toLowerCase().contains(keyword);
                })
                .collect(Collectors.toList());
        }

        OrderManagementDTO.OrderPageResult result = new OrderManagementDTO.OrderPageResult();
        result.setRecords(records);
        result.setTotal(pageResult.getTotal());
        result.setPage(page);
        result.setSize(size);
        result.setTotalPages((int) pageResult.getPages());

        return result;
    }

    public OrderManagementDTO getOrderDetail(Long orderId) {
        return getOrderDetail(orderId, null);
    }

    public OrderManagementDTO getOrderDetail(Long orderId, Long factoryId) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            return null;
        }
        if (factoryId != null && !factoryId.equals(order.getFactoryId())) {
            throw new BusinessException(ResultCode.FORBIDDEN, "无权访问该订单");
        }
        return convertToDTO(order);
    }

    public void cancelOrder(Long orderId, String reason) {
        cancelOrder(orderId, reason, null);
    }

    public void cancelOrder(Long orderId, String reason, Long factoryId) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new BusinessException(ResultCode.ORDER_NOT_FOUND);
        }
        if (factoryId != null && !factoryId.equals(order.getFactoryId())) {
            throw new BusinessException(ResultCode.FORBIDDEN, "无权取消该订单");
        }
        if (order != null && "pending_review".equals(order.getStatus())) {
            order.setStatus("cancelled");
            order.setRejectReason(reason);
            order.setUpdateTime(LocalDateTime.now());
            orderMapper.updateById(order);
        }
    }

    public Map<String, Object> getOrderStats() {
        return getOrderStats(null);
    }

    public Map<String, Object> getOrderStats(Long factoryId) {
        Map<String, Object> stats = new java.util.HashMap<>();

        LocalDateTime todayStart = LocalDate.now().atStartOfDay();
        LocalDateTime todayEnd = LocalDate.now().atTime(LocalTime.MAX);

        LambdaQueryWrapper<Order> todayWrapper = new LambdaQueryWrapper<>();
        todayWrapper.ge(Order::getCreateTime, todayStart);
        todayWrapper.le(Order::getCreateTime, todayEnd);
        if (factoryId != null) {
            todayWrapper.eq(Order::getFactoryId, factoryId);
        }
        long todayOrderCount = orderMapper.selectCount(todayWrapper);
        stats.put("todayOrderCount", todayOrderCount);

        LambdaQueryWrapper<Order> pendingReviewWrapper = new LambdaQueryWrapper<>();
        pendingReviewWrapper.eq(Order::getStatus, "pending_review");
        if (factoryId != null) {
            pendingReviewWrapper.eq(Order::getFactoryId, factoryId);
        }
        long pendingReviewCount = orderMapper.selectCount(pendingReviewWrapper);
        stats.put("pendingReviewCount", pendingReviewCount);

        LambdaQueryWrapper<Order> completedWrapper = new LambdaQueryWrapper<>();
        completedWrapper.eq(Order::getStatus, "completed");
        completedWrapper.ge(Order::getDeliveredAt, todayStart);
        completedWrapper.le(Order::getDeliveredAt, todayEnd);
        if (factoryId != null) {
            completedWrapper.eq(Order::getFactoryId, factoryId);
        }
        long todayCompletedCount = orderMapper.selectCount(completedWrapper);
        stats.put("todayCompletedCount", todayCompletedCount);

        LambdaQueryWrapper<Order> deliveringWrapper = new LambdaQueryWrapper<>();
        deliveringWrapper.in(Order::getStatus, "dispatched", "delivering");
        if (factoryId != null) {
            deliveringWrapper.eq(Order::getFactoryId, factoryId);
        }
        long deliveringCount = orderMapper.selectCount(deliveringWrapper);
        stats.put("deliveringCount", deliveringCount);

        return stats;
    }

    private OrderManagementDTO convertToDTO(Order order) {
        OrderManagementDTO dto = new OrderManagementDTO();
        dto.setId(order.getId());
        dto.setOrderNo(order.getOrderNo());
        dto.setStatus(order.getStatus());
        dto.setStatusText(getStatusText(order.getStatus()));
        dto.setTotalAmount(order.getTotalAmount());
        dto.setPaymentType(order.getPaymentType());
        dto.setPaymentTypeText(getPaymentTypeText(order.getPaymentType()));
        dto.setCreateTime(order.getCreateTime());
        dto.setReviewedAt(order.getReviewedAt());
        dto.setDispatchedAt(order.getDispatchedAt());
        dto.setDeliveredAt(order.getDeliveredAt());
        dto.setRejectReason(order.getRejectReason());
        dto.setSignPhotos(order.getSignPhotos());
        dto.setContactName(order.getContactName());
        dto.setContactPhone(order.getContactPhone());
        dto.setDeliveryAddress(order.getDeliveryAddress());
        dto.setRemark(order.getRemark());

        if (order.getStationId() != null) {
            Station station = stationMapper.selectById(order.getStationId());
            if (station != null) {
                dto.setStationId(station.getId());
                dto.setStationName(station.getName());
                dto.setStationAddress(station.getAddress());
            }
        }

        if (order.getWarehouseId() != null) {
            Warehouse warehouse = warehouseMapper.selectById(order.getWarehouseId());
            if (warehouse != null) {
                dto.setWarehouseId(warehouse.getId());
                dto.setWarehouseName(warehouse.getName());
            }
        }

        if (order.getDriverId() != null) {
            Driver driver = driverMapper.selectById(order.getDriverId());
            if (driver != null) {
                dto.setDriverId(driver.getId());
                dto.setDriverName(driver.getName());
            }
        }

        List<OrderItem> items = orderItemMapper.selectList(
            new LambdaQueryWrapper<OrderItem>().eq(OrderItem::getOrderId, order.getId())
        );

        log.info("[DEBUG] 查询订单明细: orderId={}, items.size={}", order.getId(), items.size());

        int totalBuckets = order.getOrderBuckets() != null ? order.getOrderBuckets() : 0;
        int actualBuckets = order.getDeliveredQty() != null ? order.getDeliveredQty() : 0;
        List<OrderManagementDTO.OrderItemDTO> itemDTOs = new ArrayList<>();

        for (OrderItem item : items) {
            OrderManagementDTO.OrderItemDTO itemDTO = new OrderManagementDTO.OrderItemDTO();
            itemDTO.setProductId(item.getProductId());
            itemDTO.setProductName(getProductName(item.getProductId()));
            itemDTO.setQuantity(item.getQuantity());
            itemDTO.setActualQty(item.getActualQty());
            itemDTO.setUnitPrice(item.getUnitPrice());
            itemDTO.setSubtotal(item.getSubtotal());
            itemDTOs.add(itemDTO);

            log.info("[DEBUG] 订单明细: productId={}, quantity={}, actualQty={}", 
                item.getProductId(), item.getQuantity(), item.getActualQty());

            if (totalBuckets == 0 && item.getQuantity() != null) {
                totalBuckets += item.getQuantity();
            }
            if (actualBuckets == 0 && item.getActualQty() != null) {
                actualBuckets += item.getActualQty();
            }
        }

        log.info("[DEBUG] 订单桶数统计: totalBuckets={}, actualBuckets={}", totalBuckets, actualBuckets);

        dto.setItems(itemDTOs);
        dto.setTotalBuckets(totalBuckets);
        dto.setActualBuckets(actualBuckets > 0 ? actualBuckets : totalBuckets);

        return dto;
    }

    private String getProductName(Long productId) {
        if (productId == null) return "未知商品";
        var product = productMapper.selectById(productId);
        return product != null ? product.getName() : "未知商品";
    }

    private String getStatusText(String status) {
        if (status == null) return "";
        return switch (status) {
            case "pending_review" -> "待审查";
            case "reviewed" -> "已接单";
            case "dispatched" -> "已派单";
            case "delivering" -> "配送中";
            case "completed" -> "已完成";
            case "cancelled" -> "已取消";
            case "rejected" -> "已拒单";
            default -> status;
        };
    }

    private String getPaymentTypeText(String paymentType) {
        if (paymentType == null) return "";
        return switch (paymentType) {
            case "prepaid" -> "预存金";
            case "credit" -> "信用额度";
            case "monthly" -> "月结";
            case "quarterly" -> "季结";
            default -> paymentType;
        };
    }

    private String convertStatusToDb(String status) {
        if (status == null) return null;
        return switch (status) {
            case "PENDING_REVIEW" -> "pending_review";
            case "REVIEWED" -> "reviewed";
            case "DISPATCHED" -> "dispatched";
            case "DELIVERING" -> "delivering";
            case "COMPLETED" -> "completed";
            case "CANCELLED" -> "cancelled";
            case "REJECTED" -> "rejected";
            default -> status.toLowerCase();
        };
    }
}
