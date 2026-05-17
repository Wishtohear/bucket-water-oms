package com.bucketwater.oms.module.inventory.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bucketwater.oms.module.inventory.entity.ProductInventoryTransaction;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface ProductInventoryTransactionMapper extends BaseMapper<ProductInventoryTransaction> {

    @Select("SELECT * FROM product_inventory_transaction WHERE warehouse_id = #{warehouseId} ORDER BY create_time DESC")
    List<ProductInventoryTransaction> findByWarehouseId(@Param("warehouseId") Long warehouseId);

    @Select("SELECT * FROM product_inventory_transaction WHERE warehouse_id = #{warehouseId} AND product_id = #{productId} ORDER BY create_time DESC")
    List<ProductInventoryTransaction> findByWarehouseIdAndProductId(@Param("warehouseId") Long warehouseId, @Param("productId") Long productId);

    @Select("SELECT * FROM product_inventory_transaction WHERE warehouse_id = #{warehouseId} AND transaction_type = #{transactionType} ORDER BY create_time DESC")
    List<ProductInventoryTransaction> findByWarehouseIdAndType(@Param("warehouseId") Long warehouseId, @Param("transactionType") String transactionType);

    @Select("SELECT * FROM product_inventory_transaction WHERE warehouse_id = #{warehouseId} AND related_order_no = #{orderNo} ORDER BY create_time DESC")
    List<ProductInventoryTransaction> findByWarehouseIdAndOrderNo(@Param("warehouseId") Long warehouseId, @Param("orderNo") String orderNo);

    @Select("SELECT SUM(quantity) FROM product_inventory_transaction WHERE warehouse_id = #{warehouseId} AND product_id = #{productId} AND transaction_type = 'INBOUND' AND status = 'completed'")
    Integer sumInboundQuantity(@Param("warehouseId") Long warehouseId, @Param("productId") Long productId);

    @Select("SELECT SUM(quantity) FROM product_inventory_transaction WHERE warehouse_id = #{warehouseId} AND product_id = #{productId} AND transaction_type = 'OUTBOUND' AND status = 'completed'")
    Integer sumOutboundQuantity(@Param("warehouseId") Long warehouseId, @Param("productId") Long productId);
}
