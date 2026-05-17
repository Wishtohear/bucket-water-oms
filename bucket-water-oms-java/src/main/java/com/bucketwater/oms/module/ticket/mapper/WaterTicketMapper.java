package com.bucketwater.oms.module.ticket.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bucketwater.oms.module.ticket.entity.WaterTicket;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface WaterTicketMapper extends BaseMapper<WaterTicket> {

    @Select("SELECT * FROM water_ticket WHERE station_id = #{stationId} AND status = 'active' ORDER BY created_at DESC")
    List<WaterTicket> findByStationId(@Param("stationId") Long stationId);

    @Select("SELECT * FROM water_ticket WHERE station_id = #{stationId} AND status = 'active' AND expire_date > NOW() AND (total_count - used_count) > 0")
    List<WaterTicket> findValidTicketsByStationId(@Param("stationId") Long stationId);
}
