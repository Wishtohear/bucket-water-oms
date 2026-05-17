package com.bucketwater.oms.module.driver.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bucketwater.oms.module.driver.entity.DriverStatement;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface DriverStatementMapper extends BaseMapper<DriverStatement> {

    @Select("SELECT * FROM driver_statement WHERE driver_id = #{driverId} ORDER BY created_at DESC")
    List<DriverStatement> findByDriverId(@Param("driverId") Long driverId);

    @Select("SELECT * FROM driver_statement WHERE driver_id = #{driverId} AND status = #{status} ORDER BY created_at DESC")
    List<DriverStatement> findByDriverIdAndStatus(@Param("driverId") Long driverId, @Param("status") String status);
}
