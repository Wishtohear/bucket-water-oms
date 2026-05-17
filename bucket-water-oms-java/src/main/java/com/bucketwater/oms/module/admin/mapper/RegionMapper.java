package com.bucketwater.oms.module.admin.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bucketwater.oms.module.admin.entity.Region;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Delete;

import java.util.List;

@Mapper
public interface RegionMapper extends BaseMapper<Region> {
    List<Region> selectByParentCode(@Param("parentCode") String parentCode);
    List<Region> selectByLevel(@Param("level") Integer level);
    List<Region> selectByStatus(@Param("status") String status);

    /**
     * 根据编码查询记录（包括已删除的记录）
     * 用于检查唯一约束冲突
     */
    @Select("SELECT * FROM region WHERE code = #{code}")
    Region selectByCodeIncludingDeleted(@Param("code") String code);

    /**
     * 物理删除指定ID的记录（包括已删除的记录）
     * 不使用逻辑删除，直接从数据库删除
     */
    @Delete("DELETE FROM region WHERE id = #{id}")
    int physicalDeleteById(@Param("id") String id);
}
