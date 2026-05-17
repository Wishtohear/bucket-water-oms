package com.bucketwater.oms.module.driver.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bucketwater.oms.module.driver.entity.DriverWarehouse;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface DriverWarehouseMapper extends BaseMapper<DriverWarehouse> {

    @Select("SELECT warehouse_id FROM driver_warehouse WHERE driver_id = #{driverId} AND deleted = 0 AND status = 'active'")
    List<Long> selectWarehouseIdsByDriverId(@Param("driverId") Long driverId);

    @Select("SELECT driver_id FROM driver_warehouse WHERE warehouse_id = #{warehouseId} AND deleted = 0 AND status = 'active'")
    List<Long> selectDriverIdsByWarehouseId(@Param("warehouseId") Long warehouseId);

    @Select("SELECT COUNT(*) FROM driver_warehouse WHERE driver_id = #{driverId} AND warehouse_id = #{warehouseId} AND deleted = 0")
    int countByDriverAndWarehouse(@Param("driverId") Long driverId, @Param("warehouseId") Long warehouseId);
}
