package com.bucketwater.oms.module.product.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bucketwater.oms.module.product.entity.StationProductPrice;
import org.apache.ibatis.annotations.Mapper;

import java.util.Optional;


@Mapper
public interface StationProductPriceMapper extends BaseMapper<StationProductPrice> {

    default Optional<StationProductPrice> findByStationAndProduct(Long stationId, Long productId) {
        var result = selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StationProductPrice>()
                .eq(StationProductPrice::getStationId, stationId)
                .eq(StationProductPrice::getProductId, productId)
                .eq(StationProductPrice::getIsEnabled, true)
        );
        return Optional.ofNullable(result);
    }
}
