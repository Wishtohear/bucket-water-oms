package com.bucketwater.oms.module.admin.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;

@Schema(description = "地域DTO")
public class RegionDTO {
    @Schema(description = "主键ID")
    private Long id;

    @Schema(description = "区域编码")
    private String code;

    @Schema(description = "区域名称")
    private String name;

    @Schema(description = "上级区域编码")
    private String parentCode;

    @Schema(description = "层级")
    private Integer level;

    @Schema(description = "排序值")
    private Integer sort;

    @Schema(description = "状态: active-启用, inactive-停用")
    private String status;

    @Schema(description = "备注")
    private String remark;

    @Schema(description = "子地域列表")
    private List<RegionDTO> children;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getParentCode() { return parentCode; }
    public void setParentCode(String parentCode) { this.parentCode = parentCode; }
    public Integer getLevel() { return level; }
    public void setLevel(Integer level) { this.level = level; }
    public Integer getSort() { return sort; }
    public void setSort(Integer sort) { this.sort = sort; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getRemark() { return remark; }
    public void setRemark(String remark) { this.remark = remark; }
    public List<RegionDTO> getChildren() { return children; }
    public void setChildren(List<RegionDTO> children) { this.children = children; }
}
