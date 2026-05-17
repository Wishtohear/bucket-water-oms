package com.bucketwater.oms.module.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "登录响应")
public class LoginResponse {

    @Schema(description = "访问令牌")
    private String accessToken;

    @Schema(description = "刷新令牌")
    private String refreshToken;

    @Schema(description = "过期时间(秒)")
    private Long expiresIn;

    @Schema(description = "用户信息")
    private UserInfo user;

    public LoginResponse() {}

    public LoginResponse(String accessToken, String refreshToken, Long expiresIn, UserInfo user) {
        this.accessToken = accessToken;
        this.refreshToken = refreshToken;
        this.expiresIn = expiresIn;
        this.user = user;
    }

    public String getAccessToken() {
        return accessToken;
    }

    public void setAccessToken(String accessToken) {
        this.accessToken = accessToken;
    }

    public String getRefreshToken() {
        return refreshToken;
    }

    public void setRefreshToken(String refreshToken) {
        this.refreshToken = refreshToken;
    }

    public Long getExpiresIn() {
        return expiresIn;
    }

    public void setExpiresIn(Long expiresIn) {
        this.expiresIn = expiresIn;
    }

    public UserInfo getUser() {
        return user;
    }

    public void setUser(UserInfo user) {
        this.user = user;
    }

    @Schema(description = "用户信息")
    public static class UserInfo {

        @Schema(description = "用户ID")
        private String id;

        @Schema(description = "姓名")
        private String name;

        @Schema(description = "角色")
        private String role;

        @Schema(description = "手机号")
        private String phone;

        @Schema(description = "头像")
        private String avatar;

        @Schema(description = "水站ID")
        private String stationId;

        @Schema(description = "仓库ID")
        private String warehouseId;

        @Schema(description = "司机ID")
        private String driverId;

        public UserInfo() {}

        public UserInfo(String id, String name, String role, String phone, String avatar, 
                       String stationId, String warehouseId, String driverId) {
            this.id = id;
            this.name = name;
            this.role = role;
            this.phone = phone;
            this.avatar = avatar;
            this.stationId = stationId;
            this.warehouseId = warehouseId;
            this.driverId = driverId;
        }

        public String getId() {
            return id;
        }

        public void setId(String id) {
            this.id = id;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getRole() {
            return role;
        }

        public void setRole(String role) {
            this.role = role;
        }

        public String getPhone() {
            return phone;
        }

        public void setPhone(String phone) {
            this.phone = phone;
        }

        public String getAvatar() {
            return avatar;
        }

        public void setAvatar(String avatar) {
            this.avatar = avatar;
        }

        public String getStationId() {
            return stationId;
        }

        public void setStationId(String stationId) {
            this.stationId = stationId;
        }

        public String getWarehouseId() {
            return warehouseId;
        }

        public void setWarehouseId(String warehouseId) {
            this.warehouseId = warehouseId;
        }

        public String getDriverId() {
            return driverId;
        }

        public void setDriverId(String driverId) {
            this.driverId = driverId;
        }
    }
}
