package com.bucketwater.oms.module.ticket.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.bucketwater.oms.module.station.entity.Station;
import com.bucketwater.oms.module.station.mapper.StationMapper;
import com.bucketwater.oms.module.ticket.dto.WaterTicketDTO;
import com.bucketwater.oms.module.ticket.dto.WaterTicketTransactionDTO;
import com.bucketwater.oms.module.ticket.entity.WaterTicket;
import com.bucketwater.oms.module.ticket.entity.WaterTicketTransaction;
import com.bucketwater.oms.module.ticket.mapper.WaterTicketMapper;
import com.bucketwater.oms.module.ticket.mapper.WaterTicketTransactionMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import java.util.stream.Collectors;

@Service
public class WaterTicketService {

    @Autowired
    private WaterTicketMapper ticketMapper;

    @Autowired
    private WaterTicketTransactionMapper transactionMapper;

    @Autowired
    private StationMapper stationMapper;

    private static final DateTimeFormatter TICKET_NO_FORMATTER = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

    public List<WaterTicketDTO> getTickets(Long stationId) {
        List<WaterTicket> tickets = ticketMapper.findByStationId(stationId);
        return tickets.stream().map(this::convertToDTO).collect(Collectors.toList());
    }

    public List<WaterTicketDTO> getValidTickets(Long stationId) {
        List<WaterTicket> tickets = ticketMapper.findValidTicketsByStationId(stationId);
        return tickets.stream().map(this::convertToDTO).collect(Collectors.toList());
    }

    public WaterTicketDTO getTicketById(Long ticketId) {
        WaterTicket ticket = ticketMapper.selectById(ticketId);
        if (ticket == null) {
            return null;
        }
        return convertToDTO(ticket);
    }

    public List<WaterTicketTransactionDTO> getTicketTransactions(Long ticketId) {
        List<WaterTicketTransaction> transactions = transactionMapper.findByTicketId(ticketId);
        return transactions.stream().map(this::convertTransactionToDTO).collect(Collectors.toList());
    }

    @Transactional
    public WaterTicketDTO purchaseTicket(Long stationId, Integer count, BigDecimal amount, LocalDateTime expireDate) {
        WaterTicket ticket = new WaterTicket();
        ticket.setTicketNo("SP" + LocalDateTime.now().format(TICKET_NO_FORMATTER));
        ticket.setStationId(stationId);
        ticket.setTotalCount(count);
        ticket.setUsedCount(0);
        ticket.setAmount(amount);
        ticket.setStatus("active");
        ticket.setExpireDate(expireDate);
        ticketMapper.insert(ticket);

        return convertToDTO(ticket);
    }

    public int getTotalRemainingTickets(Long stationId) {
        List<WaterTicket> validTickets = ticketMapper.findValidTicketsByStationId(stationId);
        return validTickets.stream().mapToInt(t -> t.getTotalCount() - t.getUsedCount()).sum();
    }

    public Map<String, Object> getTicketStats(Long stationId) {
        List<WaterTicket> allTickets = ticketMapper.findByStationId(stationId);

        int totalTickets = 0;
        int availableTickets = 0;
        int usedTickets = 0;

        for (WaterTicket ticket : allTickets) {
            totalTickets += ticket.getTotalCount();
            int remaining = ticket.getTotalCount() - ticket.getUsedCount();
            availableTickets += remaining;
            usedTickets += ticket.getUsedCount();
        }

        Map<String, Object> stats = new HashMap<>();
        stats.put("totalTickets", totalTickets);
        stats.put("availableTickets", availableTickets);
        stats.put("usedTickets", usedTickets);
        return stats;
    }

    public List<WaterTicketDTO> getTicketHoldings(Long stationId) {
        List<WaterTicket> tickets = ticketMapper.findByStationId(stationId);
        return tickets.stream().map(this::convertToDTO).collect(Collectors.toList());
    }

    public List<WaterTicketTransactionDTO> getAllTransactions(Long stationId, String filter, String dateRange) {
        List<WaterTicket> tickets = ticketMapper.findByStationId(stationId);
        List<Long> ticketIds = tickets.stream().map(WaterTicket::getId).collect(Collectors.toList());

        if (ticketIds.isEmpty()) {
            return new ArrayList<>();
        }

        QueryWrapper<WaterTicketTransaction> wrapper = new QueryWrapper<>();
        wrapper.in("ticket_id", ticketIds);
        wrapper.orderByDesc("created_at");
        wrapper.last("LIMIT 100");

        List<WaterTicketTransaction> transactions = transactionMapper.selectList(wrapper);

        List<WaterTicketTransactionDTO> result = new ArrayList<>();
        Map<Long, WaterTicket> ticketMap = new HashMap<>();
        for (WaterTicket ticket : tickets) {
            ticketMap.put(ticket.getId(), ticket);
        }

        for (WaterTicketTransaction transaction : transactions) {
            WaterTicketTransactionDTO dto = convertTransactionToDTO(transaction);
            WaterTicket ticket = ticketMap.get(transaction.getTicketId());
            if (ticket != null) {
                dto.setTicketName(ticket.getTicketNo());
                dto.setRemainingCount(ticket.getTotalCount() - ticket.getUsedCount());
            }
            result.add(dto);
        }

        return result;
    }

    public WaterTicketDTO useTicketForOrder(Long stationId, Long orderId, Integer useCount) {
        List<WaterTicket> validTickets = ticketMapper.findValidTicketsByStationId(stationId);
        if (validTickets.isEmpty()) {
            return null;
        }

        WaterTicket ticket = validTickets.get(0);
        int remaining = ticket.getTotalCount() - ticket.getUsedCount();
        if (remaining < useCount) {
            useCount = remaining;
        }

        ticket.setUsedCount(ticket.getUsedCount() + useCount);
        if (ticket.getTotalCount() - ticket.getUsedCount() <= 0) {
            ticket.setStatus("used");
        }
        ticketMapper.updateById(ticket);

        WaterTicketTransaction transaction = new WaterTicketTransaction();
        transaction.setTicketId(ticket.getId());
        transaction.setOrderId(orderId);
        transaction.setUsedCount(useCount);
        transaction.setDeductAmount(BigDecimal.ZERO);
        transaction.setType("deduct");
        transactionMapper.insert(transaction);

        return convertToDTO(ticket);
    }

    private WaterTicketDTO convertToDTO(WaterTicket ticket) {
        WaterTicketDTO dto = new WaterTicketDTO();
        dto.setId(ticket.getId());
        dto.setTicketNo(ticket.getTicketNo());
        dto.setStationId(ticket.getStationId());
        dto.setTotalCount(ticket.getTotalCount());
        dto.setUsedCount(ticket.getUsedCount());
        dto.setRemainingCount(ticket.getTotalCount() - ticket.getUsedCount());
        dto.setAmount(ticket.getAmount());
        dto.setStatus(ticket.getStatus());
        dto.setExpireDate(ticket.getExpireDate());
        dto.setCreatedAt(ticket.getCreatedAt());

        Station station = stationMapper.selectById(ticket.getStationId());
        if (station != null) {
            dto.setStationName(station.getName());
        }

        return dto;
    }

    private WaterTicketTransactionDTO convertTransactionToDTO(WaterTicketTransaction transaction) {
        WaterTicketTransactionDTO dto = new WaterTicketTransactionDTO();
        dto.setId(transaction.getId());
        dto.setTicketId(transaction.getTicketId());
        dto.setOrderId(transaction.getOrderId());
        dto.setUsedCount(transaction.getUsedCount());
        dto.setDeductAmount(transaction.getDeductAmount());
        dto.setType(transaction.getType());
        dto.setCreatedAt(transaction.getCreatedAt());
        return dto;
    }
}
