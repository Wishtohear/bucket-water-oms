package com.bucketwater.oms.module.bucket.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bucketwater.oms.module.bucket.entity.BucketOutbound;
import org.apache.ibatis.annotations.Mapper;

/**
 * 空桶出库 Mapper
 */
@Mapper
public interface BucketOutboundMapper extends BaseMapper<BucketOutbound> {
}
