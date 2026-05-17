package com.bucketwater.oms.module.ticket.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bucketwater.oms.module.ticket.entity.WaterTicketTransaction;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface WaterTicketTransactionMapper extends BaseMapper<WaterTicketTransaction> {

    @Select("SELECT * FROM water_ticket_transaction WHERE ticket_id = #{ticketId} ORDER BY created_at DESC")
    List<WaterTicketTransaction> findByTicketId(@Param("ticketId") Long ticketId);

    @Select("SELECT * FROM water_ticket_transaction WHERE order_id = #{orderId} ORDER BY created_at DESC")
    List<WaterTicketTransaction> findByOrderId(@Param("orderId") Long orderId);
}
