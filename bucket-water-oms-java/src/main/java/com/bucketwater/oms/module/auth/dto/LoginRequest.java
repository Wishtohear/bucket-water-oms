package com.bucketwater.oms.module.auth.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonSetter;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

@JsonIgnoreProperties(ignoreUnknown = true)
@Schema(description = "登录请求")
public class LoginRequest {

    @NotBlank(message = "手机号不能为空")
    @Schema(description = "手机号")
    private String phone;

    @JsonSetter("username")
    public void setUsername(String username) {
        this.phone = username;
    }

    @NotBlank(message = "密码不能为空")
    @Schema(description = "密码")
    private String password;

    @NotBlank(message = "角色不能为空")
    @Schema(description = "角色: station/driver/warehouse/admin")
    private String role;

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
}
