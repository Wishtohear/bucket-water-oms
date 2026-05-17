package com.bucketwater.oms.module.order.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bucketwater.oms.module.order.entity.Order;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.time.LocalDateTime;
import java.util.List;

@Mapper
public interface OrderMapper extends BaseMapper<Order> {

    @Select("SELECT * FROM orders WHERE status = 'pending_review' AND create_time < #{timeoutTime}")
    List<Order> selectPendingReviewOrders(@Param("timeoutTime") LocalDateTime timeoutTime);
}
