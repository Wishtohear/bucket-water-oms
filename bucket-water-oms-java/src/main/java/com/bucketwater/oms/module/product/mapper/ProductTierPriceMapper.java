package com.bucketwater.oms.module.product.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bucketwater.oms.module.product.entity.ProductTierPrice;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;
import java.util.Optional;


@Mapper
public interface ProductTierPriceMapper extends BaseMapper<ProductTierPrice> {

    default Optional<ProductTierPrice> findTierPrice(Long stationId, Long productId, int quantity) {
        var wrapper = new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<ProductTierPrice>()
                .eq(ProductTierPrice::getStationId, stationId)
                .eq(ProductTierPrice::getProductId, productId)
                .eq(ProductTierPrice::getIsEnabled, true)
                .le(ProductTierPrice::getMinQuantity, quantity)
                .and(w -> w
                    .isNull(ProductTierPrice::getMaxQuantity)
                    .or()
                    .gt(ProductTierPrice::getMaxQuantity, quantity)
                )
                .orderByDesc(ProductTierPrice::getMinQuantity)
                .last("LIMIT 1");
        var result = selectOne(wrapper);
        return Optional.ofNullable(result);
    }

    default List<ProductTierPrice> findAllTiers(Long stationId, Long productId) {
        return selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<ProductTierPrice>()
                .eq(ProductTierPrice::getStationId, stationId)
                .eq(ProductTierPrice::getProductId, productId)
                .eq(ProductTierPrice::getIsEnabled, true)
                .orderByAsc(ProductTierPrice::getMinQuantity)
        );
    }
}
