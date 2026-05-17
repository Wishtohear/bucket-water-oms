package com.bucketwater.oms.module.admin.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

@Data
@Schema(description = "水站店员账号DTO")
public class StationStaffDTO {

    @Schema(description = "账号ID")
    private Long id;

    @Schema(description = "姓名")
    private String name;

    @Schema(description = "手机号")
    private String phone;

    @Schema(description = "角色: owner/staff")
    private String role;

    @Schema(description = "状态: active/inactive")
    private String status;

    @Schema(description = "密码(可选)")
    private String password;
}
