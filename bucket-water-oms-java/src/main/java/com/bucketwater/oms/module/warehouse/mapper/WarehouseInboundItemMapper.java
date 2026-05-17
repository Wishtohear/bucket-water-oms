package com.bucketwater.oms.module.warehouse.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bucketwater.oms.module.warehouse.entity.WarehouseInboundItem;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;


@Mapper
public interface WarehouseInboundItemMapper extends BaseMapper<WarehouseInboundItem> {

    @Select("SELECT * FROM warehouse_inbound_item WHERE inbound_id = #{inboundId}")
    List<WarehouseInboundItem> findByInboundId(@Param("inboundId") Long inboundId);
}
