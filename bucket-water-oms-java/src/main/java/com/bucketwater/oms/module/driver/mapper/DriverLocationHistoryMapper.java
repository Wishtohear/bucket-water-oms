package com.bucketwater.oms.module.driver.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bucketwater.oms.module.driver.entity.DriverLocationHistory;
import org.apache.ibatis.annotations.Mapper;

import java.time.LocalDateTime;
import java.util.List;

@Mapper
public interface DriverLocationHistoryMapper extends BaseMapper<DriverLocationHistory> {

    default List<DriverLocationHistory> findByDriverIdAndTimeRange(
            Long driverId, 
            LocalDateTime startTime, 
            LocalDateTime endTime) {
        return selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<DriverLocationHistory>()
                .eq(DriverLocationHistory::getDriverId, driverId)
                .between(DriverLocationHistory::getRecordTime, startTime, endTime)
                .orderByAsc(DriverLocationHistory::getRecordTime)
        );
    }

    default List<DriverLocationHistory> findByOrderId(String orderId) {
        return selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<DriverLocationHistory>()
                .eq(DriverLocationHistory::getOrderId, orderId)
                .orderByAsc(DriverLocationHistory::getRecordTime)
        );
    }

    default int countByDriverIdAndDate(Long driverId, LocalDateTime startTime, LocalDateTime endTime) {
        return Math.toIntExact(
            selectCount(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<DriverLocationHistory>()
                    .eq(DriverLocationHistory::getDriverId, driverId)
                    .between(DriverLocationHistory::getRecordTime, startTime, endTime)
            )
        );
    }
}
