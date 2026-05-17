package com.bucketwater.oms.common.enums;

public enum BucketTransactionType {

    DEPOSIT("押金收取"),
    RETURN("回桶"),
    OWED("欠桶"),
    DEPOSIT_REFUND("补缴押金"),
    DIFF_COMPENSATION("差异赔偿");

    private final String description;

    BucketTransactionType(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}
