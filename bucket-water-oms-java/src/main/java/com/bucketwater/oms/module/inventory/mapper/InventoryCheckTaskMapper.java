package com.bucketwater.oms.module.inventory.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bucketwater.oms.module.inventory.entity.InventoryCheckTask;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface InventoryCheckTaskMapper extends BaseMapper<InventoryCheckTask> {

    @Select("SELECT * FROM inventory_check_task WHERE warehouse_id = #{warehouseId} ORDER BY create_time DESC")
    List<InventoryCheckTask> findByWarehouseId(@Param("warehouseId") Long warehouseId);

    @Select("SELECT * FROM inventory_check_task WHERE warehouse_id = #{warehouseId} AND status = #{status} ORDER BY create_time DESC")
    List<InventoryCheckTask> findByWarehouseIdAndStatus(@Param("warehouseId") Long warehouseId, @Param("status") String status);

    @Select("SELECT * FROM inventory_check_task WHERE status = 'in_progress' ORDER BY create_time DESC")
    List<InventoryCheckTask> findInProgressTasks();
}
