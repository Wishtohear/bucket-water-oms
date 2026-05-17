package com.bucketwater.oms.module.statement.service;

import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.order.entity.Order;
import com.bucketwater.oms.module.order.entity.OrderItem;
import com.bucketwater.oms.module.order.mapper.OrderItemMapper;
import com.bucketwater.oms.module.order.mapper.OrderMapper;
import com.bucketwater.oms.module.product.entity.Product;
import com.bucketwater.oms.module.product.mapper.ProductMapper;
import com.bucketwater.oms.module.statement.dto.StatementDTO;
import com.bucketwater.oms.module.statement.entity.MonthlyStatement;
import com.bucketwater.oms.module.statement.mapper.MonthlyStatementMapper;
import com.bucketwater.oms.module.station.entity.Station;
import com.bucketwater.oms.module.station.mapper.StationMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;


@Service
public class StatementService {

    @Autowired
    private MonthlyStatementMapper statementMapper;

    @Autowired
    private StationMapper stationMapper;

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private OrderItemMapper orderItemMapper;

    @Autowired
    private ProductMapper productMapper;

    public List<StatementDTO> getStatements(Long stationId, String yearMonth) {
        com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<MonthlyStatement> wrapper =
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<MonthlyStatement>()
                .eq(MonthlyStatement::getStationId, stationId);

        if (yearMonth != null && !yearMonth.isEmpty()) {
            wrapper.eq(MonthlyStatement::getYearMonth, yearMonth);
        }

        wrapper.orderByDesc(MonthlyStatement::getGeneratedAt);

        List<MonthlyStatement> statements = statementMapper.selectList(wrapper);
        List<StatementDTO> result = new ArrayList<>();

        Station station = stationMapper.selectById(stationId);
        String stationName = station != null ? station.getName() : "";

        for (MonthlyStatement stmt : statements) {
            result.add(convertToDTO(stmt, stationName));
        }

        return result;
    }

    public StatementDTO getStatementDetail(Long statementId) {
        MonthlyStatement statement = statementMapper.selectById(statementId);
        if (statement == null) {
            throw new BusinessException(ResultCode.STATEMENT_NOT_FOUND);
        }

        Station station = stationMapper.selectById(statement.getStationId());
        String stationName = station != null ? station.getName() : "";

        return convertToDTO(statement, stationName);
    }

    @Transactional
    public void confirmStatement(Long statementId) {
        MonthlyStatement statement = statementMapper.selectById(statementId);
        if (statement == null) {
            throw new BusinessException(ResultCode.STATEMENT_NOT_FOUND);
        }

        statement.setStatus("confirmed");
        statement.setConfirmedAt(LocalDateTime.now());
        statementMapper.updateById(statement);
    }

    @Transactional
    public void disputeStatement(Long statementId, String disputeReason) {
        MonthlyStatement statement = statementMapper.selectById(statementId);
        if (statement == null) {
            throw new BusinessException(ResultCode.STATEMENT_NOT_FOUND);
        }

        statement.setStatus("disputed");
        statement.setDisputeReason(disputeReason);
        statement.setDisputedAt(LocalDateTime.now());
        statementMapper.updateById(statement);
    }

    private StatementDTO convertToDTO(MonthlyStatement statement, String stationName) {
        List<Order> orders = orderMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Order>()
                .eq(Order::getStationId, statement.getStationId())
                .ge(Order::getCreateTime, statement.getStartDate().atStartOfDay())
                .le(Order::getCreateTime, statement.getEndDate().atTime(23, 59, 59))
        );

        List<StatementDTO.OrderItem> orderItems = new ArrayList<>();
        for (Order order : orders) {
            List<OrderItem> items = orderItemMapper.selectList(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<OrderItem>()
                    .eq(OrderItem::getOrderId, order.getId())
            );

            StringBuilder itemDesc = new StringBuilder();
            for (OrderItem item : items) {
                if (itemDesc.length() > 0) itemDesc.append(", ");
                String productName = getProductName(item.getProductId());
                itemDesc.append(productName).append("×").append(item.getQuantity());
            }

            orderItems.add(new StatementDTO.OrderItem(
                order.getId().toString(),
                order.getCreateTime() != null ? order.getCreateTime().toLocalDate() : null,
                order.getTotalAmount(),
                itemDesc.toString()
            ));
        }

        return new StatementDTO(
            statement.getId().toString(),
            statement.getStationId().toString(),
            stationName,
            statement.getYearMonth(),
            statement.getStartDate(),
            statement.getEndDate(),
            statement.getOpeningBalance(),
            statement.getTotalAmount(),
            statement.getPaymentReceived(),
            statement.getClosingBalance(),
            statement.getStatus(),
            orderItems,
            statement.getGeneratedAt(),
            statement.getConfirmedAt(),
            statement.getDisputeReason(),
            statement.getDisputedAt(),
            statement.getSettlementAmount()
        );
    }

    private String getProductName(Long productId) {
        if (productId == null) return "未知商品";
        Product product = productMapper.selectById(productId);
        return product != null ? product.getName() : "未知商品";
    }
}
