# 地域管理API开发指南

本文档描述了水厂订货管理系统中地域管理模块的后端开发规范和实现指南。

## 1. 数据库表结构

### 1.1 表创建SQL

```sql
-- 地域区域表
CREATE TABLE region (
    id VARCHAR(36) PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE COMMENT '区域编码',
    name VARCHAR(100) NOT NULL COMMENT '区域名称',
    parent_code VARCHAR(50) DEFAULT NULL COMMENT '上级区域编码',
    level INT NOT NULL COMMENT '层级: 1-省/直辖市, 2-市/区, 3-县/街道',
    sort INT DEFAULT 0 COMMENT '排序值',
    status VARCHAR(20) DEFAULT 'active' COMMENT '状态: active-启用, inactive-停用',
    remark VARCHAR(500) DEFAULT NULL COMMENT '备注',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_parent_code (parent_code),
    INDEX idx_status (status),
    INDEX idx_level (level)
) COMMENT='地域区域表';
```

### 1.2 初始化示例数据

```sql
-- 插入浙江省及下属城市和区县
INSERT INTO region (id, code, name, parent_code, level, sort, status) VALUES
('550e8400-e29b-41d4-a716-446655440001', '330000', '浙江省', NULL, 1, 1, 'active'),
('550e8400-e29b-41d4-a716-446655440002', '330100', '杭州市', '330000', 2, 1, 'active'),
('550e8400-e29b-41d4-a716-446655440003', '330105', '拱墅区', '330100', 3, 1, 'active'),
('550e8400-e29b-41d4-a716-446655440004', '330106', '西湖区', '330100', 3, 2, 'active'),
('550e8400-e29b-41d4-a716-446655440005', '330108', '滨江区', '330100', 3, 3, 'active'),
('550e8400-e29b-41d4-a716-446655440006', '330109', '萧山区', '330100', 3, 4, 'active'),
('550e8400-e29b-41d4-a716-446655440007', '330110', '余杭区', '330100', 3, 5, 'active'),
('550e8400-e29b-41d4-a716-446655440008', '330111', '临安区', '330100', 3, 6, 'active'),
('550e8400-e29b-41d4-a716-446655440009', '330200', '宁波市', '330000', 2, 2, 'active'),
('550e8400-e29b-41d4-a716-446655440010', '330203', '海曙区', '330200', 3, 1, 'active'),
('550e8400-e29b-41d4-a716-446655440011', '330206', '北仑区', '330200', 3, 2, 'active'),
('550e8400-e29b-41d4-a716-446655440012', '330300', '温州市', '330000', 2, 3, 'active'),
('550e8400-e29b-41d4-a716-446655440013', '330302', '鹿城区', '330300', 3, 1, 'active'),
('550e8400-e29b-41d4-a716-446655440014', '310000', '上海市', NULL, 1, 2, 'active'),
('550e8400-e29b-41d4-a716-446655440015', '310100', '黄浦区', '310000', 2, 1, 'active'),
('550e8400-e29b-41d4-a716-446655440016', '310110', '杨浦区', '310000', 2, 2, 'active');
```

## 2. Java实体类

### 2.1 Entity类

```java
package com.bucketwater.oms.module.admin.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("region")
public class Region {
    
    @TableId(type = IdType.ASSIGN_UUID)
    private String id;
    
    private String code;
    
    private String name;
    
    private String parentCode;
    
    private Integer level;
    
    private Integer sort;
    
    private String status;
    
    private String remark;
    
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
    
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}
```

### 2.2 DTO类

```java
package com.bucketwater.oms.module.admin.dto;

import lombok.Data;
import java.util.List;

@Data
public class RegionDTO {
    private String id;
    private String code;
    private String name;
    private String parentCode;
    private Integer level;
    private Integer sort;
    private String status;
    private String remark;
    private List<RegionDTO> children;
}

@Data
class CreateRegionRequest {
    private String code;
    private String name;
    private String parentCode;
    private Integer sort;
    private String remark;
}

@Data
class UpdateRegionRequest {
    private String code;
    private String name;
    private String parentCode;
    private Integer sort;
    private String remark;
}
```

### 2.3 Mapper接口

```java
package com.bucketwater.oms.module.admin.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bucketwater.oms.module.admin.entity.Region;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface RegionMapper extends BaseMapper<Region> {
    List<Region> selectByParentCode(String parentCode);
    List<Region> selectByLevel(Integer level);
    List<Region> selectByStatus(String status);
}
```

### 2.4 Mapper XML

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.bucketwater.oms.module.admin.mapper.RegionMapper">

    <select id="selectByParentCode" resultType="Region">
        SELECT * FROM region 
        WHERE parent_code = #{parentCode} 
        ORDER BY sort ASC, code ASC
    </select>

    <select id="selectByLevel" resultType="Region">
        SELECT * FROM region 
        WHERE level = #{level} 
        ORDER BY sort ASC, code ASC
    </select>

    <select id="selectByStatus" resultType="Region">
        SELECT * FROM region 
        WHERE status = #{status} 
        ORDER BY sort ASC, code ASC
    </select>

</mapper>
```

## 3. Service层业务逻辑

### 3.1 Service接口

```java
package com.bucketwater.oms.module.admin.service;

import com.bucketwater.oms.module.admin.dto.RegionDTO;
import java.util.List;

public interface AdminRegionService {
    
    List<RegionDTO> getAllRegions(String status, Integer level);
    
    List<RegionDTO> getRegionTree();
    
    RegionDTO getRegionById(String id);
    
    RegionDTO getRegionByCode(String code);
    
    List<RegionDTO> getChildren(String parentCode);
    
    List<RegionDTO> getProvinces();
    
    List<RegionDTO> getCities(String provinceCode);
    
    List<RegionDTO> getDistricts(String cityCode);
    
    RegionDTO createRegion(CreateRegionRequest request);
    
    RegionDTO updateRegion(String id, UpdateRegionRequest request);
    
    void deleteRegion(String id);
    
    void enableRegion(String id);
    
    void disableRegion(String id);
    
    void updateSort(String id, Integer sort);
    
    void batchUpdate(List<RegionDTO> regions);
}
```

### 3.2 Service实现类

```java
package com.bucketwater.oms.module.admin.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.bucketwater.oms.module.admin.dto.RegionDTO;
import com.bucketwater.oms.module.admin.entity.Region;
import com.bucketwater.oms.module.admin.mapper.RegionMapper;
import com.bucketwater.oms.module.admin.service.AdminRegionService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdminRegionServiceImpl implements AdminRegionService {

    private final RegionMapper regionMapper;

    @Override
    public List<RegionDTO> getAllRegions(String status, Integer level) {
        LambdaQueryWrapper<Region> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(status)) {
            wrapper.eq(Region::getStatus, status);
        }
        if (level != null) {
            wrapper.eq(Region::getLevel, level);
        }
        wrapper.orderByAsc(Region::getSort).orderByAsc(Region::getCode);
        
        List<Region> regions = regionMapper.selectList(wrapper);
        return regions.stream().map(this::toDTO).collect(Collectors.toList());
    }

    @Override
    public List<RegionDTO> getRegionTree() {
        LambdaQueryWrapper<Region> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByAsc(Region::getSort).orderByAsc(Region::getCode);
        List<Region> allRegions = regionMapper.selectList(wrapper);
        
        Map<String, List<Region>> childrenMap = allRegions.stream()
            .filter(r -> r.getParentCode() != null)
            .collect(Collectors.groupingBy(Region::getParentCode));
        
        List<Region> roots = allRegions.stream()
            .filter(r -> r.getParentCode() == null)
            .collect(Collectors.toList());
        
        return roots.stream().map(r -> buildTree(r, childrenMap)).collect(Collectors.toList());
    }

    private RegionDTO buildTree(Region region, Map<String, List<Region>> childrenMap) {
        RegionDTO dto = toDTO(region);
        List<Region> children = childrenMap.get(region.getCode());
        if (children != null && !children.isEmpty()) {
            dto.setChildren(children.stream()
                .map(c -> buildTree(c, childrenMap))
                .collect(Collectors.toList()));
        } else {
            dto.setChildren(new ArrayList<>());
        }
        return dto;
    }

    @Override
    public RegionDTO getRegionById(String id) {
        Region region = regionMapper.selectById(id);
        if (region == null) {
            throw new BusinessException("地域不存在");
        }
        return toDTO(region);
    }

    @Override
    public RegionDTO getRegionByCode(String code) {
        LambdaQueryWrapper<Region> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Region::getCode, code);
        Region region = regionMapper.selectOne(wrapper);
        if (region == null) {
            throw new BusinessException("地域不存在");
        }
        return toDTO(region);
    }

    @Override
    public List<RegionDTO> getChildren(String parentCode) {
        List<Region> children = regionMapper.selectByParentCode(parentCode);
        return children.stream().map(this::toDTO).collect(Collectors.toList());
    }

    @Override
    public List<RegionDTO> getProvinces() {
        return getCities(null);
    }

    @Override
    public List<RegionDTO> getCities(String provinceCode) {
        List<Region> cities;
        if (StringUtils.hasText(provinceCode)) {
            cities = regionMapper.selectByParentCode(provinceCode);
        } else {
            LambdaQueryWrapper<Region> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(Region::getLevel, 1);
            wrapper.eq(Region::getStatus, "active");
            wrapper.orderByAsc(Region::getSort);
            cities = regionMapper.selectList(wrapper);
        }
        return cities.stream().map(this::toDTO).collect(Collectors.toList());
    }

    @Override
    public List<RegionDTO> getDistricts(String cityCode) {
        List<Region> districts = regionMapper.selectByParentCode(cityCode);
        return districts.stream().map(this::toDTO).collect(Collectors.toList());
    }

    @Override
    @Transactional
    public RegionDTO createRegion(CreateRegionRequest request) {
        if (!StringUtils.hasText(request.getCode()) || !StringUtils.hasText(request.getName())) {
            throw new BusinessException("区域编码和名称不能为空");
        }
        
        LambdaQueryWrapper<Region> codeCheck = new LambdaQueryWrapper<>();
        codeCheck.eq(Region::getCode, request.getCode());
        if (regionMapper.selectCount(codeCheck) > 0) {
            throw new BusinessException("区域编码已存在");
        }
        
        Region region = new Region();
        region.setId(UUID.randomUUID().toString());
        region.setCode(request.getCode());
        region.setName(request.getName());
        region.setParentCode(request.getParentCode());
        region.setSort(request.getSort() != null ? request.getSort() : 0);
        region.setRemark(request.getRemark());
        region.setStatus("active");
        
        if (StringUtils.hasText(request.getParentCode())) {
            Region parent = regionMapper.selectOne(
                new LambdaQueryWrapper<Region>().eq(Region::getCode, request.getParentCode())
            );
            if (parent == null) {
                throw new BusinessException("上级地域不存在");
            }
            int newLevel = parent.getLevel() + 1;
            if (newLevel > 3) {
                throw new BusinessException("地域层级不能超过3级");
            }
            region.setLevel(newLevel);
        } else {
            region.setLevel(1);
        }
        
        regionMapper.insert(region);
        return toDTO(region);
    }

    @Override
    @Transactional
    public RegionDTO updateRegion(String id, UpdateRegionRequest request) {
        Region region = regionMapper.selectById(id);
        if (region == null) {
            throw new BusinessException("地域不存在");
        }
        
        if (StringUtils.hasText(request.getCode()) && !request.getCode().equals(region.getCode())) {
            LambdaQueryWrapper<Region> codeCheck = new LambdaQueryWrapper<>();
            codeCheck.eq(Region::getCode, request.getCode()).ne(Region::getId, id);
            if (regionMapper.selectCount(codeCheck) > 0) {
                throw new BusinessException("区域编码已存在");
            }
            region.setCode(request.getCode());
        }
        
        if (StringUtils.hasText(request.getName())) {
            region.setName(request.getName());
        }
        
        if (request.getParentCode() != null) {
            if (request.getParentCode().equals(region.getCode())) {
                throw new BusinessException("不能将自己设为上级区域");
            }
            Region parent = regionMapper.selectOne(
                new LambdaQueryWrapper<Region>().eq(Region::getCode, request.getParentCode())
            );
            if (parent == null) {
                throw new BusinessException("上级地域不存在");
            }
            int newLevel = parent.getLevel() + 1;
            if (newLevel > 3) {
                throw new BusinessException("地域层级不能超过3级");
            }
            region.setParentCode(request.getParentCode());
            region.setLevel(newLevel);
        }
        
        if (request.getSort() != null) {
            region.setSort(request.getSort());
        }
        
        if (request.getRemark() != null) {
            region.setRemark(request.getRemark());
        }
        
        regionMapper.updateById(region);
        return toDTO(region);
    }

    @Override
    @Transactional
    public void deleteRegion(String id) {
        Region region = regionMapper.selectById(id);
        if (region == null) {
            throw new BusinessException("地域不存在");
        }
        
        List<Region> children = regionMapper.selectByParentCode(region.getCode());
        if (!children.isEmpty()) {
            throw new BusinessException("该地域下存在子地域，无法删除");
        }
        
        // 检查是否被水站使用
        // TODO: 检查station表是否有area=region.getCode()的记录
        
        // 检查是否被司机使用
        // TODO: 检查driver表是否有area=region.getCode()的记录
        
        regionMapper.deleteById(id);
    }

    @Override
    public void enableRegion(String id) {
        Region region = regionMapper.selectById(id);
        if (region == null) {
            throw new BusinessException("地域不存在");
        }
        region.setStatus("active");
        regionMapper.updateById(region);
    }

    @Override
    public void disableRegion(String id) {
        Region region = regionMapper.selectById(id);
        if (region == null) {
            throw new BusinessException("地域不存在");
        }
        region.setStatus("inactive");
        regionMapper.updateById(region);
    }

    @Override
    public void updateSort(String id, Integer sort) {
        Region region = regionMapper.selectById(id);
        if (region == null) {
            throw new BusinessException("地域不存在");
        }
        region.setSort(sort);
        regionMapper.updateById(region);
    }

    @Override
    @Transactional
    public void batchUpdate(List<RegionDTO> regions) {
        for (RegionDTO dto : regions) {
            Region region = regionMapper.selectById(dto.getId());
            if (region != null) {
                if (dto.getSort() != null) {
                    region.setSort(dto.getSort());
                }
                if (dto.getName() != null) {
                    region.setName(dto.getName());
                }
                regionMapper.updateById(region);
            }
        }
    }

    private RegionDTO toDTO(Region region) {
        RegionDTO dto = new RegionDTO();
        dto.setId(region.getId());
        dto.setCode(region.getCode());
        dto.setName(region.getName());
        dto.setParentCode(region.getParentCode());
        dto.setLevel(region.getLevel());
        dto.setSort(region.getSort());
        dto.setStatus(region.getStatus());
        dto.setRemark(region.getRemark());
        return dto;
    }
}
```

## 4. Controller层接口

### 4.1 Controller类

```java
package com.bucketwater.oms.module.admin.controller;

import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.module.admin.dto.RegionDTO;
import com.bucketwater.oms.module.admin.service.AdminRegionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin/regions")
@RequiredArgsConstructor
@Tag(name = "地域管理", description = "地域区域管理相关接口")
public class AdminRegionController {

    private final AdminRegionService regionService;

    @GetMapping
    @Operation(summary = "获取地域列表")
    public Result<List<RegionDTO>> getRegions(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) Integer level) {
        List<RegionDTO> regions = regionService.getAllRegions(status, level);
        return Result.success(regions);
    }

    @GetMapping("/tree")
    @Operation(summary = "获取地域树形结构")
    public Result<List<RegionDTO>> getRegionTree() {
        List<RegionDTO> tree = regionService.getRegionTree();
        return Result.success(tree);
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取地域详情")
    public Result<RegionDTO> getRegionById(@PathVariable String id) {
        RegionDTO region = regionService.getRegionById(id);
        return Result.success(region);
    }

    @GetMapping("/code/{code}")
    @Operation(summary = "根据编码获取地域")
    public Result<RegionDTO> getRegionByCode(@PathVariable String code) {
        RegionDTO region = regionService.getRegionByCode(code);
        return Result.success(region);
    }

    @GetMapping("/children/{parentCode}")
    @Operation(summary = "获取子地域")
    public Result<List<RegionDTO>> getChildren(@PathVariable String parentCode) {
        List<RegionDTO> children = regionService.getChildren(parentCode);
        return Result.success(children);
    }

    @GetMapping("/provinces")
    @Operation(summary = "获取省份列表")
    public Result<List<RegionDTO>> getProvinces() {
        List<RegionDTO> provinces = regionService.getProvinces();
        return Result.success(provinces);
    }

    @GetMapping("/cities/{provinceCode}")
    @Operation(summary = "获取城市列表")
    public Result<List<RegionDTO>> getCities(@PathVariable String provinceCode) {
        List<RegionDTO> cities = regionService.getCities(provinceCode);
        return Result.success(cities);
    }

    @GetMapping("/districts/{cityCode}")
    @Operation(summary = "获取区县列表")
    public Result<List<RegionDTO>> getDistricts(@PathVariable String cityCode) {
        List<RegionDTO> districts = regionService.getDistricts(cityCode);
        return Result.success(districts);
    }

    @PostMapping
    @Operation(summary = "创建地域")
    public Result<RegionDTO> createRegion(@RequestBody CreateRegionRequest request) {
        RegionDTO region = regionService.createRegion(request);
        return Result.success(region);
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新地域")
    public Result<RegionDTO> updateRegion(
            @PathVariable String id,
            @RequestBody UpdateRegionRequest request) {
        RegionDTO region = regionService.updateRegion(id, request);
        return Result.success(region);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除地域")
    public Result<Void> deleteRegion(@PathVariable String id) {
        regionService.deleteRegion(id);
        return Result.success();
    }

    @PatchMapping("/{id}/enable")
    @Operation(summary = "启用地域")
    public Result<Void> enableRegion(@PathVariable String id) {
        regionService.enableRegion(id);
        return Result.success();
    }

    @PatchMapping("/{id}/disable")
    @Operation(summary = "停用地域")
    public Result<Void> disableRegion(@PathVariable String id) {
        regionService.disableRegion(id);
        return Result.success();
    }

    @PatchMapping("/{id}/sort")
    @Operation(summary = "更新排序")
    public Result<Void> updateSort(
            @PathVariable String id,
            @RequestBody Map<String, Integer> body) {
        regionService.updateSort(id, body.get("sort"));
        return Result.success();
    }

    @PatchMapping("/batch")
    @Operation(summary = "批量更新地域")
    public Result<Void> batchUpdate(@RequestBody Map<String, List<RegionDTO>> body) {
        regionService.batchUpdate(body.get("regions"));
        return Result.success();
    }
}
```

## 5. API接口汇总

### 5.1 接口列表

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | /api/admin/regions | 获取地域列表 |
| GET | /api/admin/regions/tree | 获取地域树形结构 |
| GET | /api/admin/regions/{id} | 获取地域详情 |
| GET | /api/admin/regions/code/{code} | 根据编码获取地域 |
| GET | /api/admin/regions/children/{parentCode} | 获取子地域 |
| GET | /api/admin/regions/provinces | 获取省份列表 |
| GET | /api/admin/regions/cities/{provinceCode} | 获取城市列表 |
| GET | /api/admin/regions/districts/{cityCode} | 获取区县列表 |
| POST | /api/admin/regions | 创建地域 |
| PUT | /api/admin/regions/{id} | 更新地域 |
| DELETE | /api/admin/regions/{id} | 删除地域 |
| PATCH | /api/admin/regions/{id}/enable | 启用地域 |
| PATCH | /api/admin/regions/{id}/disable | 停用地域 |
| PATCH | /api/admin/regions/{id}/sort | 更新排序 |
| PATCH | /api/admin/regions/batch | 批量更新地域 |

### 5.2 请求响应示例

#### 获取地域树形结构

请求: `GET /api/admin/regions/tree`

响应:
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440001",
      "code": "330000",
      "name": "浙江省",
      "parentCode": null,
      "level": 1,
      "sort": 1,
      "status": "active",
      "remark": null,
      "children": [
        {
          "id": "550e8400-e29b-41d4-a716-446655440002",
          "code": "330100",
          "name": "杭州市",
          "parentCode": "330000",
          "level": 2,
          "sort": 1,
          "status": "active",
          "remark": null,
          "children": [
            {
              "id": "550e8400-e29b-41d4-a716-446655440005",
              "code": "330108",
              "name": "滨江区",
              "parentCode": "330100",
              "level": 3,
              "sort": 3,
              "status": "active",
              "remark": null,
              "children": []
            }
          ]
        }
      ]
    }
  ]
}
```

#### 创建地域

请求: `POST /api/admin/regions`

```json
{
  "code": "330112",
  "name": "钱塘区",
  "parentCode": "330100",
  "sort": 9,
  "remark": "2024年新设区域"
}
```

响应:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": "uuid",
    "code": "330112",
    "name": "钱塘区",
    "parentCode": "330100",
    "level": 3,
    "sort": 9,
    "status": "active",
    "remark": "2024年新设区域"
  }
}
```

## 6. 业务规则说明

### 6.1 层级限制
- 地域最多支持3级：省/直辖市 → 市/区 → 县/街道
- 创建子地域时自动计算层级
- 不能超过3级

### 6.2 删除校验
- 有子地域的不能删除
- 被水站使用的不能删除
- 被司机使用的不能删除

### 6.3 编码规范
- 编码应使用数字，通常采用行政区划代码（如330100表示杭州市）
- 编码必须唯一
- 上级编码是下级编码的前缀（如330000是330100的上级）

### 6.4 状态管理
- active: 启用状态，可正常使用
- inactive: 停用状态，不显示在选择列表中，但保留历史数据关联

## 7. 关联业务使用

### 7.1 水站管理
在水站表(station)中添加area字段存储地域编码：
```sql
ALTER TABLE station ADD COLUMN area VARCHAR(50);
```

### 7.2 司机管理
在司机表(driver)中添加area字段存储地域编码：
```sql
ALTER TABLE driver ADD COLUMN area VARCHAR(50);
```

### 7.3 数据查询示例

```java
// 根据地域查询水站
List<Station> stations = stationMapper.selectList(
    new LambdaQueryWrapper<Station>().eq(Station::getArea, "330108")
);

// 根据地域查询司机
List<Driver> drivers = driverMapper.selectList(
    new LambdaQueryWrapper<Driver>().eq(Driver::getArea, "330108")
);

// 地域名称转换（可在Service层使用缓存优化）
String areaName = regionService.getRegionByCode(station.getArea()).getName();
```

## 8. 性能优化建议

### 8.1 缓存策略
- 地域数据变化不频繁，适合使用Redis缓存
- 建议缓存Key: `region:tree` (树形结构), `region:all` (平铺列表)
- 缓存更新时机: 创建、更新、删除地域时清除缓存

### 8.2 数据库优化
- 确保parent_code、code、status、level字段有索引
- 查询树形结构时使用递归或JOIN查询

## 9. 错误码定义

| 错误码 | 描述 |
|--------|------|
| REGION_NOT_FOUND | 地域不存在 |
| REGION_CODE_EXISTS | 区域编码已存在 |
| REGION_HAS_CHILDREN | 该地域下存在子地域 |
| REGION_IN_USE | 该地域已被使用 |
| REGION_LEVEL_EXCEEDED | 地域层级超过限制 |
| REGION_SELF_PARENT | 不能将自己设为上级区域 |
