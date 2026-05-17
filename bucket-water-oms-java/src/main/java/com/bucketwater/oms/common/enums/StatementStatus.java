package com.bucketwater.oms.common.enums;

public enum StatementStatus {

    GENERATED("已生成"),
    CONFIRMED("已确认"),
    DISPUTED("有争议");

    private final String description;

    StatementStatus(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}
