package com.bucketwater.oms.module.inventory.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bucketwater.oms.module.inventory.entity.InventoryCheckTaskItem;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface InventoryCheckTaskItemMapper extends BaseMapper<InventoryCheckTaskItem> {

    @Select("SELECT * FROM inventory_check_task_item WHERE task_id = #{taskId} ORDER BY id")
    List<InventoryCheckTaskItem> findByTaskId(@Param("taskId") Long taskId);

    @Select("SELECT * FROM inventory_check_task_item WHERE task_id = #{taskId} AND product_id = #{productId}")
    InventoryCheckTaskItem findByTaskIdAndProductId(@Param("taskId") Long taskId, @Param("productId") Long productId);
}
