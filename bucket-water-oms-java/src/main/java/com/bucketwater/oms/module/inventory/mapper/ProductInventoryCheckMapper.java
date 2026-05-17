package com.bucketwater.oms.module.inventory.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bucketwater.oms.module.inventory.entity.ProductInventoryCheck;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface ProductInventoryCheckMapper extends BaseMapper<ProductInventoryCheck> {

    @Select("SELECT * FROM product_inventory_check WHERE warehouse_id = #{warehouseId} ORDER BY create_time DESC")
    List<ProductInventoryCheck> findByWarehouseId(@Param("warehouseId") Long warehouseId);

    @Select("SELECT * FROM product_inventory_check WHERE warehouse_id = #{warehouseId} AND product_id = #{productId} ORDER BY create_time DESC")
    List<ProductInventoryCheck> findByWarehouseIdAndProductId(@Param("warehouseId") Long warehouseId, @Param("productId") Long productId);

    @Select("SELECT * FROM product_inventory_check WHERE warehouse_id = #{warehouseId} AND status = #{status} ORDER BY create_time DESC")
    List<ProductInventoryCheck> findByWarehouseIdAndStatus(@Param("warehouseId") Long warehouseId, @Param("status") String status);
}
