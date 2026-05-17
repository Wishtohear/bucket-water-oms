package com.bucketwater.oms.module.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

@Schema(description = "发送验证码请求")
public class SmsCodeRequest {

    @NotBlank(message = "手机号不能为空")
    @Schema(description = "手机号")
    private String phone;

    @NotBlank(message = "类型不能为空")
    @Schema(description = "类型: login/register/reset_password")
    private String type;

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }
}
