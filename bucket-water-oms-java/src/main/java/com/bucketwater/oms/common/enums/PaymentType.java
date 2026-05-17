package com.bucketwater.oms.common.enums;

public enum PaymentType {

    DEPOSIT("预存金"),
    MONTHLY_SETTLEMENT("月结"),
    CREDIT("信用额度");

    private final String description;

    PaymentType(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}
