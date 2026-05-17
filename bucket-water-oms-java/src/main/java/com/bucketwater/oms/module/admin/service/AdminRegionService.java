package com.bucketwater.oms.module.admin.service;

import com.bucketwater.oms.module.admin.dto.CreateRegionRequest;
import com.bucketwater.oms.module.admin.dto.RegionDTO;
import com.bucketwater.oms.module.admin.dto.UpdateRegionRequest;

import java.util.List;

public interface AdminRegionService {

    List<RegionDTO> getAllRegions(String status, Integer level);

    List<RegionDTO> getRegionTree();

    RegionDTO getRegionById(Long id);

    RegionDTO getRegionByCode(String code);

    List<RegionDTO> getChildren(String parentCode);

    List<RegionDTO> getProvinces();

    List<RegionDTO> getCities(String provinceCode);

    List<RegionDTO> getDistricts(String cityCode);

    RegionDTO createRegion(CreateRegionRequest request);

    RegionDTO updateRegion(Long id, UpdateRegionRequest request);

    void deleteRegion(Long id);

    void enableRegion(Long id);

    void disableRegion(Long id);

    void updateSort(Long id, Integer sort);

    void batchUpdate(List<RegionDTO> regions);
}
