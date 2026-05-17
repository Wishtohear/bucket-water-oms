package com.bucketwater.oms.module.ticket.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Schema(description = "水票流水DTO")
public class WaterTicketTransactionDTO {
    private Long id;
    private Long ticketId;
    private String ticketName;
    private Long orderId;
    private Integer usedCount;
    private Integer remainingCount;
    private BigDecimal deductAmount;
    private String type;
    private LocalDateTime createdAt;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getTicketId() { return ticketId; }
    public void setTicketId(Long ticketId) { this.ticketId = ticketId; }
    public String getTicketName() { return ticketName; }
    public void setTicketName(String ticketName) { this.ticketName = ticketName; }
    public Long getOrderId() { return orderId; }
    public void setOrderId(Long orderId) { this.orderId = orderId; }
    public Integer getUsedCount() { return usedCount; }
    public void setUsedCount(Integer usedCount) { this.usedCount = usedCount; }
    public Integer getRemainingCount() { return remainingCount; }
    public void setRemainingCount(Integer remainingCount) { this.remainingCount = remainingCount; }
    public BigDecimal getDeductAmount() { return deductAmount; }
    public void setDeductAmount(BigDecimal deductAmount) { this.deductAmount = deductAmount; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
