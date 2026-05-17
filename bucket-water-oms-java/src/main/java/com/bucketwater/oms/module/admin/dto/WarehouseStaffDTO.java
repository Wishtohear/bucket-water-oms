package com.bucketwater.oms.module.admin.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

@Data
@Schema(description = "仓库人员DTO")
public class WarehouseStaffDTO {

    @Schema(description = "用户ID")
    private String id;

    @Schema(description = "姓名")
    private String name;

    @Schema(description = "角色: admin/staff")
    private String role;

    @Schema(description = "在线状态: online/offline")
    private String onlineStatus;
}
