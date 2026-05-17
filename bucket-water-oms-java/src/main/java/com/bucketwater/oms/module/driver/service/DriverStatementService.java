package com.bucketwater.oms.module.driver.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.bucketwater.oms.module.driver.dto.DriverStatementDTO;
import com.bucketwater.oms.module.driver.entity.DriverStatement;
import com.bucketwater.oms.module.driver.mapper.DriverStatementMapper;
import com.bucketwater.oms.module.order.entity.Order;
import com.bucketwater.oms.module.order.entity.OrderItem;
import com.bucketwater.oms.module.order.mapper.OrderItemMapper;
import com.bucketwater.oms.module.order.mapper.OrderMapper;
import com.bucketwater.oms.module.station.entity.Station;
import com.bucketwater.oms.module.station.mapper.StationMapper;
import com.bucketwater.oms.module.user.entity.User;
import com.bucketwater.oms.module.user.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class DriverStatementService {

    @Autowired
    private DriverStatementMapper statementMapper;

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private OrderItemMapper orderItemMapper;

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private StationMapper stationMapper;

    private static final DateTimeFormatter STATEMENT_NO_FORMATTER = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

    public List<DriverStatementDTO> getStatements(Long driverId, String status) {
        List<DriverStatement> statements;
        if (status != null && !status.isBlank()) {
            statements = statementMapper.findByDriverIdAndStatus(driverId, status);
        } else {
            statements = statementMapper.findByDriverId(driverId);
        }
        return statements.stream().map(this::convertToDTO).collect(Collectors.toList());
    }

    public DriverStatementDTO getLatestStatement(Long driverId) {
        List<DriverStatement> statements = statementMapper.findByDriverId(driverId);
        if (statements == null || statements.isEmpty()) {
            return null;
        }
        return convertToDTO(statements.get(0));
    }

    public DriverStatementDTO getStatementById(Long statementId) {
        DriverStatement statement = statementMapper.selectById(statementId);
        if (statement == null) {
            return null;
        }
        return convertToDTO(statement);
    }

    public DriverStatementDTO confirmStatement(Long statementId) {
        DriverStatement statement = statementMapper.selectById(statementId);
        if (statement == null) {
            return null;
        }
        statement.setStatus("confirmed");
        statement.setConfirmedAt(LocalDateTime.now());
        statementMapper.updateById(statement);
        return convertToDTO(statement);
    }

    public DriverStatementDTO generateStatement(Long driverId, LocalDate startDate, LocalDate endDate, BigDecimal commissionRate, BigDecimal mileageSubsidyPerKm) {
        List<Order> orders = orderMapper.selectList(
            new QueryWrapper<Order>()
                .eq("driver_id", driverId)
                .eq("status", "completed")
                .ge("delivery_time", startDate.atStartOfDay())
                .le("delivery_time", endDate.atTime(23, 59, 59))
        );

        int totalBuckets = 0;
        BigDecimal totalAmount = BigDecimal.ZERO;
        BigDecimal totalDistance = BigDecimal.ZERO;
        List<DriverStatementDTO.DeliveryRecord> records = new ArrayList<>();

        for (Order order : orders) {
            List<OrderItem> items = orderItemMapper.selectList(
                new QueryWrapper<OrderItem>().eq("order_id", order.getId())
            );

            Station station = stationMapper.selectById(order.getStationId());
            String stationName = station != null ? station.getName() : "未知水站";

            int orderBuckets = items.stream().mapToInt(item -> 
                item.getActualQty() != null ? item.getActualQty() : item.getQuantity()
            ).sum();

            DriverStatementDTO.DeliveryRecord record = new DriverStatementDTO.DeliveryRecord();
            record.setOrderId(order.getId().toString());
            record.setStationName(stationName);
            record.setBuckets(orderBuckets);
            record.setAmount(order.getTotalAmount());
            record.setDeliveryDate(order.getDeliveredAt() != null ? order.getDeliveredAt().toLocalDate() : LocalDate.now());
            records.add(record);

            totalBuckets += orderBuckets;
            totalAmount = totalAmount.add(order.getTotalAmount());
        }

        if (commissionRate == null) {
            commissionRate = new BigDecimal("10.0");
        }
        if (mileageSubsidyPerKm == null) {
            mileageSubsidyPerKm = new BigDecimal("0.5");
        }

        BigDecimal deliveryCommission = totalAmount.multiply(commissionRate).divide(new BigDecimal("100"), 2, java.math.RoundingMode.HALF_UP);
        BigDecimal mileageSubsidy = totalDistance.multiply(mileageSubsidyPerKm);
        BigDecimal actualAmount = deliveryCommission.add(mileageSubsidy);

        DriverStatement statement = new DriverStatement();
        statement.setStatementNo("DST" + LocalDateTime.now().format(STATEMENT_NO_FORMATTER));
        statement.setDriverId(driverId);
        statement.setStartDate(startDate);
        statement.setEndDate(endDate);
        statement.setTotalOrders(orders.size());
        statement.setTotalBuckets(totalBuckets);
        statement.setTotalAmount(totalAmount);
        statement.setCommissionRate(commissionRate);
        statement.setDeliveryCommission(deliveryCommission);
        statement.setTotalDistance(totalDistance);
        statement.setMileageSubsidy(mileageSubsidy);
        statement.setActualAmount(actualAmount);
        statement.setStatus("generated");
        statementMapper.insert(statement);

        return convertToDTO(statement);
    }

    private DriverStatementDTO convertToDTO(DriverStatement statement) {
        DriverStatementDTO dto = new DriverStatementDTO();
        dto.setId(statement.getId());
        dto.setStatementNo(statement.getStatementNo());
        dto.setDriverId(statement.getDriverId());
        dto.setStartDate(statement.getStartDate());
        dto.setEndDate(statement.getEndDate());
        dto.setTotalOrders(statement.getTotalOrders());
        dto.setTotalBuckets(statement.getTotalBuckets());
        dto.setTotalAmount(statement.getTotalAmount());
        dto.setCommissionRate(statement.getCommissionRate());
        dto.setDeliveryCommission(statement.getDeliveryCommission());
        dto.setTotalDistance(statement.getTotalDistance());
        dto.setMileageSubsidy(statement.getMileageSubsidy());
        dto.setActualAmount(statement.getActualAmount());
        dto.setStatus(statement.getStatus());
        dto.setGeneratedAt(statement.getCreatedAt());
        dto.setConfirmedAt(statement.getConfirmedAt());

        User driver = userMapper.selectById(statement.getDriverId());
        if (driver != null) {
            dto.setDriverName(driver.getName());
        }

        if (statement.getStartDate() != null && statement.getEndDate() != null) {
            List<Order> orders = orderMapper.selectList(
                new QueryWrapper<Order>()
                    .eq("driver_id", statement.getDriverId())
                    .eq("status", "completed")
                    .ge("delivery_time", statement.getStartDate().atStartOfDay())
                    .le("delivery_time", statement.getEndDate().atTime(23, 59, 59))
            );

            List<DriverStatementDTO.DeliveryRecord> records = new ArrayList<>();
            for (Order order : orders) {
                List<OrderItem> items = orderItemMapper.selectList(
                    new QueryWrapper<OrderItem>().eq("order_id", order.getId())
                );

                Station station = stationMapper.selectById(order.getStationId());
                String stationName = station != null ? station.getName() : "未知水站";

                DriverStatementDTO.DeliveryRecord record = new DriverStatementDTO.DeliveryRecord();
                record.setOrderId(order.getId().toString());
                record.setStationName(stationName);
                record.setBuckets(items.stream().mapToInt(item -> 
                    item.getActualQty() != null ? item.getActualQty() : item.getQuantity()
                ).sum());
                record.setAmount(order.getTotalAmount());
                record.setDeliveryDate(order.getDeliveredAt() != null ? order.getDeliveredAt().toLocalDate() : LocalDate.now());
                records.add(record);
            }
            dto.setRecords(records);
        }

        return dto;
    }
}
