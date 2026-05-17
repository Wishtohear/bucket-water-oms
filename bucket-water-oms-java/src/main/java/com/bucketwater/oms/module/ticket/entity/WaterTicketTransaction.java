package com.bucketwater.oms.module.ticket.entity;

import com.baomidou.mybatisplus.annotation.*;
import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@TableName("water_ticket_transaction")
@Schema(description = "水票流水实体")
public class WaterTicketTransaction {

    @TableId(type = IdType.AUTO)
    @Schema(description = "主键ID")
    private Long id;

    @Schema(description = "水票ID")
    private Long ticketId;

    @Schema(description = "订单ID")
    private Long orderId;

    @Schema(description = "使用桶数")
    private Integer usedCount;

    @Schema(description = "扣减金额")
    private BigDecimal deductAmount;

    @Schema(description = "类型: use/refund")
    private String type;

    @TableField(fill = FieldFill.INSERT)
    @Schema(description = "创建时间")
    private LocalDateTime createdAt;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getTicketId() { return ticketId; }
    public void setTicketId(Long ticketId) { this.ticketId = ticketId; }
    public Long getOrderId() { return orderId; }
    public void setOrderId(Long orderId) { this.orderId = orderId; }
    public Integer getUsedCount() { return usedCount; }
    public void setUsedCount(Integer usedCount) { this.usedCount = usedCount; }
    public BigDecimal getDeductAmount() { return deductAmount; }
    public void setDeductAmount(BigDecimal deductAmount) { this.deductAmount = deductAmount; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
