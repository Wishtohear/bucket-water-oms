package com.bucketwater.oms.module.warehouse.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bucketwater.oms.module.warehouse.entity.WarehouseInbound;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface WarehouseInboundMapper extends BaseMapper<WarehouseInbound> {

    @Select("SELECT * FROM warehouse_inbound WHERE warehouse_id = #{warehouseId} AND status = #{status} ORDER BY created_at DESC")
    List<WarehouseInbound> findByWarehouseIdAndStatus(@Param("warehouseId") Long warehouseId, @Param("status") String status);

    @Select("SELECT * FROM warehouse_inbound WHERE warehouse_id = #{warehouseId} ORDER BY created_at DESC")
    List<WarehouseInbound> findByWarehouseId(@Param("warehouseId") Long warehouseId);
}
