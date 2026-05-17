package com.bucketwater.oms.module.warehouse.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bucketwater.oms.module.warehouse.entity.WarehouseOutbound;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface WarehouseOutboundMapper extends BaseMapper<WarehouseOutbound> {

    @Select("SELECT * FROM warehouse_outbound WHERE warehouse_id = #{warehouseId} ORDER BY created_at DESC")
    List<WarehouseOutbound> findByWarehouseId(@Param("warehouseId") Long warehouseId);

    @Select("SELECT * FROM warehouse_outbound WHERE warehouse_id = #{warehouseId} AND status = #{status} ORDER BY created_at DESC")
    List<WarehouseOutbound> findByWarehouseIdAndStatus(@Param("warehouseId") Long warehouseId, @Param("status") String status);
}
