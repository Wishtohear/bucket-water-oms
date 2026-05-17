package com.bucketwater.oms.common.enums;

public enum AfterSalesStatus {

    PENDING("待处理"),
    PROCESSING("处理中"),
    COMPLETED("已完成"),
    REJECTED("已拒绝");

    private final String description;

    AfterSalesStatus(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}
