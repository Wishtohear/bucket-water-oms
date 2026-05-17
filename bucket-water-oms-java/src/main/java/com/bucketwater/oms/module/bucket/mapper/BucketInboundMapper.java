package com.bucketwater.oms.module.bucket.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bucketwater.oms.module.bucket.entity.BucketInbound;
import org.apache.ibatis.annotations.Mapper;

/**
 * 空桶入库 Mapper
 */
@Mapper
public interface BucketInboundMapper extends BaseMapper<BucketInbound> {
}
