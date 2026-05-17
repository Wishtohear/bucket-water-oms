package com.bucketwater.oms.module.user.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.bucketwater.oms.common.BaseEntity;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("sys_user")
@Schema(description = "系统用户实体")
public class SampleUser extends BaseEntity {

    @Schema(description = "用户名")
    private String username;

    @Schema(description = "密码（加密存储）")
    private String password;

    @Schema(description = "真实姓名")
    private String realName;

    @Schema(description = "手机号")
    private String phone;

    @Schema(description = "邮箱")
    private String email;

    @Schema(description = "角色：FACTORY_ADMIN/WAREHOUSE_ADMIN/DRIVER/STATION_OWNER/STATION_CLERK")
    private String role;

    @Schema(description = "关联ID（水站ID/仓库ID/司机ID）")
    private Long relatedId;

    @Schema(description = "状态：0-禁用，1-启用")
    private Integer status;

    @Schema(description = "最后登录时间")
    private java.time.LocalDateTime lastLoginTime;

    @Schema(description = "最后登录IP")
    private String lastLoginIp;
}
