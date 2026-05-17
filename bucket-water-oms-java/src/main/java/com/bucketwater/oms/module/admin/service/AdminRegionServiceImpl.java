package com.bucketwater.oms.module.admin.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.admin.dto.CreateRegionRequest;
import com.bucketwater.oms.module.admin.dto.RegionDTO;
import com.bucketwater.oms.module.admin.dto.UpdateRegionRequest;
import com.bucketwater.oms.module.admin.entity.Region;
import com.bucketwater.oms.module.admin.mapper.RegionMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
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
    public RegionDTO getRegionById(Long id) {
        Region region = regionMapper.selectById(id);
        if (region == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "地域不存在");
        }
        return toDTO(region);
    }

    @Override
    public RegionDTO getRegionByCode(String code) {
        LambdaQueryWrapper<Region> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Region::getCode, code);
        Region region = regionMapper.selectOne(wrapper);
        if (region == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "地域不存在");
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
            throw new BusinessException(ResultCode.PARAM_ERROR, "区域编码和名称不能为空");
        }

        Region existingRecord = regionMapper.selectByCodeIncludingDeleted(request.getCode());

        if (existingRecord != null) {
            if (existingRecord.getDeleted() == null || existingRecord.getDeleted() == 0) {
                throw new BusinessException(ResultCode.DATA_EXISTS, "区域编码已存在");
            }
            regionMapper.deleteById(existingRecord.getId());
        }

        Region region = new Region();
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
                throw new BusinessException(ResultCode.NOT_FOUND, "上级地域不存在");
            }
            int newLevel = parent.getLevel() + 1;
            if (newLevel > 3) {
                throw new BusinessException(ResultCode.PARAM_ERROR, "地域层级不能超过3级");
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
    public RegionDTO updateRegion(Long id, UpdateRegionRequest request) {
        Region region = regionMapper.selectById(id);
        if (region == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "地域不存在");
        }

        if (StringUtils.hasText(request.getCode()) && !request.getCode().equals(region.getCode())) {
            LambdaQueryWrapper<Region> codeCheck = new LambdaQueryWrapper<>();
            codeCheck.eq(Region::getCode, request.getCode()).ne(Region::getId, id);
            if (regionMapper.selectCount(codeCheck) > 0) {
                throw new BusinessException(ResultCode.DATA_EXISTS, "区域编码已存在");
            }
            region.setCode(request.getCode());
        }

        if (StringUtils.hasText(request.getName())) {
            region.setName(request.getName());
        }

        if (request.getParentCode() != null) {
            if (request.getParentCode().equals(region.getCode())) {
                throw new BusinessException(ResultCode.PARAM_ERROR, "不能将自己设为上级区域");
            }
            Region parent = regionMapper.selectOne(
                new LambdaQueryWrapper<Region>().eq(Region::getCode, request.getParentCode())
            );
            if (parent == null) {
                throw new BusinessException(ResultCode.NOT_FOUND, "上级地域不存在");
            }
            int newLevel = parent.getLevel() + 1;
            if (newLevel > 3) {
                throw new BusinessException(ResultCode.PARAM_ERROR, "地域层级不能超过3级");
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
    public void deleteRegion(Long id) {
        Region region = regionMapper.selectById(id);
        if (region == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "地域不存在");
        }

        deleteRegionWithChildren(region.getCode());
    }

    private void deleteRegionWithChildren(String parentCode) {
        List<Region> children = regionMapper.selectByParentCode(parentCode);

        for (Region child : children) {
            deleteRegionWithChildren(child.getCode());
        }

        LambdaQueryWrapper<Region> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Region::getCode, parentCode);
        regionMapper.delete(wrapper);
    }

    @Override
    public void enableRegion(Long id) {
        Region region = regionMapper.selectById(id);
        if (region == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "地域不存在");
        }
        region.setStatus("active");
        regionMapper.updateById(region);
    }

    @Override
    public void disableRegion(Long id) {
        Region region = regionMapper.selectById(id);
        if (region == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "地域不存在");
        }
        region.setStatus("inactive");
        regionMapper.updateById(region);
    }

    @Override
    public void updateSort(Long id, Integer sort) {
        Region region = regionMapper.selectById(id);
        if (region == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "地域不存在");
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
