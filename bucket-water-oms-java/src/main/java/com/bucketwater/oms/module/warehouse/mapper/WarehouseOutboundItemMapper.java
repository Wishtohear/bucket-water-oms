package com.bucketwater.oms.module.warehouse.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bucketwater.oms.module.warehouse.entity.WarehouseOutboundItem;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;


@Mapper
public interface WarehouseOutboundItemMapper extends BaseMapper<WarehouseOutboundItem> {

    @Select("SELECT * FROM warehouse_outbound_item WHERE outbound_id = #{outboundId}")
    List<WarehouseOutboundItem> findByOutboundId(@Param("outboundId") Long outboundId);
}
