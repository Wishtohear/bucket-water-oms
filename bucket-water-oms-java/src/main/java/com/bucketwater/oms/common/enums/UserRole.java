package com.bucketwater.oms.common.enums;

public enum UserRole {

    PLATFORM_ADMIN("平台总超级管理员"),
    FACTORY_ADMIN("水厂管理员"),
    WAREHOUSE_ADMIN("仓库管理员"),
    DRIVER("配送司机"),
    STATION_OWNER("水站老板"),
    STATION_CLERK("水站店员");

    private final String description;

    UserRole(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }

    public boolean isPlatformAdmin() {
        return this == PLATFORM_ADMIN;
    }

    public boolean isFactoryAdmin() {
        return this == FACTORY_ADMIN;
    }
}
