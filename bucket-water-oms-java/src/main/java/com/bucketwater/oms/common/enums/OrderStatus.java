package com.bucketwater.oms.common.enums;

public enum OrderStatus {

    PENDING_REVIEW("待审查"),
    ACCEPTED("已接单"),
    ASSIGNED("已派单"),
    DELIVERING("配送中"),
    COMPLETED("已完成"),
    CANCELLED("已取消"),
    REJECTED("已拒单");

    private final String description;

    OrderStatus(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}
