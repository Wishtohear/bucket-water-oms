package com.bucketwater.oms.module.statement.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bucketwater.oms.module.statement.entity.MonthlyStatement;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface MonthlyStatementMapper extends BaseMapper<MonthlyStatement> {
}
